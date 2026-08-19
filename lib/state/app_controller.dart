import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/gallery_service.dart';
import '../services/photo_mapper.dart';
import '../services/hidden_photo_service.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_cache_service.dart';

/// Immutable snapshot of the whole app's navigation state. This mirrors the
/// several `useState` calls at the top of the original `App()` component.
class AppState {
  final AppScreen screen;
  final TabName activeTab;
  final SwipeContext? swipeCtx;
  final Map<PhotoAction, int> reviewCounts;
  final ReviewResult? reviewResult;
  final List<Photo> deleteQueue;
  final bool galleryLoading;
  final List<LocationGroup> locationGroups;
  final int locationProgress;
  final int locationTotal;

  const AppState({
    required this.screen,
    required this.activeTab,
    required this.swipeCtx,
    required this.reviewCounts,
    required this.locationGroups,
    required this.deleteQueue,
    required this.reviewResult,
    required this.galleryLoading,
    this.locationProgress = 0,
    this.locationTotal = 0,
  });

  factory AppState.initial() => const AppState(
        screen: AppScreen.splash,
        galleryLoading: true,
        activeTab: TabName.gallery,
        swipeCtx: null,
        reviewResult: null,
        deleteQueue: const [],
        locationGroups: [],
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
    List<LocationGroup>? locationGroups,
    ReviewResult? reviewResult,
    List<Photo>? deleteQueue,
    bool? galleryLoading,
    int? locationProgress,
    int? locationTotal,
  }) {
    return AppState(
      reviewResult: reviewResult ?? this.reviewResult,
      screen: screen ?? this.screen,
      activeTab: activeTab ?? this.activeTab,
      swipeCtx: clearSwipeCtx ? null : (swipeCtx ?? this.swipeCtx),
      reviewCounts: reviewCounts ?? this.reviewCounts,
      deleteQueue: deleteQueue ?? this.deleteQueue,
      galleryLoading: galleryLoading ?? this.galleryLoading,
      locationGroups: locationGroups ?? this.locationGroups,
      locationProgress:
          locationProgress ?? this.locationProgress,

      locationTotal:
          locationTotal ?? this.locationTotal,
    );
  }
}

class AppController extends StateNotifier<AppState> {
  final Set<String> _hiddenPhotoUrls = {};
  Set<String> get hiddenPhotoIds => _hiddenPhotoIds;
  final GalleryService _galleryService = GalleryService();
  final HiddenPhotoService _hiddenPhotoService =
      HiddenPhotoService();
  final Geocoding _geocoding = Geocoding();
  List<Photo>? _galleryPhotos;
  final Map<String, ({double latitude, double longitude})?>
    _locationCache = {};
  final LocationCacheService _locationCacheService =
    LocationCacheService();
  List<Photo> _favoritePhotos = [];
  

  List<Photo> get favoritePhotos => _favoritePhotos;

  Set<String> _hiddenPhotoIds = {};
  Set<String> get hiddenPhotoUrls => _hiddenPhotoUrls;
  List<Photo>? get galleryPhotos => _galleryPhotos;

  List<Photo> _screenshotPhotos = [];

  List<Photo> get screenshotPhotos => _screenshotPhotos;
  int get videoCount {
    return _galleryPhotos
            ?.where(
              (photo) => photo.asset?.type == AssetType.video,
            )
            .length ??
        0;
  }

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

      debugPrint('GALLERY: requesting albums...');

      final albums = await _galleryService.getAlbums(
        createdAfter: threeMonthsAgo,
      );

      debugPrint('GALLERY: albums found = ${albums.length}');

      for (final album in albums) {
        final assets = await _galleryService.getAssetsFromAlbum(album);

        debugPrint(
          'GALLERY: album=${album.name} assets=${assets.length}',
        );

        final withinWindow = assets.where((a) {
          final DateTime? createdAt = a.createDateTime;

          return createdAt != null &&
              !createdAt.isBefore(threeMonthsAgo);
        }).toList();

        debugPrint(
          'GALLERY: within 3 months = ${withinWindow.length}',
        );

        if (withinWindow.isNotEmpty) {
          _galleryPhotos =
              PhotoMapper.fromAssetEntities(withinWindow);

          debugPrint(
            'GALLERY: loaded ${_galleryPhotos!.length} photos',
          );

          state = state.copyWith(
            galleryLoading: false,
          );

          final screenshotAssets =
              await _galleryService.filterScreenshots(withinWindow);

          _screenshotPhotos =
              PhotoMapper.fromAssetEntities(screenshotAssets);

          debugPrint(
            'GALLERY: found ${_screenshotPhotos.length} screenshots',
          );

          state = state.copyWith(
            galleryLoading: false,
          );

          return;
        }
      }

      debugPrint('GALLERY: no photos found in last 3 months');

      state = state.copyWith(
        galleryLoading: false,
      );
    } catch (e, stackTrace) {
      debugPrint('GALLERY ERROR: $e');
      debugPrint('$stackTrace');

      state = state.copyWith(
        galleryLoading: false,
      );
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


  Future<void> selectReviewMode(ReviewMode mode) async {
    if (mode == ReviewMode.date) {
      state = state.copyWith(
        screen: AppScreen.reviewDate,
      );
      return;
    }

    if (mode == ReviewMode.location) {
      final permission =
          await Permission.accessMediaLocation.request();

      if (!permission.isGranted) {
        return;
      }

      final gallery = _galleryPhotos ?? <Photo>[];

      state = state.copyWith(
        screen: AppScreen.reviewLocation,
        locationGroups: [],
        locationProgress: 0,
        locationTotal: gallery.length,
      );

      

      final Map<String, List<Photo>> grouped = {};

      // Load persistent location cache.
      final persistentCache =
          await _locationCacheService.loadCache();

      for (final entry in persistentCache.entries) {
        final value = entry.value;

        if (value == null) {
          _locationCache[entry.key] = null;
          continue;
        }

        if (value is Map) {
          final latitude =
              (value['latitude'] as num?)?.toDouble();

          final longitude =
              (value['longitude'] as num?)?.toDouble();

          if (latitude != null && longitude != null) {
            _locationCache[entry.key] = (
              latitude: latitude,
              longitude: longitude,
            );
          }
        }
      }

      const int batchSize = 5;

      for (int start = 0;
          start < gallery.length;
          start += batchSize) {
        final end = (start + batchSize > gallery.length)
            ? gallery.length
            : start + batchSize;

        final batch = gallery.sublist(start, end);

        final results = await Future.wait(
          batch.map((photo) async {
            final asset = photo.asset;

            if (asset == null) {
              return null;
            }

            final assetId = asset.id;

            // Use cached location if we already read this photo.
            if (_locationCache.containsKey(assetId)) {
              final cached = _locationCache[assetId];

              if (cached == null) {
                return null;
              }

              return (
                photo: photo,
                latitude: cached.latitude,
                longitude: cached.longitude,
              );
            }

            // First time seeing this photo: read GPS metadata.
            final location = await asset.latlngAsync();

            if (location == null) {
              _locationCache[assetId] = null;
              return null;
            }

            final cachedLocation = (
              latitude: location.latitude,
              longitude: location.longitude,
            );

            _locationCache[assetId] = cachedLocation;
            await _locationCacheService.saveCache(
              _locationCache.map(
                (key, value) => MapEntry(
                  key,
                  value == null
                      ? null
                      : {
                          'latitude': value.latitude,
                          'longitude': value.longitude,
                        },
                ),
              ),
            );

            return (
              photo: photo,
              latitude: cachedLocation.latitude,
              longitude: cachedLocation.longitude,
            );
          }),
        );

        for (final result in results) {
          if (result == null) {
            continue;
          }

          final latitude =
              result.latitude.toStringAsFixed(3);

          final longitude =
              result.longitude.toStringAsFixed(3);

          final key = '$latitude,$longitude';

          grouped
              .putIfAbsent(key, () => [])
              .add(result.photo);
        }

        state = state.copyWith(
          locationProgress: end,
        );

        debugPrint(
          'LOCATION: processed $end/${gallery.length}',
        );
      }


      final Map<String, List<Photo>> cityGroups = {};

      final Map<String, String> cityKeys = {};

      for (final entry in grouped.entries) {
        final photos = entry.value;

        final parts = entry.key.split(',');

        if (parts.length != 2) {
          continue;
        }

        final latitude = double.tryParse(parts[0]);
        final longitude = double.tryParse(parts[1]);

        if (latitude == null || longitude == null) {
          continue;
        }

        String locationName = entry.key;

        try {
          final placemarks =
              await _geocoding.placemarkFromCoordinates(
            latitude,
            longitude,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;

            locationName =
                place.subAdministrativeArea?.trim().isNotEmpty == true
                    ? place.subAdministrativeArea!.trim()
                    : place.administrativeArea?.trim().isNotEmpty == true
                        ? place.administrativeArea!.trim()
                        : place.locality?.trim().isNotEmpty == true
                            ? place.locality!.trim()
                            : entry.key;
          }
        } catch (_) {
          // Keep coordinates if reverse geocoding fails.
        }

        // Normalize the name so "Kota Bandung" and
        // "Bandung" can be treated as the same city.
        final cityKey = locationName
            .toLowerCase()
            .trim();

        cityGroups.putIfAbsent(cityKey, () => []).addAll(photos);

        cityKeys[cityKey] = locationName;
      }
      await _locationCacheService.saveCache(
        _locationCache.map(
          (key, value) => MapEntry(
            key,
            value == null
                ? null
                : {
                    'latitude': value.latitude,
                    'longitude': value.longitude,
                  },
          ),
        ),
      );
      final locationGroupsResult = cityGroups.entries.map((entry) {
        final photos = entry.value;
        final locationName = cityKeys[entry.key] ?? entry.key;

        return LocationGroup(
          id: 'location-${entry.key}',
          location: locationName,
          date: photos.first.date,
          count: photos.length,
          coverUrl: photos.first.url,
          photos: photos,
        );
      }).toList();

      state = state.copyWith(
        screen: AppScreen.reviewLocation,
        locationGroups: locationGroupsResult,
      );

      return;
    }

    final List<Photo>? gallery = _galleryPhotos;

    final bool useGallery =
        gallery != null && gallery.isNotEmpty;

    final List<Photo> videoPhotos = useGallery
        ? gallery
            .where((photo) => photo.asset?.type == AssetType.video)
            .where(
              (photo) => !_hiddenPhotoIds.contains(photo.id),
            )
            .toList()
        : bandungPhotos;
    final List<Photo> surpriseSelection = useGallery
        ? (List<Photo>.from(gallery)
          ..removeWhere(
            (photo) => _hiddenPhotoIds.contains(photo.id),
          )
          ..shuffle())
            .take(30)
            .toList()
        : surprisePhotos;

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
        subtitle: '${_screenshotPhotos.length} found',
        photos: _screenshotPhotos,
        total: _screenshotPhotos.length,
      ),

      ReviewMode.largeVideos: SwipeContext(
        mode: mode,
        title: 'Review Videos',
        subtitle: '${videoPhotos.length} videos',
        photos: videoPhotos,
        total: videoPhotos.length,
      ),

      ReviewMode.surprise: SwipeContext(
        mode: mode,
        title: 'Surprise Me',
        subtitle: '${surpriseSelection.length} random photos',
        photos: surpriseSelection,
        total: surpriseSelection.length,
      ),
    };

    _enterSwipe(configs[mode]!);
  }

  void startDateGroup(DateGroup g) {
    final photos = g.photos
        .where((photo) => !_hiddenPhotoIds.contains(photo.id))
        .toList();

    _enterSwipe(
      SwipeContext(
        mode: ReviewMode.date,
        title: g.month,
        subtitle: g.location,
        photos: photos,
        total: photos.length,
      ),
    );
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
    final existingIds =
        _favoritePhotos.map((photo) => photo.id).toSet();

    for (final photo in result.favoritePhotos) {
      if (!existingIds.contains(photo.id)) {
        _favoritePhotos.add(photo);
      }
    }

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

  void deleteSelected(List indexes) {
    final queue = [...state.deleteQueue];

    for (final i in indexes) {
      if (i >= 0 && i < queue.length) {
        final photo = queue[i];

        _hiddenPhotoIds.add(photo.id);
      }
    }

    indexes.sort((a, b) => b.compareTo(a));

    for (final i in indexes) {
      if (i >= 0 && i < queue.length) {
        queue.removeAt(i);
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