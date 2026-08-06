import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme.dart';

class BottomNav extends StatelessWidget {
  final TabName active;
  final ValueChanged<TabName> onChange;

  const BottomNav({super.key, required this.active, required this.onChange});

  static const _tabs = [
    (id: TabName.gallery, label: 'Photos', icon: Icons.grid_view_rounded),
    (id: TabName.review, label: 'Review', icon: Icons.replay_rounded),
    (id: TabName.settings, label: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _tabs.map((t) {
          final isActive = active == t.id;
          final color = isActive ? AppColors.ink : AppColors.grey300;
          return InkWell(
            onTap: () => onChange(t.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon, size: 22, color: color),
                  const SizedBox(height: 5),
                  Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
