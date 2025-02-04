import 'package:flutter/material.dart';

class AppColors {
  // 基础颜色
  static const background = Color(0xFF0C0C18);
  static const surface = Color(0xFF13132B);
  static const surfaceLight = Color(0xFF1E1E3F);

  // 主题颜色
  static const primary = Color(0xFF512BD4); // .NET 紫色
  static const secondary = Color(0xFF00A2FF); // 亮蓝色
  static const tertiary = Color(0xFFE044AA); // 粉紫色
  static const quaternary = Color(0xFF8A2BE2); // 深紫色

  // 文字颜色
  static const onBackground = Colors.white;
  static const onBackgroundMuted = Color(0xCCFFFFFF);
  static const onSurface = Colors.white;

  // 渐变色
  static const primaryGradient = LinearGradient(
    colors: [
      Color(0xFF512BD4), // .NET 紫色
      Color(0xFF7209B7), // 中紫色
      Color(0xFF9548E5), // 浅紫色
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [
      Color(0xFF00A2FF), // 亮蓝色
      Color(0xFFE044AA), // 粉紫色
      Color(0xFF8A2BE2), // 深紫色
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 背景渐变
  static const backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF0C0C18), // 深色背景
      Color(0xFF1A1A35), // 稍亮的紫色
      Color(0xFF13132B), // 中间色
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 亚克力效果颜色
  static final acrylicSurface = Color(0xFF1E1E3F).withOpacity(0.7);
  static final acrylicSurfaceLight = Color(0xFF2D2D5F).withOpacity(0.5);

  // 光晕效果颜色
  static final glowPurple = primary.withOpacity(0.15);
  static final glowBlue = secondary.withOpacity(0.15);
}
