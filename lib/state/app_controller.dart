import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/gallery_service.dart';
import '../services/photo_mapper.dart';
import '../services/hidden_photo_service.dart';

/// Immutable snapshot of the whole app's navigation state. This mirrors the
/// several `useState` calls at the top of the original `App()` component.
class AppState {
  final AppScreen screen;
  final TabName activeTab;
  final SwipeContext? swipeCtx;
  final Map<PhotoAction, int> reviewCounts;
  final ReviewResult? reviewResult;
  final List<Photo> deleteQueue;

  const AppState({
    required this.screen,
    required this.activeTab,
    required this.swipeCtx,
    required this.reviewCounts,
    required this.deleteQueue,
    required this.reviewResult,
  });

  factory AppState.initial() => const AppState(
        screen: AppScreen.splash,
        activeTab: TabName.gallery,
        swipeCtx: null,
        reviewResult: null,
        deleteQueue: const [],
        reviewCounts: {
          PhotoAction.keep: 0,
          PhotoAction.delete: 0,
          PhotoAction.later: 0,
          PhotoAction.favorite: 0,
        },
      );

  bool get showNav => const {
        AppScreen.gallery,
        AppScreen.reviewMenu,
        AppScreen.reviewDate,
        AppScreen.reviewLocation,
        AppScreen.settings,
      }.contains(screen);

  AppState copyWith({
    AppScreen? screen,
    TabName? activeTab,
    SwipeContext? swipeCtx,
    bool clearSwipeCtx = false,
    Map<PhotoAction, int>? reviewCounts,
    ReviewResult? reviewResult,
    List<Photo>? deleteQueue,
  }) {
    return AppState(
      reviewResult: reviewResult ?? this.reviewResult,
      screen: screen ?? this.screen,
      activeTab: activeTab ?? this.activeTab,
      swipeCtx: clearSwipeCtx ? null : (swipeCtx ?? this.swipeCtx),
      reviewCounts: reviewCounts ?? this.reviewCounts,
      deleteQueue: deleteQueue ?? this.deleteQueue,
    );
  }
}

class AppController extends StateNotifier<AppState> {
  final GalleryService _galleryService = GalleryService();
  final HiddenPhotoService _hiddenPhotoService =
      HiddenPhotoService();

  List<Photo>? _galleryPhotos;

  Set<String> _hiddenPhotoIds = {};

  List<Photo>? get galleryPhotos => _galleryPhotos;

  AppController() : super(AppState.initial()) {
    _loadGalleryPhotos();
  }

  /// Requests albums from [GalleryService], restricted to assets created
  /// in the last 3 months, uses the first non-empty album's assets, and
  /// maps them to [Photo] via [PhotoMapper].
  /// Leaves [_galleryPhotos] as `null` on permission denial, empty
  /// gallery, or any error, so mock_data keeps being used as before.
  Future<void> _loadGalleryPhotos() async {
    try {
      final DateTime threeMonthsAgo =
          DateTime.now().subtract(const Duration(days: 90));

      final albums =
          await _galleryService.getAlbums(createdAfter: threeMonthsAgo);

      for (final album in albums) {
        final assets = await _galleryService.getAssetsFromAlbum(album);

        final withinWindow = assets.where((a) {
          final DateTime? createdAt = a.createDateTime;
          return createdAt != null &&
              !createdAt.isBefore(threeMonthsAgo);
        }).toList();

        if (withinWindow.isNotEmpty) {
          final mappedPhotos =
              PhotoMapper.fromAssetEntities(withinWindow);

          _hiddenPhotoIds =
              await _hiddenPhotoService.getHiddenIds();

          _galleryPhotos = mappedPhotos
              .where(
                (photo) =>
                    !_hiddenPhotoIds.contains(photo.id.toString()),
              )
              .toList();

          state = state.copyWith(
            activeTab: state.activeTab,
          );

          return;
        }
      }
    } catch (_) {
      // Permission denied or any failure.
    }
  }

  void finishSplash() => state = state.copyWith(screen: AppScreen.gallery);

  void changeTab(TabName tab) {
    late AppScreen next;
    switch (tab) {
      case TabName.gallery:
        next = AppScreen.gallery;
        break;
      case TabName.review:
        next = AppScreen.reviewMenu;
        break;
      case TabName.settings:
        next = AppScreen.settings;
        break;
    }
    state = state.copyWith(activeTab: tab, screen: next);
  }

  void openReviewFromGallery() {
    state = state.copyWith(screen: AppScreen.reviewMenu, activeTab: TabName.review);
  }

  void _enterSwipe(SwipeContext ctx) {
    state = state.copyWith(swipeCtx: ctx, screen: AppScreen.swipe);
  }

  void selectReviewMode(ReviewMode mode) {
    if (mode == ReviewMode.date) {
      state = state.copyWith(
        screen: AppScreen.reviewDate,
      );
      return;
    }

    if (mode == ReviewMode.location) {
      state = state.copyWith(
        screen: AppScreen.reviewLocation,
      );
      return;
    }

    final List<Photo>? gallery = _galleryPhotos;
    final bool useGallery =
        gallery != null && gallery.isNotEmpty;

    final Map<ReviewMode, SwipeContext> configs = {
      ReviewMode.duplicates: SwipeContext(
        mode: mode,
        title: 'Duplicates',
        subtitle: '47 sets · 94 photos',
        photos: useGallery ? gallery : baliPhotos,
        total: 94,
      ),

      ReviewMode.screenshots: SwipeContext(
        mode: mode,
        title: 'Screenshots',
        subtitle: '234 found',
        photos: useGallery ? gallery : tokyoPhotos,
        total: 234,
      ),

      ReviewMode.largeVideos: SwipeContext(
        mode: mode,
        title: 'Large Videos',
        subtitle: '12 videos · 1.8 GB',
        photos: useGallery ? gallery : bandungPhotos,
        total: 12,
      ),

      ReviewMode.surprise: SwipeContext(
        mode: mode,
        title: 'Surprise Me',
        subtitle: 'Random selection',
        photos: useGallery ? gallery : surprisePhotos,
        total: 48,
      ),
    };

    _enterSwipe(configs[mode]!);
  }

  void startDateGroup(DateGroup g) {
    _enterSwipe(SwipeContext(mode: ReviewMode.date, title: g.month, subtitle: g.location, photos: g.photos, total: g.count));
  }

  void startLocationGroup(LocationGroup g) {
    _enterSwipe(SwipeContext(mode: ReviewMode.location, title: g.location, subtitle: g.date, photos: g.photos, total: g.count));
  }
  Future<void> hidePhotos(List<Photo> photos) async {
    if (photos.isEmpty) return;

    final ids = photos
        .map((photo) => photo.id.toString())
        .toList();

    await _hiddenPhotoService.hideMany(ids);

    _hiddenPhotoIds.addAll(ids);

    if (_galleryPhotos != null) {
      _galleryPhotos = _galleryPhotos!
          .where(
            (photo) => !_hiddenPhotoIds.contains(photo.id.toString()),
          )
          .toList();
    }

    state = state.copyWith(
      activeTab: state.activeTab,
    );
  }

  Future<void> restorePhotos(List<Photo> photos) async {
    if (photos.isEmpty) return;

    final ids = photos
        .map((photo) => photo.id.toString())
        .toList();

    await _hiddenPhotoService.restoreMany(ids);

    _hiddenPhotoIds.removeAll(ids);

    if (_galleryPhotos != null) {
      _galleryPhotos = [
        ..._galleryPhotos!,
        ...photos,
      ];
    }

    state = state.copyWith(
      activeTab: state.activeTab,
    );
  }

  void swipeDone(ReviewResult result) {
    state = state.copyWith(
      reviewCounts: result.counts,
      reviewResult: result,
      deleteQueue: result.deletePhotos,
      screen: AppScreen.finished,
    );
  }

  void swipeBack() {
    final mode = state.swipeCtx?.mode;
    final AppScreen next = mode == ReviewMode.date
        ? AppScreen.reviewDate
        : mode == ReviewMode.location
            ? AppScreen.reviewLocation
            : AppScreen.reviewMenu;
    state = state.copyWith(screen: next, clearSwipeCtx: true);
  }

  void finishedDone() {
    state = state.copyWith(
      activeTab: TabName.gallery,
      screen: AppScreen.gallery,
      clearSwipeCtx: true,
    );
  }
  void openDeleteQueue() {
    state = state.copyWith(
      screen: AppScreen.deleteQueue,
    );
  }
  Future<void> restoreSelected(List indexes) async {
    final queue = [...state.deleteQueue];

    final selectedPhotos = <Photo>[];

    for (final index in indexes) {
      if (index >= 0 && index < queue.length) {
        selectedPhotos.add(queue[index]);
      }
    }

    if (selectedPhotos.isEmpty) return;

    await restorePhotos(selectedPhotos);

    final sortedIndexes = [...indexes]
      ..sort((a, b) => b.compareTo(a));

    for (final index in sortedIndexes) {
      if (index >= 0 && index < queue.length) {
        queue.removeAt(index);
      }
    }

    state = state.copyWith(
      deleteQueue: queue,
    );
  }

  Future<void> deleteSelected(List indexes) async {
    final queue = [...state.deleteQueue];

    final selectedPhotos = <Photo>[];

    for (final index in indexes) {
      if (index >= 0 && index < queue.length) {
        selectedPhotos.add(queue[index]);
      }
    }

    if (selectedPhotos.isEmpty) return;

    await hidePhotos(selectedPhotos);

    final sortedIndexes = [...indexes]
      ..sort((a, b) => b.compareTo(a));

    for (final index in sortedIndexes) {
      if (index >= 0 && index < queue.length) {
        queue.removeAt(index);
      }
    }

    state = state.copyWith(
      deleteQueue: queue,
    );
  }
    /// Used by the Review-by-date / Review-by-location back buttons.
    void backToReviewMenu() => state = state.copyWith(screen: AppScreen.reviewMenu);
  }

final appControllerProvider = StateNotifierProvider<AppController, AppState>(
  (ref) => AppController(),
);

// ─── Settings ───────────────────────────────────────────────────────────────

class SettingsState {
  final bool swipeHints;
  final bool permanentDelete;
  final bool notifications;
  final bool darkMode;

  const SettingsState({
    this.swipeHints = true,
    this.permanentDelete = false,
    this.notifications = true,
    this.darkMode = false,
  });

  SettingsState copyWith({
    bool? swipeHints,
    bool? permanentDelete,
    bool? notifications,
    bool? darkMode,
  }) {
    return SettingsState(
      swipeHints: swipeHints ?? this.swipeHints,
      permanentDelete: permanentDelete ?? this.permanentDelete,
      notifications: notifications ?? this.notifications,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());

  void toggleSwipeHints() => state = state.copyWith(swipeHints: !state.swipeHints);
  void togglePermanentDelete() => state = state.copyWith(permanentDelete: !state.permanentDelete);
  void toggleNotifications() => state = state.copyWith(notifications: !state.notifications);
  void toggleDarkMode() => state = state.copyWith(darkMode: !state.darkMode);
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(),
);