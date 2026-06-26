import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 🔹 БАЗОВЫЕ СТИЛИ ТЕКСТА (устраняем дублирование)
class TextStyles {
  // 🎯 БАЗОВЫЙ СТИЛЬ (общие параметры для большинства текстов)
  static const TextStyle base = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    letterSpacing: -0.05,
  );

  // 🎯 НЕОНОВЫЙ СТИЛЬ (с тенями для акцентных элементов)
  static TextStyle neon({
    required Color color,
    required double fontSize,
    double letterSpacing = -0.05,
    double blurRadius = 12,
  }) {
    return base.copyWith(
      color: color,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      shadows: [
        Shadow(
          color: AppColors.accentGlow,
          blurRadius: blurRadius,
          offset: Offset.zero,
        ),
      ],
    );
  }

  // 🎯 ОБЫЧНЫЙ ТЕКСТ (без теней)
  static TextStyle regular({
    required Color color,
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return base.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  // 🎯 ЗАГОЛОВОК (акцентный, с неоновым свечением)
  static TextStyle title({
    required double fontSize,
  }) {
    return neon(
      color: AppColors.accent,
      fontSize: fontSize,
    );
  }

  // 🎯 ПОДЗАГОЛОВОК (вторичный текст)
  static TextStyle subtitle({
    required double fontSize,
  }) {
    return regular(
      color: AppColors.textSecondary,
      fontSize: fontSize,
    );
  }

  // 🎯 КНОПКА (чёрный текст на акцентном фоне)
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    color: Colors.black,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
  );

  // 🎯 ЦИФРА (крупное число с неоновым свечением)
  static TextStyle number({
    required double fontSize,
    double letterSpacing = -1.5,
  }) {
    return neon(
      color: AppColors.accent,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
    );
  }

  // 🎯 КНОПКА +/- (минус/плюс)
  static TextStyle plusMinus({
    required double fontSize,
  }) {
    return neon(
      color: AppColors.accent,
      fontSize: fontSize,
      letterSpacing: -0.3,
    );
  }

  // 🎯 ПОДСКАЗКА (вторичный текст маленький)
  static TextStyle hint({
    required double fontSize,
  }) {
    return regular(
      color: AppColors.textSecondary,
      fontSize: fontSize,
    );
  }

  // 🎯 ЦЕЛЬ (первичный текст)
  static TextStyle goal({
    required double fontSize,
  }) {
    return regular(
      color: AppColors.textPrimary,
      fontSize: fontSize,
    );
  }

  // 🎯 ЭМОДЗИ (для конфетти)
  static TextStyle emoji({
    required double fontSize,
  }) {
    return TextStyle(
      fontSize: fontSize,
    );
  }
}