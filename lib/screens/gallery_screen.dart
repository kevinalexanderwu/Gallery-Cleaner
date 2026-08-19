import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/net_image.dart';
import 'photo_preview_screen.dart';
import 'favorites_screen.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryScreen extends ConsumerWidget {
  final VoidCallback onReview;
  const GalleryScreen({super.key, required this.onReview});
  String _photoKey(String url) {
    return url.split('?').first.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);

    final List<Photo>? realPhotos = controller.galleryPhotos;

    final hiddenIds = controller.hiddenPhotoIds;

    final filteredRealPhotos = realPhotos
            ?.where((photo) => !hiddenIds.contains(photo.id))
            .toList() ??
        <Photo>[];

    final bool useRealPhotos = filteredRealPhotos.isNotEmpty;
    List<GalleryGroup> filterDummyGroups(
      Set<String> hiddenUrls,
    ) {
      return galleryGroups
          .map(
            (group) {
              final photos = group.photos.where((photo) {
                final baseUrl = photo.url.split('?').first;
                return !hiddenUrls.contains(baseUrl);
              }).toList();

              return GalleryGroup(
                month: group.month,
                photos: photos,
              );
            },
          )
          .where((group) => group.photos.isNotEmpty)
          .toList();
    }

    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            final controller =
                                ref.read(appControllerProvider.notifier);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FavoritesScreen(
                                  photos: controller.favoritePhotos,
                                ),
                              ),
                            );
                          },
                        ),

                        OutlinedButton(
                          onPressed: onReview,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.grey50,
                            foregroundColor: AppColors.ink,
                            side: BorderSide.none,
                          ),
                          child: const Text('Review'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  useRealPhotos
                      ? '${filteredRealPhotos.length} photos · Last 3 Months'
                      : '1,287 photos · 48.3 GB',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          if (state.galleryLoading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (useRealPhotos)
            for (final entry in _groupByDate(filteredRealPhotos).entries)
              _DateSectionPhotos(
                date: entry.key,
                photos: entry.value,
              )
          else
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(
                child: Text(
                  'No photos found',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey500,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Groups [photos] by their `month` field, preserving first-seen order
  /// so the resulting sections read the same way `galleryGroups` does.
  static Map<String, List<Photo>> _groupByDate(
    List<Photo> photos,
  ) {
    final Map<String, List<Photo>> grouped = {};

    for (final p in photos) {
      final dateOnly = p.date.split(',').first.trim();

      grouped
          .putIfAbsent(dateOnly, () => [])
          .add(p);
    }

    return grouped;
  }
}

/// Same visual structure as [_MonthSection], but sourced from a real
/// [List<Photo>] (with optional `AssetEntity`) instead of a mock
/// [GalleryGroup] of [ThumbPhoto].
class _DateSectionPhotos extends StatelessWidget {
  final String date;
  final List<Photo> photos;

  const _DateSectionPhotos({
    required this.date,
    required this.photos,
  });

  String _formatDate(String date) {
    final parsed = DateTime.tryParse(date);

    if (parsed == null) {
      return date;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final photoDate = DateTime(
      parsed.year,
      parsed.month,
      parsed.day,
    );

    final difference = today.difference(photoDate).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[parsed.month - 1]} '
        '${parsed.day}, ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: photos.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1.5,
              crossAxisSpacing: 1.5,
            ),
            itemBuilder: (context, i) {
              final p = photos[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoPreviewScreen(
                        photos: photos,
                        initialIndex: i,
                      ),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SquareThumb(
                      url: p.url,
                      asset: p.asset,
                    ),

                    if (p.asset?.type == AssetType.video)
                      const Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _MonthSection extends StatelessWidget {
  final GalleryGroup group;
  const _MonthSection({required this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: Text(
            group.month,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
          ),
        ),
        Container(
          color: AppColors.grey150,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: group.photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1.5,
              crossAxisSpacing: 1.5,
            ),
            itemBuilder: (context, i) {
              final p = group.photos[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoPreviewScreen(
                        photos: group.photos
                            .map(
                              (thumb) => Photo(
                                id: thumb.id,
                                url: thumb.url,
                                asset: null,
                                month: group.month,
                                date: group.month,
                                location: 'Demo',
                                size: '0',
                              ),
                            )
                            .toList(),
                        initialIndex: i,
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: p.id,
                  child: SquareThumb(
                    url: p.url,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}