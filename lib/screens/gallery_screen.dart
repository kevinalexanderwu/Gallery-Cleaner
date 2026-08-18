import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/net_image.dart';
import 'photo_preview_screen.dart';
import 'favorites_screen.dart';

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
          if (useRealPhotos)
            for (final entry in _groupByMonth(filteredRealPhotos).entries)
              _MonthSectionPhotos(
                month: entry.key,
                photos: entry.value,
                onReview: onReview,
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
  static Map<String, List<Photo>> _groupByMonth(List<Photo> photos) {
    final Map<String, List<Photo>> grouped = {};
    for (final p in photos) {
      grouped.putIfAbsent(p.month, () => []).add(p);
    }
    return grouped;
  }
}

/// Same visual structure as [_MonthSection], but sourced from a real
/// [List<Photo>] (with optional `AssetEntity`) instead of a mock
/// [GalleryGroup] of [ThumbPhoto].
class _MonthSectionPhotos extends StatelessWidget {
  final String month;
  final List<Photo> photos;
  final VoidCallback onReview;

  const _MonthSectionPhotos({
    required this.month,
    required this.photos,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: Text(
            month,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
          ),
        ),
        Container(
          color: AppColors.grey150,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  child: Hero(
                    tag: p.id,
                    child: SquareThumb(
                      url: p.url,
                      asset: p.asset,
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