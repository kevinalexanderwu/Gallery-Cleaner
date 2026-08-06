import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

/// A `BoxFit.cover` image with a soft grey placeholder while it loads and
/// a graceful fallback if it fails — used everywhere the design shows a
/// photo thumbnail or cover.
///
/// Renders from a real gallery [asset] via `AssetEntityImage` when one is
/// provided; otherwise falls back to the original `Image.network(url)`
/// behavior so existing mock-data call sites keep working unchanged.
class NetImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final AssetEntity? asset;
  final bool original;

  const NetImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.asset,
    this.original = false,
  });

  @override
  Widget build(BuildContext context) {
    final AssetEntity? entity = asset;
    if (entity != null) {
      return AssetEntityImage(
        entity,
        isOriginal: original,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: const Color(0xFFF0F0F0));
        },
        errorBuilder: (context, error, stack) => Container(
          color: const Color(0xFFEBEBEB),
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFFC4C4C4)),
        ),
      );
    }

    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(color: const Color(0xFFF0F0F0));
      },
      errorBuilder: (context, error, stack) => Container(
        color: const Color(0xFFEBEBEB),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFFC4C4C4)),
      ),
    );
  }
}

/// A square (1:1) thumbnail tile, used in the Gallery grid.
class SquareThumb extends StatelessWidget {
  final String url;
  final AssetEntity? asset;
  const SquareThumb({super.key, required this.url, this.asset});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: const Color(0xFFF0F0F0),
        child: NetImage(url: url, asset: asset),
      ),
    );
  }
}