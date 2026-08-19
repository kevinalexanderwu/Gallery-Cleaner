import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import 'package:photo_manager/photo_manager.dart';

class _ReviewModeItem {
  final ReviewMode id;
  final String label;
  final String hint;
  final IconData icon;
  const _ReviewModeItem({required this.id, required this.label, required this.hint, required this.icon});
}

class ReviewMenuScreen extends ConsumerWidget {
  final ValueChanged<ReviewMode> onSelect;
  const ReviewMenuScreen({super.key, required this.onSelect});

  /// Builds the "Review by Date" hint from real gallery photos when
  /// available ("<count> photos · <n> time periods"), otherwise falls
  /// back to the original static mock text.
  static String _dateHint(List<Photo>? realPhotos) {
    if (realPhotos == null || realPhotos.isEmpty) {
      return '1,287 photos · 5 time periods';
    }
    final int periods = realPhotos.map((p) => p.month).toSet().length;
    return '${_formatCount(realPhotos.length)} photos · $periods time period${periods == 1 ? '' : 's'}';
  }

  static String _formatCount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Photo>? realPhotos = ref.read(appControllerProvider.notifier).galleryPhotos;
    final controller = ref.read(appControllerProvider.notifier);

    final int totalPhotos = realPhotos?.length ?? 0;

    final int locationCount =
      ref.watch(appControllerProvider).locationGroups.length;

    final List<_ReviewModeItem> reviewModes = [
      _ReviewModeItem(
        id: ReviewMode.date,
        label: 'Review by Date',
        hint: _dateHint(realPhotos),
        icon: Icons.calendar_today_outlined,
      ),

      _ReviewModeItem(
        id: ReviewMode.location,
        label: 'Review by Location',
        hint: '$locationCount '
            'location${locationCount == 1 ? '' : 's'}',
        icon: Icons.location_on_outlined,
      ),

      _ReviewModeItem(
        id: ReviewMode.screenshots,
        label: 'Review Screenshots',
        hint: '${ref.read(appControllerProvider.notifier).screenshotPhotos.length} screenshots',
        icon: Icons.image_outlined,
      ),

      _ReviewModeItem(
        id: ReviewMode.largeVideos,
        label: 'Review Videos',
        hint: '${controller.galleryPhotos?.where(
          (photo) => photo.asset?.type == AssetType.video,
        ).length ?? 0} videos',
        icon: Icons.movie_outlined,
      ),

      _ReviewModeItem(
        id: ReviewMode.surprise,
        label: 'Surprise Me',
        hint: realPhotos == null
            ? 'Using demo data'
            : 'Random from $totalPhotos photos',
        icon: Icons.shuffle_rounded,
      ),
    ];

    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Review', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.4, height: 1)),
                SizedBox(height: 6),
                Text('Choose how to revisit your memories.', style: TextStyle(fontSize: 14, color: AppColors.grey600, height: 1.3)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (int i = 0; i < reviewModes.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColors.divider),
                    _ReviewModeRow(item: reviewModes[i], onTap: () => onSelect(reviewModes[i].id)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ReviewModeRow extends StatelessWidget {
  final _ReviewModeItem item;
  final VoidCallback onTap;
  const _ReviewModeRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Icon(item.icon, size: 16, color: AppColors.grey700),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppColors.ink, height: 1.3)),
                  const SizedBox(height: 2),
                  Text(item.hint, style: const TextStyle(fontSize: 12, color: AppColors.grey400)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.grey200),
          ],
        ),
      ),
    );
  }
}