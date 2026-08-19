import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils.dart';
import '../state/app_controller.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class ReviewByLocationScreen extends ConsumerWidget {
  final ValueChanged<LocationGroup> onStart;
  final VoidCallback onBack;
  const ReviewByLocationScreen({super.key, required this.onStart, required this.onBack});

  @override
 Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(appControllerProvider);
  final locationGroups = state.locationGroups;
  final isLoadingLocation =
    state.locationTotal > 0 &&
    state.locationProgress < state.locationTotal;
    return Container(
      color: AppColors.bgFaint,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.divider),
              ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('By Location', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.3, height: 1)),
                    SizedBox(height: 2),
                    Text(
                      '${locationGroups.length} '
                      'location${locationGroups.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoadingLocation
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Finding locations...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${state.locationProgress} / '
                          '${state.locationTotal} photos',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 180,
                          child: LinearProgressIndicator(
                            value: state.locationTotal == 0
                                ? 0
                                : state.locationProgress /
                                    state.locationTotal,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  )
                : locationGroups.isEmpty
                    ? const Center(
                        child: Text(
                          'No locations found',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey500,
                          ),
                        ),
                      )
          : ListView.separated(
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
                          child: _LocationCoverPhoto(
                            photo: group.photos.first,
                          ),
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

class _LocationCoverPhoto extends StatelessWidget {
  final Photo photo;

  const _LocationCoverPhoto({
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    final asset = photo.asset;

    if (asset == null) {
      return Container(
        color: const Color(0xFFEBEBEB),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(
        const ThumbnailSize(800, 420),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: const Color(0xFFEBEBEB),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        final bytes = snapshot.data;

        if (bytes == null) {
          return Container(
            color: const Color(0xFFEBEBEB),
          );
        }

        return Image.memory(
          bytes,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
