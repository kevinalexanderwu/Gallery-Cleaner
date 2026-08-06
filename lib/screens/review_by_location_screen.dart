import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils.dart';
import '../widgets/net_image.dart';

class ReviewByLocationScreen extends StatelessWidget {
  final ValueChanged<LocationGroup> onStart;
  final VoidCallback onBack;
  const ReviewByLocationScreen({super.key, required this.onStart, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgFaint,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.chevron_left, size: 24, color: AppColors.ink),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('By Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.3, height: 1)),
                    SizedBox(height: 2),
                    Text('6 places', style: TextStyle(fontSize: 12, color: AppColors.grey400)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: locationGroups.length,
              separatorBuilder: (context, i) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final group = locationGroups[i];
                return InkWell(
                  onTap: () => onStart(group),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 100 / 52,
                          child: Container(color: const Color(0xFFEBEBEB), child: NetImage(url: group.coverUrl)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: AppColors.grey700),
                                  const SizedBox(width: 6),
                                  Text(group.location, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.2)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${group.date} · ${formatCount(group.count)} photos', style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
