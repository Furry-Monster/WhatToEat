import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  // 全局设置
  static const bool showDebugBanner = false;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        background: AppColors.background,
        surface: AppColors.surface,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        onBackground: AppColors.onBackground,
        onSurface: AppColors.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.acrylicSurface,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: AppColors.onBackground.withOpacity(0.7),
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
            );
          }
          return IconThemeData(
            color: AppColors.onBackground.withOpacity(0.7),
          );
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.acrylicSurfaceLight,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: AppColors.acrylicSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Dialog 样式
  static BoxDecoration dialogDecoration = BoxDecoration(
    gradient: AppColors.primaryGradient.scale(0.3),
    borderRadius: BorderRadius.circular(16),
  );

  static const dialogPadding = EdgeInsets.all(20);

  // 文本样式
  static TextStyle dialogTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          );

  static TextStyle dialogSubtitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!.copyWith(
            color: AppColors.onBackground,
          );

  static const TextStyle chipLabelStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
  );

  // 输入框样式
  static const double inputHeight = 56.0;
  static const InputDecoration textFieldDecoration = InputDecoration(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 16,
    ),
  );

  // 下拉框样式
  static const double dropdownHeight = 56.0;
  static InputDecoration dropdownDecoration = textFieldDecoration.copyWith(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  );

  // Chip 样式
  static const double chipHeight = 40.0;
  static ChipThemeData get tagChipTheme => ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelPadding: EdgeInsets.zero,
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(fontSize: 14),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: BorderSide.none,
        showCheckmark: false,
      );

  static TextStyle tagChipLabelStyle(Color color) => TextStyle(
        color: color,
        fontSize: 14,
      );

  static TextStyle tagChipSelectedLabelStyle = const TextStyle(
    color: Colors.white,
    fontSize: 14,
  );

  // 卡片样式
  static BoxDecoration cardDecoration = BoxDecoration(
    gradient: AppColors.primaryGradient.scale(0.3),
    borderRadius: BorderRadius.circular(16),
  );

  static const cardPadding = EdgeInsets.all(16);
  static const cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  // 空状态样式
  static TextStyle emptyStateStyle = TextStyle(
    color: AppColors.onBackgroundMuted,
    fontSize: 16,
  );

  static const double emptyStateIconSize = 64.0;
  static const double spacingNormal = 16.0;
  static const double spacingSmall = 8.0;

  // 按钮样式
  static ButtonStyle filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.2),
    foregroundColor: AppColors.onBackground,
  );

  // 列表样式
  static const listViewPadding = EdgeInsets.all(16);

  // 卡片文本样式
  static TextStyle cardTitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w600,
          );

  static TextStyle cardSubtitleStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppColors.onBackgroundMuted,
          );

  // 标签选择样式
  static const double tagChipSpacing = 8.0;
  static const double tagChipHeight = 32.0;
}
