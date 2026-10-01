import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ✅ Функция форматирования дат
String formatDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class FFAppState extends ChangeNotifier {
  static final FFAppState _instance = FFAppState._internal();
  factory FFAppState() => _instance;
  FFAppState._internal();

  // 🎯 КОНСТАНТЫ ЛИМИТОВ
  static const int minDailyGoalGlasses = 1;
  static const int maxDailyGoalGlasses = 50;
  
  // ✅ НОВАЯ КОНСТАНТА: Лимиты для объема стакана
  static const int minCupVolume = 50;
  static const int maxCupVolume = 1000;

  // 🎯 Основные настройки и счетчики
  int dailyGoalGlasses = 8;
  int cupVolume = 250; // ✅ ДОБАВЛЕНО: Объем стакана (по умолчанию 250 мл)
  
  // ✅ ИСПРАВЛЕНО: Расчет цели теперь динамический
  int get dailyGoalMl => dailyGoalGlasses * cupVolume; 
  
  int waterGlassesToday = 0;
  
  // 📊 Недельная статистика
  List<int> weeklyWaterGlasses = List.filled(7, 0);
  
  // ️ Состояние приложения
  bool isDarkMode = true;
  bool isOnboardingCompleted = false;
  Map<String, int> dailyGoalsHistory = {};
  String? lastCheckedDay;

  // ✅ Кэш SharedPreferences
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  //  Загрузка данных
  Future<void> load() async {
    final prefs = await _preferences;
    
    dailyGoalGlasses = prefs.getInt('dailyGoalGlasses') ?? 8;
    cupVolume = prefs.getInt('cupVolume') ?? 250; // ✅ ЗАГРУЖАЕМ ОБЪЕМ ИЗ ПАМЯТИ
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
        final key = formatDateKey(date);
        dailyGoalsHistory[key] = dailyGoalGlasses;
      }
      await save();
    }

    // Инициализация lastCheckedDay
    if (lastCheckedDay == null) {
      dailyGoalGlasses = 8;
      cupVolume = 250; // ✅ УБЕЖДАЕМСЯ, ЧТО ПРИ ПЕРВОМ ЗАПУСКЕ ТОЖЕ 250
      lastCheckedDay = formatDateKey(DateTime.now());
      dailyGoalsHistory[lastCheckedDay!] = dailyGoalGlasses;
      await save();
    }

    // Синхронизация текущего дня с недельным массивом
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    if (waterGlassesToday > weeklyWaterGlasses[todayIndex]) {
      weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    }
  }

  // 💾 Сохранение данных
  Future<void> save() async {
    try {
      final prefs = await _preferences;
      
      await Future.wait([
        prefs.setInt('dailyGoalGlasses', dailyGoalGlasses),
        prefs.setInt('cupVolume', cupVolume), // ✅ СОХРАНЯЕМ ОБЪЕМ
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
  Future<void> checkDayChange() async {
    final now = DateTime.now();
    final todayString = formatDateKey(now);

    if (lastCheckedDay == null) {
      lastCheckedDay = todayString;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      await save();
      notifyListeners();
      return;
    }

    if (lastCheckedDay != todayString) {
      final yesterday = now.subtract(Duration(days: 1));
      final yesterdayString = formatDateKey(yesterday);
      final yesterdayIndex = (yesterday.weekday - 1) % 7;
      weeklyWaterGlasses[yesterdayIndex] = waterGlassesToday;
      
      final lastCheckedDate = DateTime.parse(lastCheckedDay!);
      final daysDiff = now.difference(lastCheckedDate).inDays;
      
      for (int i = 1; i < daysDiff; i++) {
        final missedDate = lastCheckedDate.add(Duration(days: i));
        final missedIndex = (missedDate.weekday - 1) % 7;
        weeklyWaterGlasses[missedIndex] = 0;
        
        final missedKey = formatDateKey(missedDate);
        dailyGoalsHistory[missedKey] = dailyGoalGlasses;
      }
      
      dailyGoalsHistory[yesterdayString] = dailyGoalGlasses;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      
      final cutoffDate = now.subtract(const Duration(days: 90));
      final cutoffString = formatDateKey(cutoffDate);
      dailyGoalsHistory.removeWhere((key, value) => key.compareTo(cutoffString) < 0);
      
      waterGlassesToday = 0;
      lastCheckedDay = todayString;
      
      await save();
      notifyListeners();
    }
  }

  // 🎯 Изменение дневной цели
  Future<void> setDailyGoal(int glasses) async {
    dailyGoalGlasses = glasses.clamp(minDailyGoalGlasses, maxDailyGoalGlasses);
    final todayString = formatDateKey(DateTime.now());
    dailyGoalsHistory[todayString] = dailyGoalGlasses;
    await save();
    notifyListeners();
  }

  // ✅ НОВЫЙ МЕТОД: Изменение объема стакана
  Future<void> setCupVolume(int volume) async {
    cupVolume = volume.clamp(minCupVolume, maxCupVolume);
    await save();
    notifyListeners();
  }

  // 📊 Получение цели для конкретного дня недели
  int getGoalForWeekDay(int index) {
    final today = DateTime.now();
    final todayIndex = (today.weekday - 1) % 7;
    final daysDiff = index - todayIndex;
    final targetDate = today.add(Duration(days: daysDiff));
    final dateKey = formatDateKey(targetDate);
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
    lastCheckedDay = formatDateKey(DateTime.now());
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = 0;
    waterGlassesToday = 0;
    await save();
    notifyListeners();
  }
}