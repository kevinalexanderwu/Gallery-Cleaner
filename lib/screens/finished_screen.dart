import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

class FinishedScreen extends StatefulWidget {
  final Map<PhotoAction, int> counts;
  final SwipeContext? ctx;
  final VoidCallback onDone;
  final VoidCallback onReviewDelete;

  const FinishedScreen({
    super.key,
    required this.counts,
    required this.ctx,
    required this.onDone,
    required this.onReviewDelete,
  });

  @override
  State<FinishedScreen> createState() => _FinishedScreenState();
}

class _FinishedScreenState extends State<FinishedScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _rows = [
    (action: PhotoAction.keep, label: 'Kept'),
    (action: PhotoAction.delete, label: 'Deleted'),
    (action: PhotoAction.later, label: 'For Later'),
    (action: PhotoAction.favorite, label: 'Favorited'),
  ];

  @override
  Widget build(BuildContext context) {
    final deleteCount = widget.counts[PhotoAction.delete] ?? 0;
    final gbFreed = (deleteCount * 4.1 / 1024).toStringAsFixed(2);
    final curve = CurvedAnimation(parent: _ctrl, curve: const Cubic(0.16, 1, 0.3, 1));

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: curve,
          builder: (context, child) {
            return Opacity(
              opacity: curve.value,
              child: Transform.translate(offset: Offset(0, (1 - curve.value) * 16), child: child),
            );
          },
          child: Column(
            children: [
              const SizedBox(height: 48),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.center,
                child: const Icon(Icons.check, size: 24, color: AppColors.ink),
              ),
              const SizedBox(height: 20),
              const Text('Review complete', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.3)),
              if (widget.ctx != null) ...[
                const SizedBox(height: 4),
                Text('${widget.ctx!.title} · ${widget.ctx!.subtitle}', style: const TextStyle(fontSize: 13, color: AppColors.grey600)),
              ],
              if (deleteCount > 0) ...[
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border), bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(
                    children: [
                      const Text('STORAGE FREED', style: TextStyle(fontSize: 11, color: AppColors.grey400, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text('$gbFreed GB', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.4, height: 1)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Column(
                children: [
                  for (int i = 0; i < _rows.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: AppColors.divider),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(actionConfig[_rows[i].action]!.icon, size: 14, color: actionConfig[_rows[i].action]!.color),
                              const SizedBox(width: 10),
                              Text(_rows[i].label, style: const TextStyle(fontSize: 14, color: AppColors.inkSoft)),
                            ],
                          ),
                          Text('${widget.counts[_rows[i].action] ?? 0}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),

              if (deleteCount > 0) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: widget.onReviewDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(
                      'Review Delete Queue ($deleteCount)',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
