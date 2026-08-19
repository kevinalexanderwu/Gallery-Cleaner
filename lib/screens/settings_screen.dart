import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

import '../state/app_controller.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _storageBytes;
  bool _isCalculatingStorage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStorage();
    });
  }

  Future<void> _refreshStorage() async {
    if (_isCalculatingStorage) return;

    setState(() {
      _isCalculatingStorage = true;
    });

    try {
      final permission = await PhotoManager.requestPermissionExtend();

      if (!permission.isAuth) {
        if (mounted) {
          setState(() {
            _storageBytes = null;
            _isCalculatingStorage = false;
          });
        }
        return;
      }

      final paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      if (paths.isEmpty) {
        if (mounted) {
          setState(() {
            _storageBytes = 0;
            _isCalculatingStorage = false;
          });
        }
        return;
      }

      int totalBytes = 0;

      // Use the "All" album when available.
      final path = paths.first;

      const pageSize = 100;
      int page = 0;

      while (true) {
        final assets = await path.getAssetListPaged(
          page: page,
          size: pageSize,
        );

        if (assets.isEmpty) break;

        for (final asset in assets) {
          try {
            final file = await asset.file;
            if (file != null && await file.exists()) {
              totalBytes += await file.length();
            }
          } catch (_) {
            // Skip files that cannot be accessed.
          }
        }

        if (assets.length < pageSize) break;
        page++;
      }

      if (!mounted) return;

      setState(() {
        _storageBytes = totalBytes;
        _isCalculatingStorage = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _storageBytes = null;
        _isCalculatingStorage = false;
      });
    }
  }

  String _formatStorage() {
    final bytes = _storageBytes;

    if (bytes == null) {
      return 'Unable to calculate photo storage';
    }

    if (bytes < 1024 * 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB of photos';
    }

    final gb = bytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(1)} GB of photos';
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsControllerProvider);
    final ctrl = ref.read(settingsControllerProvider.notifier);

    return Container(
      color: AppColors.bgFaint,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
                letterSpacing: -0.4,
                height: 1,
              ),
            ),
          ),
          _Section(
            title: 'Review',
            children: [
              _Row(
                icon: Icons.replay_rounded,
                label: 'Swipe hints',
                sub: 'Show labels while dragging',
                trailing: _Toggle(
                  on: s.swipeHints,
                  onToggle: ctrl.toggleSwipeHints,
                ),
              ),
              const _Row(
                icon: Icons.schedule,
                label: 'Auto-advance delay',
                sub: 'Pause after each action',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'None',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey400,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: AppColors.grey200,
                    ),
                  ],
                ),
              ),
            ],
          ),
          _Section(
            title: 'Storage',
            children: [
              _Row(
                icon: Icons.delete_outline,
                label: 'Delete permanently',
                sub: 'Skip trash, remove immediately',
                trailing: _Toggle(
                  on: s.permanentDelete,
                  onToggle: ctrl.togglePermanentDelete,
                ),
              ),
              _StorageRow(
                value: _isCalculatingStorage
                    ? 'Calculating...'
                    : _formatStorage(),
                isLoading: _isCalculatingStorage,
                onRefresh: _refreshStorage,
              ),
            ],
          ),
          _Section(
            title: 'Notifications',
            children: [
              _Row(
                icon: Icons.notifications_outlined,
                label: 'Daily reminder',
                sub: 'Remind me to review new photos',
                trailing: _Toggle(
                  on: s.notifications,
                  onToggle: ctrl.toggleNotifications,
                ),
              ),
            ],
          ),
          _Section(
            title: 'Appearance',
            children: [
              _Row(
                icon: Icons.dark_mode_outlined,
                label: 'Dark mode',
                trailing: _Toggle(
                  on: s.darkMode,
                  onToggle: ctrl.toggleDarkMode,
                ),
              ),
            ],
          ),
          _Section(
            title: 'About',
            children: [
              _Row(
                icon: Icons.shield_outlined,
                label: 'Privacy policy',
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.grey250,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              const _Row(
                icon: Icons.auto_awesome,
                label: 'Version',
                sub: 'Gallery Cleaner 1.0',
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StorageRow extends StatelessWidget {
  final String value;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _StorageRow({
    required this.value,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.storage_outlined,
              size: 15,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Storage used',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.ink,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey400,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: isLoading ? null : onRefresh,
            tooltip: 'Refresh storage',
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                    ),
                  )
                : const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: AppColors.grey500,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 4),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.grey400,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      color: AppColors.grey150,
                    ),
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
  final VoidCallback? onTap;

  const _Row({
    required this.icon,
    required this.label,
    this.sub,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 15,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool on;
  final VoidCallback onToggle;

  const _Toggle({
    required this.on,
    required this.onToggle,
  });

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
          alignment: on
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgFaint,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.ink,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: const [
          Text(
            'Last updated: August 2026',
            style: TextStyle(fontSize: 12, color: AppColors.grey400),
          ),
          SizedBox(height: 24),
          _PrivacyTitle('Photos & Videos'),
          _PrivacyText(
            'Gallery Cleaner requires access to photos and videos on your '
            'device to provide features such as reviewing, organizing, '
            'and deleting media.',
          ),
          _PrivacyTitle('Location'),
          _PrivacyText(
            'Gallery Cleaner may read location information stored in photo '
            'metadata to provide the Review by Location feature. It does '
            'not request your device’s live location for this feature.',
          ),
          _PrivacyTitle('Your Data'),
          _PrivacyText(
            'Gallery Cleaner is designed to process your media locally on '
            'your device. Your photos and videos are not uploaded to a '
            'remote server by the application’s local features.',
          ),
          _PrivacyTitle('Data Collection'),
          _PrivacyText(
            'Gallery Cleaner does not require an account for its core '
            'features and does not intentionally collect personal '
            'information such as your name, email address, phone number, '
            'contacts, or messages.',
          ),
          _PrivacyTitle('Permissions'),
          _PrivacyText(
            'Gallery Cleaner may request permission to access your photos '
            'and videos. These permissions are necessary for core '
            'functionality and can be managed through device settings.',
          ),
          _PrivacyTitle('Deletion'),
          _PrivacyText(
            'When you choose to delete photos or videos, Gallery Cleaner '
            'performs the requested deletion using the permissions provided '
            'by your device. Please review selected media before confirming.',
          ),
          _PrivacyTitle('Changes'),
          _PrivacyText(
            'This Privacy Policy may be updated when Gallery Cleaner '
            'introduces new features or changes how information is handled.',
          ),
          _PrivacyTitle('Contact'),
          _PrivacyText(
            'Kevin Alexander\nEmail: your-email@example.com',
          ),
        ],
      ),
    );
  }
}

class _PrivacyTitle extends StatelessWidget {
  final String text;

  const _PrivacyTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _PrivacyText extends StatelessWidget {
  final String text;

  const _PrivacyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.6,
          color: AppColors.grey700,
        ),
      ),
    );
  }
}
