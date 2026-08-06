import 'package:photo_manager/photo_manager.dart';

/// Thin wrapper around `photo_manager` responsible only for talking to the
/// device's native gallery: requesting permission, listing albums, and
/// fetching the [AssetEntity] list for a given album.
///
/// This service does not touch UI, models, or app state — it simply
/// returns raw `photo_manager` data for callers to use later.
class GalleryService {
  /// Requests permission to access the device's photo gallery.
  ///
  /// Returns `true` if permission was granted (fully or with limited
  /// access), `false` otherwise.
  Future<bool> requestPermission() async {
    final PermissionState state =
        await PhotoManager.requestPermissionExtend();
    return state.isAuth || state.hasAccess;
  }

  /// Fetches the list of available albums (asset paths) on the device.
  ///
  /// [type] filters by media type (defaults to images and videos).
  /// [createdAfter], if provided, restricts results at the native query
  /// level (MediaStore selection on Android, NSPredicate on iOS) to
  /// assets whose `createDateTime` is on or after that date — this is
  /// applied by the OS/photo library itself, not by fetching everything
  /// and filtering in Dart.
  /// Returns an empty list if permission has not been granted.
  Future<List<AssetPathEntity>> getAlbums({
    RequestType type = RequestType.common,
    DateTime? createdAfter,
  }) async {
    final bool hasPermission = await requestPermission();
    if (!hasPermission) return [];

    final FilterOptionGroup? filterOption = createdAfter == null
        ? null
        : FilterOptionGroup(
            createTimeCond: DateTimeCond(
              min: createdAfter,
              max: DateTime.now(),
            ),
          );

    return PhotoManager.getAssetPathList(
      type: type,
      onlyAll: false,
      filterOption: filterOption,
    );
  }

  /// Fetches every [AssetEntity] belonging to a given [album].
  ///
  /// Uses `getAssetListRange` to pull the full (already-filtered) set in
  /// one call. This is safe/efficient here specifically because [album]
  /// was already obtained via [getAlbums] with a date filter applied at
  /// the native query level — so the count fetched here is bounded to
  /// that filtered window, not the device's entire library.
  Future<List<AssetEntity>> getAssetsFromAlbum(AssetPathEntity album) async {
    final int count = await album.assetCountAsync;
    if (count == 0) return [];
    return album.getAssetListRange(start: 0, end: count);
  }
}