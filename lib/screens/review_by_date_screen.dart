import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/net_image.dart';

class ReviewByDateScreen extends ConsumerWidget {
  final ValueChanged<DateGroup> onStart;
  final VoidCallback onBack;
  const ReviewByDateScreen({super.key, required this.onStart, required this.onBack});

  /// Groups real gallery [photos] by their `month` field into [DateGroup]s,
  /// newest month first. Falls back to `dateGroups` (mock_data) when there
  /// is no real gallery data yet.
  static List<DateGroup> _buildRealGroups(List<Photo> photos) {
    final Map<String, List<Photo>> byMonth = {};
    for (final p in photos) {
      byMonth.putIfAbsent(p.month, () => []).add(p);
    }
    final groups = byMonth.entries.map((e) {
      final photosInMonth = e.value;
      return DateGroup(
        id: e.key.replaceAll(' ', '-').toLowerCase(),
        month: e.key,
        location: photosInMonth.first.location,
        count: photosInMonth.length,
        coverUrl: photosInMonth.first.url,
        photos: photosInMonth,
      );
    }).toList();
    groups.sort((a, b) {
      final aTime = a.photos.first.asset?.createDateTime;
      final bTime = b.photos.first.asset?.createDateTime;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });
    return groups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(appControllerProvider.notifier);

    final List<Photo>? realPhotos = controller.galleryPhotos;

    final hiddenIds = controller.hiddenPhotoIds;

    final List<Photo> filteredPhotos = realPhotos
            ?.where((photo) => !hiddenIds.contains(photo.id))
            .toList() ??
        <Photo>[];

    final bool useReal = filteredPhotos.isNotEmpty;

    final List<DateGroup> groups =
        useReal ? _buildRealGroups(filteredPhotos) : dateGroups;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.chevron_left, size: 24, color: AppColors.ink),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('By Date', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.3, height: 1)),
                    const SizedBox(height: 2),
                    Text('${groups.length} time periods', style: const TextStyle(fontSize: 12, color: AppColors.grey400)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: groups.length,
              itemBuilder: (context, i) {
                final group = groups[i];
                return Column(
                  children: [
                    if (i > 0) const Divider(height: 1, color: AppColors.divider, indent: 20, endIndent: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(group.month, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.3, height: 1)),
                                    const SizedBox(height: 4),
                                    Text(group.location, style: const TextStyle(fontSize: 13, color: AppColors.grey600)),
                                    const SizedBox(height: 2),
                                    Text('${formatCount(group.count)} photos', style: const TextStyle(fontSize: 12, color: AppColors.grey350)),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => onStart(group),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text('Start Review', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink)),
                                      SizedBox(width: 2),
                                      Icon(Icons.chevron_right, size: 14, color: AppColors.ink),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: AppColors.grey150,
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: group.photos.length > 4 ? 4 : group.photos.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2,
                                ),
                                itemBuilder: (context, j) => SquareThumb(url: group.photos[j].url, asset: group.photos[j].asset),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}