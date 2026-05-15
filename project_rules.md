# Проектные правила для Water Tracker v1

## 🎯 Цель
Оффлайн-приложение для учёта воды. Без аккаунтов, без интернета, без Firebase. Данные — только на устройстве.

## 🧠 Архитектура
- Единое состояние: `FFAppState` (singleton, persisted через shared_preferences)
- Нет Bloc/Riverpod/GetX — только StatefulWidget + setState
- Все данные — локальные, без сервера

## 🌐 Язык
- Код: Dart (null-safe)
- Комментарии: на русском (только где логика неочевидна)
- UI: полностью на русском (ru-RU)

## 🎨 Дизайн
- Тема: тёмная неоновая (#0f0f15 фон, #17e4fc акцент)
- AppBar: двухстрочный ("💧Трекер воды" + "Следите за водным балансом")
- BottomNavigationBar: на всех экранах, кроме OnboardingPage
- Резерв под баннер: Container(height: 60) над навигацией

## 📏 Логика
- Стакан = 250 мл (фиксировано в v1)
- Цель: от 1 до 50 стаканов → clamp(1, 50)
- Некорректный ввод → fallback на 8
- Склонение: через pluralizeGlasses() → "1 стакан", "2 стакана", "5 стаканов"

## 💾 Хранение
- Все переменные из ТЗ — persisted:
  dailyGoalGlasses, waterGlassesToday, weeklyWaterGlasses, isDarkMode, isOnboardingCompleted, lastUpdateDate
- При старте — проверка смены дня → сброс прогресса, запись в weeklyWaterGlasses

## 🚫 Запрещено в v1
- Реклама, напоминания, светлая тема, настраиваемый объём стакана
- Внешние зависимости кроме flutter и shared_preferences
- try-catch кроме int.parse()
- Английский в UI

## 📁 Структура
lib/
├── main.dart
├── app_state.dart
├── utils/pluralize.dart
├── widgets/custom_app_bar.dart
├── themes/dark_theme.dart
└── pages/
    ├── onboarding_page.dart
    ├── home_page.dart
    ├── stats_page.dart
    └── settings_page.dart