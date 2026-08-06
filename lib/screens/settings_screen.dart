import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_controller.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);

    return Container(
      color: AppColors.bgFaint,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Text('Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.4, height: 1)),
          ),
          _Section(title: 'Review', children: [
            _Row(
              icon: Icons.replay_rounded,
              label: 'Swipe hints',
              sub: 'Show labels while dragging',
              trailing: _Toggle(on: s.swipeHints, onToggle: ctrl.toggleSwipeHints),
            ),
            _Row(
              icon: Icons.schedule,
              label: 'Auto-advance delay',
              sub: 'Pause after each action',
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('None', style: TextStyle(fontSize: 13, color: AppColors.grey400)),
                  Icon(Icons.chevron_right, size: 14, color: AppColors.grey200),
                ],
              ),
            ),
          ]),
          _Section(title: 'Storage', children: [
            _Row(
              icon: Icons.delete_outline,
              label: 'Delete permanently',
              sub: 'Skip trash, remove immediately',
              trailing: _Toggle(on: s.permanentDelete, onToggle: ctrl.togglePermanentDelete),
            ),
            const _Row(
              icon: Icons.storage_outlined,
              label: 'Storage used',
              sub: '48.3 GB of photos',
              trailing: Icon(Icons.chevron_right, size: 16, color: AppColors.grey250),
            ),
          ]),
          _Section(title: 'Notifications', children: [
            _Row(
              icon: Icons.notifications_outlined,
              label: 'Daily reminder',
              sub: 'Remind me to review new photos',
              trailing: _Toggle(on: s.notifications, onToggle: ctrl.toggleNotifications),
            ),
          ]),
          _Section(title: 'Appearance', children: [
            _Row(
              icon: Icons.dark_mode_outlined,
              label: 'Dark mode',
              trailing: _Toggle(on: s.darkMode, onToggle: ctrl.toggleDarkMode),
            ),
          ]),
          _Section(title: 'About', children: const [
            _Row(icon: Icons.shield_outlined, label: 'Privacy policy', trailing: Icon(Icons.chevron_right, size: 16, color: AppColors.grey250)),
            _Row(icon: Icons.auto_awesome, label: 'Version', sub: 'Gallery Cleaner 1.0', trailing: Text('1.0.0', style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)))),
          ]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 4),
            child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.grey400, letterSpacing: 1.5)),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.grey150),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final Widget trailing;
  const _Row({required this.icon, required this.label, this.sub, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: AppColors.grey50, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: AppColors.grey700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub!, style: const TextStyle(fontSize: 12, color: AppColors.grey400)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool on;
  final VoidCallback onToggle;
  const _Toggle({required this.on, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        decoration: BoxDecoration(
          color: on ? AppColors.ink : AppColors.grey200,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: Color(0x1A000000), blurRadius: 2, offset: Offset(0, 1)),
            ]),
          ),
        ),
      ),
    );
  }
}
