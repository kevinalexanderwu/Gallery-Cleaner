import '../models/models.dart';

// ─── Gallery grid (month thumbnails) ───────────────────────────────────────

final List<GalleryGroup> galleryGroups = [
  GalleryGroup(month: 'December 2024', photos: const [
    ThumbPhoto(id: 'g1', url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g2', url: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g3', url: 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g4', url: 'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g5', url: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g6', url: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?w=300&h=300&fit=crop&auto=format'),
  ]),
  GalleryGroup(month: 'November 2024', photos: const [
    ThumbPhoto(id: 'g7', url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g8', url: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g9', url: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g10', url: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g11', url: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g12', url: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=300&h=300&fit=crop&auto=format'),
  ]),
  GalleryGroup(month: 'October 2024', photos: const [
    ThumbPhoto(id: 'g13', url: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g14', url: 'https://images.unsplash.com/photo-1518791841217-8f162f1912da?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g15', url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g16', url: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g17', url: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=300&h=300&fit=crop&auto=format'),
    ThumbPhoto(id: 'g18', url: 'https://images.unsplash.com/photo-1485688804469-a857de4dbddb?w=300&h=300&fit=crop&auto=format'),
  ]),
];

// ─── Full photo sets (with metadata) used by review sessions ──────────────

final List<Photo> baliPhotos = [
  const Photo(id: 'b1', url: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600&h=740&fit=crop&auto=format', date: 'Oct 14, 2023 · 7:22 AM', location: 'Bali, Indonesia', size: '5.3 MB', month: 'October 2023', camera: 'iPhone 15 Pro Max', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/240s', iso: 'ISO 50', resolution: '4032 × 3024'),
  const Photo(id: 'b2', url: 'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=600&h=740&fit=crop&auto=format', date: 'Oct 11, 2023 · 5:48 PM', location: 'Seminyak, Bali', size: '4.7 MB', month: 'October 2023', camera: 'iPhone 15 Pro Max', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/500s', iso: 'ISO 32', resolution: '4032 × 3024'),
  const Photo(id: 'b3', url: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?w=600&h=740&fit=crop&auto=format', date: 'Oct 9, 2023 · 10:15 AM', location: 'Ubud, Bali', size: '3.2 MB', month: 'October 2023', camera: 'iPhone 15 Pro Max', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/1000s', iso: 'ISO 50', resolution: '4032 × 3024'),
  const Photo(id: 'b4', url: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=600&h=740&fit=crop&auto=format', date: 'Oct 7, 2023 · 8:30 AM', location: 'Tegallalang, Bali', size: '4.9 MB', month: 'October 2023', camera: 'iPhone 15 Pro Max', lens: 'Main: 24mm', aperture: 'f/2.2', shutter: '1/120s', iso: 'ISO 80', resolution: '4032 × 3024'),
  const Photo(id: 'b5', url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=600&h=740&fit=crop&auto=format', date: 'Oct 5, 2023 · 6:10 AM', location: 'Mount Batur, Bali', size: '6.1 MB', month: 'October 2023', camera: 'iPhone 15 Pro Max', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/60s', iso: 'ISO 125', resolution: '4032 × 3024'),
  const Photo(id: 'b6', url: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=600&h=740&fit=crop&auto=format', date: 'Oct 3, 2023 · 9:55 AM', location: 'Bedugul, Bali', size: '5.0 MB', month: 'October 2023', camera: 'iPhone 15 Pro Max', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/350s', iso: 'ISO 50', resolution: '4032 × 3024'),
  const Photo(id: 'b7', url: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=600&h=740&fit=crop&auto=format', date: 'Oct 1, 2023 · 6:20 AM', location: 'Kintamani, Bali', size: '4.4 MB', month: 'October 2023', camera: 'iPhone 15 Pro Max', lens: 'Main: 24mm', aperture: 'f/2.8', shutter: '1/80s', iso: 'ISO 64', resolution: '4032 × 3024'),
];

final List<Photo> tokyoPhotos = [
  const Photo(id: 't1', url: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600&h=740&fit=crop&auto=format', date: 'Jun 22, 2025 · 8:45 PM', location: 'Shinjuku, Tokyo', size: '4.8 MB', month: 'June 2025', camera: 'Sony A7C II', lens: 'FE 35mm f/1.4', aperture: 'f/1.4', shutter: '1/60s', iso: 'ISO 3200', resolution: '7008 × 4672'),
  const Photo(id: 't2', url: 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=600&h=740&fit=crop&auto=format', date: 'Jun 20, 2025 · 7:30 PM', location: 'Shibuya, Tokyo', size: '3.9 MB', month: 'June 2025', camera: 'Sony A7C II', lens: 'FE 35mm f/1.4', aperture: 'f/2.0', shutter: '1/80s', iso: 'ISO 1600', resolution: '7008 × 4672'),
  const Photo(id: 't3', url: 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=600&h=740&fit=crop&auto=format', date: 'Jun 18, 2025 · 2:15 PM', location: 'Asakusa, Tokyo', size: '5.2 MB', month: 'June 2025', camera: 'Sony A7C II', lens: 'FE 35mm f/1.4', aperture: 'f/5.6', shutter: '1/640s', iso: 'ISO 100', resolution: '7008 × 4672'),
  const Photo(id: 't4', url: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&h=740&fit=crop&auto=format', date: 'Jun 16, 2025 · 1:05 PM', location: 'Tsukiji, Tokyo', size: '2.8 MB', month: 'June 2025', camera: 'Sony A7C II', lens: 'FE 50mm f/1.8', aperture: 'f/2.5', shutter: '1/200s', iso: 'ISO 200', resolution: '7008 × 4672'),
  const Photo(id: 't5', url: 'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=600&h=740&fit=crop&auto=format', date: 'Jun 14, 2025 · 11:20 AM', location: 'Harajuku, Tokyo', size: '3.1 MB', month: 'June 2025', camera: 'Sony A7C II', lens: 'FE 50mm f/1.8', aperture: 'f/2.8', shutter: '1/400s', iso: 'ISO 100', resolution: '7008 × 4672'),
  const Photo(id: 't6', url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&h=740&fit=crop&auto=format', date: 'Jun 12, 2025 · 4:40 PM', location: 'Omotesando, Tokyo', size: '5.7 MB', month: 'June 2025', camera: 'Sony A7C II', lens: 'FE 35mm f/1.4', aperture: 'f/1.8', shutter: '1/125s', iso: 'ISO 400', resolution: '7008 × 4672'),
];

final List<Photo> bandungPhotos = [
  const Photo(id: 'bg1', url: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=600&h=740&fit=crop&auto=format', date: 'Jul 20, 2025 · 9:10 AM', location: 'Bandung, Indonesia', size: '4.2 MB', month: 'July 2025', camera: 'iPhone 15 Pro', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/500s', iso: 'ISO 50', resolution: '4032 × 3024'),
  const Photo(id: 'bg2', url: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600&h=740&fit=crop&auto=format', date: 'Jul 18, 2025 · 7:45 AM', location: 'Lembang, Bandung', size: '3.8 MB', month: 'July 2025', camera: 'iPhone 15 Pro', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/350s', iso: 'ISO 50', resolution: '4032 × 3024'),
  const Photo(id: 'bg3', url: 'https://images.unsplash.com/photo-1485688804469-a857de4dbddb?w=600&h=740&fit=crop&auto=format', date: 'Jul 16, 2025 · 3:30 PM', location: 'Kawah Putih, Bandung', size: '4.5 MB', month: 'July 2025', camera: 'iPhone 15 Pro', lens: 'Ultra Wide: 13mm', aperture: 'f/2.2', shutter: '1/800s', iso: 'ISO 50', resolution: '4032 × 3024'),
  const Photo(id: 'bg4', url: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=600&h=740&fit=crop&auto=format', date: 'Jul 14, 2025 · 2:00 PM', location: 'Dago, Bandung', size: '2.9 MB', month: 'July 2025', camera: 'iPhone 15 Pro', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/200s', iso: 'ISO 64', resolution: '4032 × 3024'),
  const Photo(id: 'bg5', url: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&h=740&fit=crop&auto=format', date: 'Jul 12, 2025 · 10:30 AM', location: 'Braga, Bandung', size: '3.5 MB', month: 'July 2025', camera: 'iPhone 15 Pro', lens: 'Main: 24mm', aperture: 'f/1.78', shutter: '1/1000s', iso: 'ISO 32', resolution: '4032 × 3024'),
];

final List<Photo> surprisePhotos = [
  const Photo(id: 's1', url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600&h=740&fit=crop&auto=format', date: 'Apr 3, 2024 · 2:14 PM', location: 'Amsterdam', size: '5.1 MB', month: 'April 2024', camera: 'Fujifilm X100VI', lens: '23mm f/2', aperture: 'f/4.0', shutter: '1/250s', iso: 'ISO 160', resolution: '6240 × 4160'),
  const Photo(id: 's2', url: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=600&h=740&fit=crop&auto=format', date: 'Feb 14, 2024 · 7:30 PM', location: 'Barcelona', size: '4.0 MB', month: 'February 2024', camera: 'Fujifilm X100VI', lens: '23mm f/2', aperture: 'f/2.0', shutter: '1/60s', iso: 'ISO 800', resolution: '6240 × 4160'),
  const Photo(id: 's3', url: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600&h=740&fit=crop&auto=format', date: 'May 21, 2023 · 5:55 PM', location: 'Paris, France', size: '6.3 MB', month: 'May 2023', camera: 'Fujifilm X100VI', lens: '23mm f/2', aperture: 'f/5.6', shutter: '1/500s', iso: 'ISO 125', resolution: '6240 × 4160'),
  const Photo(id: 's4', url: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=600&h=740&fit=crop&auto=format', date: 'Aug 9, 2023 · 8:40 PM', location: 'New York, USA', size: '5.5 MB', month: 'August 2023', camera: 'Fujifilm X100VI', lens: '23mm f/2', aperture: 'f/2.8', shutter: '1/30s', iso: 'ISO 3200', resolution: '6240 × 4160'),
  const Photo(id: 's5', url: 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=600&h=740&fit=crop&auto=format', date: 'Mar 11, 2025 · 6:25 PM', location: 'Singapore', size: '4.8 MB', month: 'March 2025', camera: 'Fujifilm X100VI', lens: '23mm f/2', aperture: 'f/3.2', shutter: '1/200s', iso: 'ISO 200', resolution: '6240 × 4160'),
  const Photo(id: 's6', url: 'https://images.unsplash.com/photo-1518791841217-8f162f1912da?w=600&h=740&fit=crop&auto=format', date: 'Nov 3, 2024 · 3:15 PM', location: 'Vienna, Austria', size: '3.2 MB', month: 'November 2024', camera: 'Fujifilm X100VI', lens: '23mm f/2', aperture: 'f/2.0', shutter: '1/125s', iso: 'ISO 400', resolution: '6240 × 4160'),
];

// ─── Grouped review data ───────────────────────────────────────────────────

List<Photo> _slice(List<Photo> list, int start, int end) => list.sublist(start, end);
List<Photo> _wrap(List<Photo> a, List<Photo> b) => [...a, ...b];

final List<DateGroup> dateGroups = [
  DateGroup(id: 'dg1', month: 'July 2025', location: 'Bandung', count: 324, coverUrl: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=600&h=340&fit=crop&auto=format', photos: bandungPhotos),
  DateGroup(id: 'dg2', month: 'June 2025', location: 'Tokyo', count: 284, coverUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=600&h=340&fit=crop&auto=format', photos: tokyoPhotos),
  DateGroup(id: 'dg3', month: 'March 2025', location: 'Singapore', count: 156, coverUrl: 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=600&h=340&fit=crop&auto=format', photos: _wrap(_slice(surprisePhotos, 4, 6), _slice(surprisePhotos, 0, 4))),
  DateGroup(id: 'dg4', month: 'October 2023', location: 'Bali', count: 624, coverUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600&h=340&fit=crop&auto=format', photos: baliPhotos),
  DateGroup(id: 'dg5', month: 'August 2023', location: 'New York', count: 198, coverUrl: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=600&h=340&fit=crop&auto=format', photos: _wrap(_slice(surprisePhotos, 3, 6), _slice(surprisePhotos, 0, 3))),
];

final List<LocationGroup> locationGroups = [
  LocationGroup(id: 'loc-bali', location: 'Bali', date: 'October 2023', count: 624, coverUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=700&h=420&fit=crop&auto=format', photos: baliPhotos),
  LocationGroup(id: 'loc-tokyo', location: 'Tokyo', date: 'June 2025', count: 284, coverUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=700&h=420&fit=crop&auto=format', photos: tokyoPhotos),
  LocationGroup(id: 'loc-bandung', location: 'Bandung', date: 'July 2025', count: 324, coverUrl: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=700&h=420&fit=crop&auto=format', photos: bandungPhotos),
  LocationGroup(id: 'loc-singapore', location: 'Singapore', date: 'March 2025', count: 156, coverUrl: 'https://images.unsplash.com/photo-1525625293386-3f8f99389edd?w=700&h=420&fit=crop&auto=format', photos: surprisePhotos),
  LocationGroup(id: 'loc-nyc', location: 'New York', date: 'August 2023', count: 198, coverUrl: 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=700&h=420&fit=crop&auto=format', photos: _wrap(_slice(surprisePhotos, 3, 6), _slice(surprisePhotos, 0, 3))),
  LocationGroup(id: 'loc-paris', location: 'Paris', date: 'May 2023', count: 89, coverUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=700&h=420&fit=crop&auto=format', photos: _wrap(_slice(surprisePhotos, 2, 6), _slice(surprisePhotos, 0, 2))),
];
