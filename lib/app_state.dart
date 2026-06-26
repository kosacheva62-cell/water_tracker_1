import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ✅ ЗАДАЧА: Своя функция форматирования дат вместо intl
String formatDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class FFAppState extends ChangeNotifier {
  static final FFAppState _instance = FFAppState._internal();
  factory FFAppState() => _instance;
  FFAppState._internal();

  // 🎯 КОНСТАНТЫ ЛИМИТОВ (Задача 1.3)
  static const int minDailyGoalGlasses = 1;
  static const int maxDailyGoalGlasses = 50;

  // 🎯 Основные настройки и счетчики
  int dailyGoalGlasses = 8;
  int get dailyGoalMl => dailyGoalGlasses * 250; // 1 стакан = 250 мл
  
  int waterGlassesToday = 0;
  
  // 📊 Недельная статистика (Пн=0, Вт=1, ..., Вс=6)
  List<int> weeklyWaterGlasses = List.filled(7, 0);
  
  // ⚙️ Состояние приложения
  bool isDarkMode = true;  // ⚠️ Зарезервировано для V2 (переключатель темы)
  bool isOnboardingCompleted = false;
  Map<String, int> dailyGoalsHistory = {};
  String? lastCheckedDay;

  // ✅ ЗАДАЧА 2.1: Кэш экземпляра SharedPreferences
  SharedPreferences? _prefs;

  // ✅ ЗАДАЧА 2.1: Геттер для получения кэшированного экземпляра
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // 🔹 Загрузка данных из SharedPreferences
  Future<void> load() async {
    // ✅ ЗАДАЧА 2.1: Используем кэш вместо SharedPreferences.getInstance()
    final prefs = await _preferences;
    
    dailyGoalGlasses = prefs.getInt('dailyGoalGlasses') ?? 8;
    waterGlassesToday = prefs.getInt('waterGlassesToday') ?? 0;
    isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;
    isDarkMode = prefs.getBool('isDarkMode') ?? true;
    
    final saved = prefs.getStringList('weeklyWaterGlasses');
    weeklyWaterGlasses = (saved != null && saved.length == 7)
        ? saved.map((e) => int.tryParse(e) ?? 0).toList()
        : List.filled(7, 0);

    final historyJson = prefs.getString('dailyGoalsHistory');
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(historyJson);
        if (decoded is Map) {
          dailyGoalsHistory = decoded.map((key, value) => 
            MapEntry(key as String, (value as num).toInt()));
        }
      } catch (e) {
        dailyGoalsHistory = {};
      }
    }

    lastCheckedDay = prefs.getString('lastCheckedDay');

    // Инициализация истории целей при первом запуске
    if (dailyGoalsHistory.isEmpty) {
      final today = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: i));
        final key = formatDateKey(date);  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey
        dailyGoalsHistory[key] = dailyGoalGlasses;
      }
      await save();
    }

    // Инициализация lastCheckedDay
    if (lastCheckedDay == null) {
      dailyGoalGlasses = 8;
      lastCheckedDay = formatDateKey(DateTime.now());  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey
      dailyGoalsHistory[lastCheckedDay!] = 8;
      await save();
    }

    // Синхронизация текущего дня с недельным массивом
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    if (waterGlassesToday > weeklyWaterGlasses[todayIndex]) {
      weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    }
  }

  // 💾 Сохранение данных в SharedPreferences
  // ✅ ЗАДАЧА 2.1: Кэш + Future.wait (параллельные операции)
  Future<void> save() async {
    try {
      final prefs = await _preferences;
      
      await Future.wait([
        prefs.setInt('dailyGoalGlasses', dailyGoalGlasses),
        prefs.setInt('waterGlassesToday', waterGlassesToday),
        prefs.setBool('isOnboardingCompleted', isOnboardingCompleted),
        prefs.setBool('isDarkMode', isDarkMode),
        prefs.setStringList('weeklyWaterGlasses', weeklyWaterGlasses.map((e) => e.toString()).toList()),
        prefs.setString('dailyGoalsHistory', jsonEncode(dailyGoalsHistory)),
        prefs.setString('lastCheckedDay', lastCheckedDay ?? ''),
      ]);
    } catch (e) {
      throw Exception('Не удалось сохранить данные: $e');
    }
  }

  // 🔄 ПРОВЕРКА СМЕНЫ ДНЯ
  // ✅ ЗАДАЧА 2.2: Добавлена очистка старых записей (старше 90 дней)
  Future<void> checkDayChange() async {
    final now = DateTime.now();
    final todayString = formatDateKey(now);  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey

    if (lastCheckedDay == null) {
      lastCheckedDay = todayString;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      await save();
      notifyListeners();
      return;
    }

    if (lastCheckedDay != todayString) {
      // 1. Сохраняем итог за вчерашний день
      final yesterday = now.subtract(Duration(days: 1));
      final yesterdayString = formatDateKey(yesterday);  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey
      final yesterdayIndex = (yesterday.weekday - 1) % 7;
      weeklyWaterGlasses[yesterdayIndex] = waterGlassesToday;
      
      // 2. ОБНУЛЯЕМ ВСЕ ПРОПУЩЕННЫЕ ДНИ
      final lastCheckedDate = DateTime.parse(lastCheckedDay!);
      final daysDiff = now.difference(lastCheckedDate).inDays;
      
      for (int i = 1; i < daysDiff; i++) {
        final missedDate = lastCheckedDate.add(Duration(days: i));
        final missedIndex = (missedDate.weekday - 1) % 7;
        weeklyWaterGlasses[missedIndex] = 0;
        
        final missedKey = formatDateKey(missedDate);  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey
        dailyGoalsHistory[missedKey] = dailyGoalGlasses;
      }
      
      // 3. Фиксируем цели для вчерашнего и сегодняшнего дня
      dailyGoalsHistory[yesterdayString] = dailyGoalGlasses;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      
      // ✅ ЗАДАЧА 2.2: ОЧИЩАЕМ СТАРЫЕ ЗАПИСИ (старше 90 дней)
      final cutoffDate = now.subtract(const Duration(days: 90));
      final cutoffString = formatDateKey(cutoffDate);  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey
      
      dailyGoalsHistory.removeWhere((key, value) => key.compareTo(cutoffString) < 0);
      
      // 4. Сброс счетчиков текущего дня
      waterGlassesToday = 0;
      lastCheckedDay = todayString;
      
      await save();
      notifyListeners();
    }
  }

  // 🎯 Изменение дневной цели (С ИСПОЛЬЗОВАНИЕМ КОНСТАНТ)
  Future<void> setDailyGoal(int glasses) async {
    dailyGoalGlasses = glasses.clamp(minDailyGoalGlasses, maxDailyGoalGlasses);
    final todayString = formatDateKey(DateTime.now());  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey
    dailyGoalsHistory[todayString] = dailyGoalGlasses;
    await save();
    notifyListeners();
  }

  // 📊 Получение цели для конкретного дня недели (0=Пн, 6=Вс)
  int getGoalForWeekDay(int index) {
    final today = DateTime.now();
    final todayIndex = (today.weekday - 1) % 7;
    final daysDiff = index - todayIndex;
    final targetDate = today.add(Duration(days: daysDiff));
    final dateKey = formatDateKey(targetDate);  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey
    return dailyGoalsHistory[dateKey] ?? dailyGoalGlasses;
  }

  // 💧 Добавление стакана воды
  Future<void> addGlass() async {
    waterGlassesToday++;
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    await save();
    notifyListeners();
  }

  // 🚀 Завершение онбординга
  Future<void> completeOnboarding(int glasses) async {
    await setDailyGoal(glasses);
    isOnboardingCompleted = true;
    lastCheckedDay = formatDateKey(DateTime.now());  // ✅ ЗАМЕНЕНО: DateFormat → formatDateKey
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = 0;
    waterGlassesToday = 0;
    await save();
    notifyListeners();
  }
}