import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class MediaPreview extends StatefulWidget {
  final AssetEntity? asset;
  final String url;
  final BoxFit fit;

  const MediaPreview({
    super.key,
    required this.asset,
    required this.url,
    this.fit = BoxFit.contain,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  VideoPlayerController? _controller;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    if (widget.asset?.type == AssetType.video) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final asset = widget.asset;

    if (asset == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final file = await asset.file;

      if (file == null) {
        throw Exception('Video file not available');
      }

      final controller = VideoPlayerController.file(file);

      await controller.initialize();

      controller.setLooping(true);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isLoading = false;
      });

      await controller.play();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;

    if (controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;

    // VIDEO
    if (asset?.type == AssetType.video) {
      if (_isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (_hasError || _controller == null) {
        return const Center(
          child: Icon(
            Icons.videocam_off_outlined,
            size: 40,
            color: Colors.white54,
          ),
        );
      }

      final controller = _controller!;

      return GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),

            if (!controller.value.isPlaying)
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),

            // Video progress slider
            Positioned(
              left: 16,
              right: 16,
              bottom: 35,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white24,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // IMAGE
    if (asset != null) {
      return AssetEntityImage(
        asset,
        isOriginal: false,
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // FALLBACK FOR MOCK DATA
    return Image.network(
      widget.url,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
    );
  }
}