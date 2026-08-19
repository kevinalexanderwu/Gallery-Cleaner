import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../state/app_controller.dart';
import '../widgets/media_preview.dart';

class PhotoPreviewScreen extends ConsumerStatefulWidget {
  final List<Photo> photos;
  final int initialIndex;

  const PhotoPreviewScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  ConsumerState<PhotoPreviewScreen> createState() =>
      _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState
    extends ConsumerState<PhotoPreviewScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  // Used only for the visual heart feedback.
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFavorite(Photo photo) {
    ref
        .read(appControllerProvider.notifier)
        .toggleFavorite(photo);

    setState(() {
      _showHeart = true;
    });

    Future.delayed(
      const Duration(milliseconds: 700),
      () {
        if (!mounted) return;

        setState(() {
          _showHeart = false;
        });
      },
    );
  }

  Future<void> _sharePhoto(Photo photo) async {
    try {
      if (photo.asset != null) {
        final file = await photo.asset!.file;

        if (file == null) {
          return;
        }

        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile(file.path),
            ],
          ),
        );

        return;
      }

      if (photo.url.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(
            text: photo.url,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to share this media',
          ),
        ),
      );
    }
  }

  Future<void> _showPhotoDetails(
    BuildContext context,
    Photo photo,
  ) async {
    final asset = photo.asset;

    if (asset == null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (context) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No additional details are available for this media.',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      );

      return;
    }

    final file = await asset.file;

    if (!mounted) return;

    final fileSize = file != null
        ? await file.length()
        : null;

    if (!mounted) return;

    String formatFileSize(int? bytes) {
      if (bytes == null) {
        return 'Unknown';
      }

      if (bytes < 1024) {
        return '$bytes B';
      }

      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }

      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }

      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }

    String formatDuration(Duration duration) {
      final hours = duration.inHours;
      final minutes =
          duration.inMinutes.remainder(60);
      final seconds =
          duration.inSeconds.remainder(60);

      if (hours > 0) {
        return '${hours}h ${minutes}m ${seconds}s';
      }

      if (minutes > 0) {
        return '${minutes}m ${seconds}s';
      }

      return '${seconds}s';
    }

    final isVideo =
        asset.type == AssetType.video;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
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
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                _DetailRow(
                  label: 'Type',
                  value:
                      isVideo ? 'Video' : 'Photo',
                ),

                _DetailRow(
                  label: 'Resolution',
                  value:
                      '${asset.width} × ${asset.height}',
                ),

                _DetailRow(
                  label: 'File size',
                  value:
                      formatFileSize(fileSize),
                ),

                _DetailRow(
                  label: 'Date',
                  value: photo.date,
                ),

                if (isVideo)
                  _DetailRow(
                    label: 'Duration',
                    value: formatDuration(
                      asset.videoDuration,
                    ),
                  ),

                _DetailRow(
                  label: 'Location',
                  value: asset.latLng != null
                      ? '${asset.latLng!.latitude.toStringAsFixed(6)}, '
                          '${asset.latLng!.longitude.toStringAsFixed(6)}'
                      : 'Not available',
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

                  _toggleFavorite(photo);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.share_outlined,
                ),
                title: const Text('Share'),
                onTap: () async {
                  Navigator.pop(context);

                  await _sharePhoto(photo);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.info_outline,
                ),
                title: const Text('Details'),
                onTap: () {
                  Navigator.pop(context);

                  _showPhotoDetails(
                    context,
                    photo,
                  );
                },
              ),

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
        ),
      ),

      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,

        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _showHeart = false;
          });
        },

        itemBuilder: (context, index) {
          final photo = widget.photos[index];

          final isVideo =
              photo.asset?.type == AssetType.video;

          // --------------------------------------------------
          // VIDEO
          // --------------------------------------------------

          if (isVideo) {
            return Center(
              child: Hero(
                tag: photo.id,
                child: MediaPreview(
                  asset: photo.asset,
                  url: photo.url,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }

          // --------------------------------------------------
          // PHOTO
          // --------------------------------------------------

          return Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,

              panEnabled: true,
              scaleEnabled: true,

              boundaryMargin:
                  const EdgeInsets.all(100),

              clipBehavior: Clip.none,

              child: GestureDetector(
                behavior: HitTestBehavior.opaque,

                onDoubleTap: () {
                  _toggleFavorite(photo);
                },
                onLongPress: () {
                  _showPhotoOptions(
                    context,
                    photo,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,

                  children: [
                    Hero(
                      tag: photo.id,

                      child: MediaPreview(
                        asset: photo.asset,
                        url: photo.url,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // ----------------------------------------
                    // HEART FEEDBACK
                    // ----------------------------------------

                    if (_showHeart &&
                        index == _currentIndex)
                      const IgnorePointer(
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 110,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}