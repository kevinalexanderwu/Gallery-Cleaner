import 'package:photo_manager/photo_manager.dart';

import '../models/models.dart';

/// Converts a `photo_manager` [AssetEntity] into the app's existing
/// [Photo] model, so real gallery assets can eventually be dropped into
/// screens that were built against [Photo].
///
/// This adapter is intentionally standalone: it is not wired into any
/// screen, controller, or provider yet. It only knows how to build a
/// [Photo] from an [AssetEntity], filling in any field that isn't
/// cheaply/synchronously available from `photo_manager` with a safe
/// placeholder default.
class PhotoMapper {
  /// Placeholder used for [Photo.url] until a real image-loading strategy
  /// (e.g. rendering from `AssetEntity` thumbnail/file bytes) is wired up.
  static const String _placeholderUrl =
      'https://via.placeholder.com/600x740?text=Photo';

  static const String _unknownLocation = 'Unknown location';
  static const String _unknownSize = 'Unknown size';
  static const String _unknownDate = 'Unknown date';
  static const String _unknownMonth = 'Unknown month';

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _fullMonthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// Builds a [Photo] from the given [asset].
  ///
  /// Only synchronously/cheaply available `AssetEntity` fields are used
  /// (id, creation time, width/height). Anything not available without
  /// extra I/O (e.g. GPS-derived location name, file size on disk,
  /// camera/lens EXIF data) is filled with a safe default so the mapping
  /// never throws and never blocks.
  static Photo fromAssetEntity(AssetEntity asset) {
    final DateTime? createdAt = asset.createDateTime;
    final String date = _formatDate(createdAt);
    final String month = _formatMonth(createdAt);
    final String resolution = (asset.width > 0 && asset.height > 0)
        ? '${asset.width} × ${asset.height}'
        : 'Unknown resolution';

    return Photo(
      id: asset.id,
      url: _placeholderUrl,
      date: date,
      location: _unknownLocation,
      size: _unknownSize,
      month: month,
      camera: null,
      lens: null,
      aperture: null,
      shutter: null,
      iso: null,
      resolution: resolution,
      asset: asset,
    );
  }

  /// Convenience helper to map a whole list of assets at once.
  static List<Photo> fromAssetEntities(List<AssetEntity> assets) {
    return assets.map(fromAssetEntity).toList();
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return _unknownDate;
    final String monthName = _monthNames[dt.month - 1];
    final int hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final String period = dt.hour >= 12 ? 'PM' : 'AM';
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$monthName ${dt.day}, ${dt.year} · $hour12:$minute $period';
  }

  static String _formatMonth(DateTime? dt) {
    if (dt == null) return _unknownMonth;
    return '${_fullMonthNames[dt.month - 1]} ${dt.year}';
  }
  static Future<Photo> fromAssetEntityWithLocation(
    AssetEntity asset,
  ) async {
    final DateTime? createdAt = asset.createDateTime;

    final location = await asset.latlngAsync();

    String locationText = _unknownLocation;

    if (location != null) {
      locationText =
          '${location.latitude},${location.longitude}';
    }

    final String resolution =
        (asset.width > 0 && asset.height > 0)
            ? '${asset.width} × ${asset.height}'
            : 'Unknown resolution';

    return Photo(
      id: asset.id,
      url: _placeholderUrl,
      date: _formatDate(createdAt),
      location: locationText,
      size: _unknownSize,
      month: _formatMonth(createdAt),
      camera: null,
      lens: null,
      aperture: null,
      shutter: null,
      iso: null,
      resolution: resolution,
      asset: asset,
    );
  }

  static Future<List<Photo>> fromAssetEntitiesWithLocation(
    List<AssetEntity> assets,
  ) async {
    final List<Photo> photos = [];

    for (final asset in assets) {
      photos.add(
        await fromAssetEntityWithLocation(asset),
      );
    }

    return photos;
  }
}