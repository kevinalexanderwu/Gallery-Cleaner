import 'dart:async';

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

  const GalleryScreen({
    super.key,
    required this.onReview,
  });

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
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
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
                            final controller = ref.read(
                              appControllerProvider.notifier,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FavoritesScreen(
                                  photos:
                                      controller.favoritePhotos,
                                ),
                              ),
                            );
                          },
                        ),
                        OutlinedButton(
                          onPressed: onReview,
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                AppColors.grey50,
                            foregroundColor:
                                AppColors.ink,
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
            for (final entry
                in _groupByDate(filteredRealPhotos).entries)
              _DateSectionPhotos(
                date: entry.key,
                photos: entry.value,
                onFavorite:
                    controller.toggleFavorite,
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

  static Map<String, List<Photo>> _groupByDate(
    List<Photo> photos,
  ) {
    final Map<String, List<Photo>> grouped = {};

    for (final p in photos) {
      final dateOnly =
          p.date.split(',').first.trim();

      grouped
          .putIfAbsent(dateOnly, () => [])
          .add(p);
    }

    return grouped;
  }
}


// ============================================================
// DATE SECTION PHOTOS
// ============================================================

class _DateSectionPhotos
    extends ConsumerStatefulWidget {
  final String date;
  final List<Photo> photos;
  final void Function(Photo photo)? onFavorite;

  const _DateSectionPhotos({
    required this.date,
    required this.photos,
    this.onFavorite,
  });

  @override
  ConsumerState<_DateSectionPhotos>
      createState() =>
          _DateSectionPhotosState();
}


class _DateSectionPhotosState
    extends ConsumerState<_DateSectionPhotos> {

  Timer? _tapTimer;
  DateTime? _lastTapTime;
  String? _lastTapPhotoId;


  // ----------------------------------------------------------
  // FORMAT DATE
  // ----------------------------------------------------------

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

    final difference =
        today.difference(photoDate).inDays;

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


  // ----------------------------------------------------------
  // SINGLE TAP
  //
  // We wait 300ms first.
  //
  // Why?
  // Because if another tap arrives within those 300ms,
  // Flutter treats it as a double tap and we cancel the
  // single-tap action.
  // ----------------------------------------------------------

  void _handleSingleTap(
    BuildContext context,
    int index,
  ) {
    _tapTimer?.cancel();

    _tapTimer = Timer(
      const Duration(milliseconds: 300),
      () {
        if (!mounted) {
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PhotoPreviewScreen(
              photos: widget.photos,
              initialIndex: index,
            ),
          ),
        );
      },
    );
  }


  // ----------------------------------------------------------
  // DOUBLE TAP
  // ----------------------------------------------------------

  void _handleDoubleTap(Photo photo) {
      _tapTimer?.cancel();

      _tapTimer = null;

      debugPrint(
        'DOUBLE TAP: ${photo.id}',
      );

      widget.onFavorite?.call(photo);
    }

    void _showPhotoOptions(
    BuildContext context,
    Photo photo,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Photo Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                ListTile(
                  leading: const Icon(
                    Icons.favorite_border,
                  ),
                  title: const Text(
                    'Add to Favorites',
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    widget.onFavorite?.call(photo);
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.share_outlined,
                  ),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(context);

                    // Share akan kita sambungkan
                    // setelah menu ini berhasil.
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                  ),
                  title: const Text('Details'),
                  onTap: () {
                    Navigator.pop(context);

                    // Details akan kita sambungkan
                    // setelah menu ini berhasil.
                  },
                ),

                const SizedBox(height: 4),

                ListTile(
                  leading: const Icon(
                    Icons.close,
                  ),
                  title: const Text('Cancel'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  @override
  void dispose() {
    _tapTimer?.cancel();

    _lastTapTime = null;
    _lastTapPhotoId = null;

    super.dispose();
  }


  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {

    final favoritePhotos =
        ref.watch(
          appControllerProvider,
        ).favoritePhotos;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        // ----------------------------------------------------
        // DATE TITLE
        // ----------------------------------------------------

        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            6,
          ),

          child: Text(
            _formatDate(
              widget.date,
            ),

            style: const TextStyle(
              fontSize: 13,
              fontWeight:
                  FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
        ),


        // ----------------------------------------------------
        // PHOTO GRID
        // ----------------------------------------------------

        GridView.builder(
          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          padding: EdgeInsets.zero,

          itemCount:
              widget.photos.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,

            mainAxisSpacing: 1.5,

            crossAxisSpacing: 1.5,
          ),

          itemBuilder: (
            context,
            i,
          ) {

            final p =
                widget.photos[i];


            // ------------------------------------------------
            // CHECK FAVORITE
            // ------------------------------------------------

            final isFavorite =
                favoritePhotos.any(
              (photo) =>
                  photo.id == p.id,
            );


            // ------------------------------------------------
            // PHOTO TILE
            // ------------------------------------------------

            return GestureDetector(
              behavior: HitTestBehavior.opaque,

              onTap: () {
                final now = DateTime.now();

                if (_lastTapTime != null &&
                    now.difference(_lastTapTime!) <
                        const Duration(milliseconds: 350) &&
                    _lastTapPhotoId == p.id) {
                  
                  // DOUBLE TAP
                  _lastTapTime = null;
                  _lastTapPhotoId = null;

                  debugPrint(
                    'DOUBLE TAP MANUAL: ${p.id}',
                  );

                  widget.onFavorite?.call(p);

                  return;
                }

                // FIRST TAP
                _lastTapTime = now;
                _lastTapPhotoId = p.id;

                debugPrint(
                  'SINGLE TAP WAITING: ${p.id}',
                );

                _tapTimer?.cancel();

                _tapTimer = Timer(
                  const Duration(milliseconds: 350),
                  () {
                    if (!mounted) return;

                    // SINGLE TAP → buka preview
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoPreviewScreen(
                          photos: widget.photos,
                          initialIndex: i,
                        ),
                      ),
                    );

                    _lastTapTime = null;
                    _lastTapPhotoId = null;
                  },
                );
              },

              onLongPress: () {
                _showPhotoOptions(
                  context,
                  p,
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

                  if (isFavorite)
                    const Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
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