/// Core data models for Gallery Cleaner.

import 'package:photo_manager/photo_manager.dart';

/// Which app screen is currently visible.
enum AppScreen {
  splash,
  gallery,
  reviewMenu,
  reviewDate,
  reviewLocation,
  swipe,
  finished,
  deleteQueue,
  settings,
}

/// Bottom navigation tabs.
enum TabName { gallery, review, settings }

/// The action taken on a photo during a swipe review.
enum PhotoAction { keep, delete, later, favorite }

/// Which "mode" a review session was started from.
enum ReviewMode {
  date,
  location,
  duplicates,
  screenshots,
  largeVideos,
  surprise,
}

/// A single photo with its metadata (mirrors the EXIF-style panel in the
/// original design).
class Photo {
  final String id;
  final String url;
  final String date;
  final String location;
  final String size;
  final String month;
  final String? camera;
  final String? lens;
  final String? aperture;
  final String? shutter;
  final String? iso;
  final String? resolution;
  final AssetEntity? asset;

  const Photo({
    required this.id,
    required this.url,
    required this.date,
    required this.location,
    required this.size,
    required this.month,
    this.camera,
    this.lens,
    this.aperture,
    this.shutter,
    this.iso,
    this.resolution,
    this.asset,
  });

  /// Splits "Oct 14, 2023 · 7:22 AM" into ("Oct 14, 2023", "7:22 AM").
  List<String> get dateParts => date.split(' · ');
}

/// A lightweight photo reference used only for grid thumbnails (no
/// metadata needed there).
class ThumbPhoto {
  final String id;
  final String url;
  const ThumbPhoto({required this.id, required this.url});
}

/// A month section shown on the main Gallery grid.
class GalleryGroup {
  final String month;
  final List<ThumbPhoto> photos;
  const GalleryGroup({required this.month, required this.photos});
}

/// A group of photos for the "Review by Date" screen.
class DateGroup {
  final String id;
  final String month;
  final String location;
  final int count;
  final String coverUrl;
  final List<Photo> photos;

  const DateGroup({
    required this.id,
    required this.month,
    required this.location,
    required this.count,
    required this.coverUrl,
    required this.photos,
  });
}

/// A group of photos for the "Review by Location" screen.
class LocationGroup {
  final String id;
  final String location;
  final String date;
  final int count;
  final String coverUrl;
  final List<Photo> photos;

  const LocationGroup({
    required this.id,
    required this.location,
    required this.date,
    required this.count,
    required this.coverUrl,
    required this.photos,
  });
}

/// Everything the Swipe screen needs to run a review session.
class SwipeContext {
  final ReviewMode mode;
  final String title;
  final String subtitle;
  final List<Photo> photos;
  final int total;

  const SwipeContext({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.photos,
    required this.total,
  });
}

/// Static config (label / color / icon) per [PhotoAction], shared by the
/// swipe labels and the Finished-screen summary rows.
class ActionConfig {
  final String label;
  final int colorValue;
  final int bgColorValue;

  const ActionConfig({
    required this.label,
    required this.colorValue,
    required this.bgColorValue,
  });
}

class ReviewResult {
  final Map<PhotoAction, int> counts;
  final List<Photo> deletePhotos;
  final List<Photo> keptPhotos;
  final List<Photo> laterPhotos;
  final List<Photo> favoritePhotos;

  const ReviewResult({
    required this.counts,
    required this.deletePhotos,
    required this.keptPhotos,
    required this.laterPhotos,
    required this.favoritePhotos,
  });
}