# Проектные правила для Water Tracker v1

##  Цель
Оффлайн-приложение для учёта воды. Без аккаунтов, без интернета, без Firebase. Данные — только на устройстве.

##  Архитектура
- Единое состояние: `FFAppState` (singleton, persisted через shared_preferences)
- Нет Bloc/Riverpod/GetX — только StatefulWidget + setState + Provider
- Все данные — локальные, без сервера
- Провайдер: `provider` пакет для передачи состояния между виджетами

## 🌐 Язык
- Код: Dart (null-safe)
- Комментарии: на русском (только где логика неочевидна)
- UI: полностью на русском (ru-RU)

##  Дизайн
- Тема: тёмная неоновая (фон `#0D152A`, акцент `#50FAF1`)
- Все цвета централизованы в `utils/app_colors.dart` (класс `AppColors`)
- Все стили текста централизованы в `utils/text_styles.dart` (класс `TextStyles`)
- Использование `.copyWith()` для устранения дублирования стилей
- AppBar: двухстрочный ("💧Трекер воды" + "Следите за водным балансом")
- BottomNavigationBar: на всех экранах, кроме OnboardingPage
- Резерв под баннер: Container(height: 60) над навигацией
- Шрифт: Inter (подключён через assets)

## 📏 Логика
- Стакан = 250 мл (фиксировано в v1)
- Цель: от 1 до 50 стаканов → clamp(1, 50)
- Некорректный ввод → fallback на 8
- Склонение: через pluralizeGlasses() → "1 стакан", "2 стакана", "5 стаканов"
- Проверка смены дня: через `lastCheckedDay` (String в формате "yyyy-MM-dd")
- Форматирование дат: через собственную функцию `formatDateKey()` (без явного использования `intl`)
- История целей: `dailyGoalsHistory` (Map<String, int>), очистка записей старше 90 дней
- Статус достижения цели вычисляется динамически в UI: `waterGlassesToday >= dailyGoalGlasses`
- Глобальное масштабирование шрифтов отключено: `TextScaler.noScaling` (решение для Honor)

##  Хранение
- Все переменные — persisted через SharedPreferences:
  - dailyGoalGlasses (int)
  - waterGlassesToday (int)
  - weeklyWaterGlasses (List<int>, длина 7)
  - isDarkMode (bool) — зарезервировано для V2 (переключатель темы)
  - isOnboardingCompleted (bool)
  - dailyGoalsHistory (Map<String, int>, JSON)
  - lastCheckedDay (String, формат "yyyy-MM-dd")
- При старте — проверка смены дня → сброс прогресса, запись в weeklyWaterGlasses
- Кэш SharedPreferences: используется `_prefs` для оптимизации запросов
- Параллельные операции сохранения: `Future.wait([...])`

## 🎬 Анимации
- Конфетти при достижении цели: 25 крупных эмодзи 🎉 (scale 1.5-2.5x)
- Равномерное распределение: стратифицированная выборка + компенсация размера эмодзи
- Длительность анимации: 3 секунды
- Кнопка "+1 стакан": pop-эффект + неоновое свечение (через `AnimatedButton`)
- Вибрация при достижении цели: 1000 мс (✅ ЗАДАЧА 4.17 ВЫПОЛНЕНА)

## 🚫 Запрещено в v1
- Реклама, напоминания, светлая тема, настраиваемый объём стакана
- Внешние зависимости кроме: flutter, shared_preferences, provider, vibration, intl
- Английский в UI

## 📁 Структура
lib/
├── main.dart
├── app_state.dart
── utils/
│   ├── pluralize.dart
│   ├── app_colors.dart
│   └── text_styles.dart
├── widgets/
│   ├── custom_app_bar.dart
│   └── animated_button.dart
└── pages/
    ├── onboarding_page.dart
    ├── home_page.dart
    ├── stats_page.dart
    └── settings_page.dart