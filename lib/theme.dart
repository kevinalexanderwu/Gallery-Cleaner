import 'package:flutter/material.dart';
import 'models/models.dart';

/// Flat color palette lifted directly from the original design's hex
/// values, so every screen stays pixel-faithful to the source.
class AppColors {
  static const ink = Color(0xFF111111);
  static const inkSoft = Color(0xFF333333);
  static const grey700 = Color(0xFF555555);
  static const grey600 = Color(0xFF777777);
  static const grey500 = Color(0xFF888888);
  static const grey400 = Color(0xFFAAAAAA);
  static const grey350 = Color(0xFFBBBBBB);
  static const grey300 = Color(0xFFC4C4C4);
  static const grey250 = Color(0xFFCCCCCC);
  static const grey200 = Color(0xFFDEDEDE);
  static const grey150 = Color(0xFFECECEC);
  static const grey100 = Color(0xFFF0F0F0);
  static const grey50 = Color(0xFFF5F5F5);
  static const bgFaint = Color(0xFFFAFAFA);
  static const border = Color(0xFFECECEC);
  static const divider = Color(0xFFF0F0F0);

  static const keep = Color(0xFF16A34A);
  static const keepBg = Color(0xF0DCFCE7);
  static const delete = Color(0xFFDC2626);
  static const deleteBg = Color(0xF0FEE2E2);
  static const later = Color(0xFF2563EB);
  static const laterBg = Color(0xF0DBEAFE);
  static const favorite = Color(0xFFD97706);
  static const favoriteBg = Color(0xF0FEF3C7);
}

/// Icon + label + color per [PhotoAction], mirroring ACTION_CONFIG.
class ActionVisual {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;
  const ActionVisual({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}

const Map<PhotoAction, ActionVisual> actionConfig = {
  PhotoAction.keep: ActionVisual(
      label: 'Keep', color: AppColors.keep, bgColor: AppColors.keepBg, icon: Icons.check),
  PhotoAction.delete: ActionVisual(
      label: 'Delete', color: AppColors.delete, bgColor: AppColors.deleteBg, icon: Icons.delete_outline),
  PhotoAction.later: ActionVisual(
      label: 'Later', color: AppColors.later, bgColor: AppColors.laterBg, icon: Icons.schedule),
  PhotoAction.favorite: ActionVisual(
      label: 'Fav', color: AppColors.favorite, bgColor: AppColors.favoriteBg, icon: Icons.star_outline),
};

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: '.SF Pro Text',
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: AppColors.divider,
  );
}
