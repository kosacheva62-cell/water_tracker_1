import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class FFAppState {
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
  bool isDoneToday = false;
  
  // 📊 Недельная статистика (Пн=0, Вт=1, ..., Вс=6)
  List<int> weeklyWaterGlasses = List.filled(7, 0);
  
  // ⚙️ Состояние приложения
  bool isDarkMode = true;
  bool isOnboardingCompleted = false;
  DateTime? lastUpdateDate;
  Map<String, int> dailyGoalsHistory = {};
  String? lastCheckedDay;

  // ✅ НОВОЕ: Кэш экземпляра SharedPreferences
  SharedPreferences? _prefs;

  // ✅ НОВОЕ: Геттер для получения кэшированного экземпляра
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // 🔹 Загрузка данных из SharedPreferences
  Future<void> load() async {
    // ✅ ИСПОЛЬЗУЕМ КЭШ вместо SharedPreferences.getInstance()
    final prefs = await _preferences;
    
    dailyGoalGlasses = prefs.getInt('dailyGoalGlasses') ?? 8;
    waterGlassesToday = prefs.getInt('waterGlassesToday') ?? 0;
    isDoneToday = prefs.getBool('isDoneToday') ?? false;
    isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;
    isDarkMode = prefs.getBool('isDarkMode') ?? true;
    
    final dateStr = prefs.getString('lastUpdateDate');
    lastUpdateDate = dateStr != null ? DateTime.tryParse(dateStr) : null;
    
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
        final key = DateFormat('yyyy-MM-dd').format(date);
        dailyGoalsHistory[key] = dailyGoalGlasses;
      }
      await save();
    }

    // Инициализация lastCheckedDay
    if (lastCheckedDay == null) {
      dailyGoalGlasses = 8;
      lastCheckedDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
      dailyGoalsHistory[lastCheckedDay!] = 8;
      await save();
    }

    // Синхронизация текущего дня с недельным массивом
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    if (waterGlassesToday > weeklyWaterGlasses[todayIndex]) {
      weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    }
  }

  // 💾 Сохранение данных в SharedPreferences (С КЭШЕМ И ПАРАЛЛЕЛЬНЫМИ ОПЕРАЦИЯМИ)
  Future<void> save() async {
    try {
      // ✅ ИСПОЛЬЗУЕМ КЭШ вместо SharedPreferences.getInstance()
      final prefs = await _preferences;
      
      // ✅ ИСПОЛЬЗУЕМ Future.wait для параллельного выполнения всех операций
      await Future.wait([
        prefs.setInt('dailyGoalGlasses', dailyGoalGlasses),
        prefs.setInt('waterGlassesToday', waterGlassesToday),
        prefs.setBool('isDoneToday', isDoneToday),
        prefs.setBool('isOnboardingCompleted', isOnboardingCompleted),
        prefs.setBool('isDarkMode', isDarkMode),
        prefs.setStringList('weeklyWaterGlasses', weeklyWaterGlasses.map((e) => e.toString()).toList()),
        prefs.setString('lastUpdateDate', lastUpdateDate?.toIso8601String() ?? ''),
        prefs.setString('dailyGoalsHistory', jsonEncode(dailyGoalsHistory)),
        prefs.setString('lastCheckedDay', lastCheckedDay ?? ''),
      ]);
    } catch (e) {
      // 🔹 Если сохранение упало — пробрасываем исключение выше,
      // чтобы UI мог показать SnackBar с ошибкой
      throw Exception('Не удалось сохранить данные: $e');
    }
  }

  // 🔄 ПРОВЕРКА СМЕНЫ ДНЯ (ИСПРАВЛЕННАЯ ЛОГИКА)
  Future<void> checkDayChange() async {
    final now = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(now);

    if (lastCheckedDay == null) {
      lastCheckedDay = todayString;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      await save();
      return;
    }

    if (lastCheckedDay != todayString) {
      // 1. Сохраняем итог за вчерашний день
      final yesterday = now.subtract(Duration(days: 1));
      final yesterdayString = DateFormat('yyyy-MM-dd').format(yesterday);
      final yesterdayIndex = (yesterday.weekday - 1) % 7;
      weeklyWaterGlasses[yesterdayIndex] = waterGlassesToday;
      
      // 2. 🆕 ОБНУЛЯЕМ ВСЕ ПРОПУЩЕННЫЕ ДНИ
      final lastCheckedDate = DateTime.parse(lastCheckedDay!);
      final daysDiff = now.difference(lastCheckedDate).inDays;
      
      for (int i = 1; i < daysDiff; i++) {
        final missedDate = lastCheckedDate.add(Duration(days: i));
        final missedIndex = (missedDate.weekday - 1) % 7;
        weeklyWaterGlasses[missedIndex] = 0; // ← Правило: пропущенный день = 0
        
        final missedKey = DateFormat('yyyy-MM-dd').format(missedDate);
        dailyGoalsHistory[missedKey] = dailyGoalGlasses;
      }
      
      // 3. Фиксируем цели для вчерашнего и сегодняшнего дня
      dailyGoalsHistory[yesterdayString] = dailyGoalGlasses;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      
      // 4. Сброс счетчиков текущего дня
      waterGlassesToday = 0;
      isDoneToday = false;
      lastCheckedDay = todayString;
      
      await save();
    }
  }

  // 🎯 Изменение дневной цели (С ИСПОЛЬЗОВАНИЕМ КОНСТАНТ)
  Future<void> setDailyGoal(int glasses) async {
    dailyGoalGlasses = glasses.clamp(minDailyGoalGlasses, maxDailyGoalGlasses);
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    dailyGoalsHistory[todayString] = dailyGoalGlasses;
    await save();
  }

  // 📊 Получение цели для конкретного дня недели (0=Пн, 6=Вс)
  int getGoalForWeekDay(int index) {
    final today = DateTime.now();
    final todayIndex = (today.weekday - 1) % 7;
    final daysDiff = index - todayIndex;
    final targetDate = today.add(Duration(days: daysDiff));
    final dateKey = DateFormat('yyyy-MM-dd').format(targetDate);
    // Если есть сохраненная цель для этого дня → берем её. Иначе → текущую.
    return dailyGoalsHistory[dateKey] ?? dailyGoalGlasses;
  }

  // 💧 Добавление стакана воды
  Future<void> addGlass() async {
    waterGlassesToday++;
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    if (waterGlassesToday >= dailyGoalGlasses) isDoneToday = true;
    await save();
  }

  // 🚀 Завершение онбординга
  Future<void> completeOnboarding(int glasses) async {
    await setDailyGoal(glasses);
    isOnboardingCompleted = true;
    final now = DateTime.now();
    lastUpdateDate = DateTime(now.year, now.month, now.day);
    lastCheckedDay = DateFormat('yyyy-MM-dd').format(now);
    final todayIndex = (now.weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = 0;
    waterGlassesToday = 0;
    isDoneToday = false;
    await save();
  }
}