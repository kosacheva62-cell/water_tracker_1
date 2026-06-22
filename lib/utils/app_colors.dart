import 'package:flutter/material.dart';

/// 🎨 Централизованная палитра приложения "Трекер воды"
/// Все цвета вынесены сюда для удобства поддержки и будущей светлой темы.
class AppColors {
  AppColors._(); // Приватный конструктор (нельзя создать экземпляр)

  // ═══════════════════════════════════════════════════════════════════
  // ОСНОВНЫЕ ЦВЕТА
  // ═══════════════════════════════════════════════════════════════════

  /// 🟦 Тёмно-синий фон всех страниц
  static const Color background = Color(0xFF0D152A);

  /// 🟢 Неоновый голубой — акцентный цвет (кнопки, прогресс, заголовки)
  static const Color accent = Color(0xFF50FAF1);

  /// ⚪ Белый — основной текст
  static const Color textPrimary = Colors.white;

  /// 🔘 Светло-серый — вторичный текст (подписи, подсказки)
  static const Color textSecondary = Color(0xFFB0B8D0);

  /// 🟦 Синий для карточек (настройки, блоки)
  static const Color card = Color(0xFF162238);

  /// 🟦 Синий для разделителей (линии, границы)
  static const Color divider = Color(0xFF1A283F);

  /// ⚫ Чёрный — текст на светлых кнопках
  static const Color textOnAccent = Colors.black;

  /// 🟢 Тёмно-бирюзовый — фон незаполненной части кольца прогресса
  static const Color progressBackground = Color(0xFF143A47);

  // ═══════════════════════════════════════════════════════════════════
  // ЦВЕТА СВЕЧЕНИЯ (с прозрачностью)
  // ═══════════════════════════════════════════════════════════════════

  /// Мягкое свечение (для BoxShadow) — 53% непрозрачности
  static const Color accentShadow = Color(0x8850FAF1);

  /// Яркое свечение (для Shadow в TextStyle) — 80% непрозрачности
  static const Color accentGlow = Color(0xCC50FAF1);

  /// Очень мягкое свечение — 20% непрозрачности
  static const Color accentSoft = Color(0x3350FAF1);

  /// Среднее свечение — 67% непрозрачности (для SnackBar)
  static const Color accentMedium = Color(0xAA50FAF1);
}