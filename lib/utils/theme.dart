import 'package:flutter/material.dart';

class AppTheme {
  // 主色调 - 柔和的蓝紫渐变
  static const Color primaryLight = Color(0xFF6B8AFE);
  static const Color primaryDark = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF06B6D4);
  
  // 背景色
  static const Color bgStart = Color(0xFFE0E7FF);
  static const Color bgMid = Color(0xFFEDE9FE);
  static const Color bgEnd = Color(0xFFE0F2FE);
  
  // 玻璃效果
  static const double glassBlur = 20.0;
  static const double glassOpacity = 0.25;
  static const double glassBorderOpacity = 0.4;
  
  // 文字颜色
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textWhite = Colors.white;
  
  // 气泡颜色
  static const Color userBubbleStart = Color(0xFF6B8AFE);
  static const Color userBubbleEnd = Color(0xFF8B5CF6);
  static const Color aiBubble = Colors.white;
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
    );
  }
  
  // 渐变背景
  static BoxDecoration get backgroundGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bgStart, bgMid, bgEnd],
      ),
    );
  }
  
  // 用户消息气泡渐变
  static const LinearGradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [userBubbleStart, userBubbleEnd],
  );
  
  // 主按钮渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryLight, primaryDark],
  );
}
