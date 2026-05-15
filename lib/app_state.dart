// lib/app_state.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class FFAppState {
  static final FFAppState _instance = FFAppState._internal();
  factory FFAppState() => _instance;
  FFAppState._internal();

  int dailyGoalGlasses = 8;
  int get dailyGoalMl => dailyGoalGlasses * 250;
  int waterGlassesToday = 0;
  bool isDoneToday = false;
  List<int> weeklyWaterGlasses = List.filled(7, 0);
  bool isDarkMode = true;
  bool isOnboardingCompleted = false;
  DateTime? lastUpdateDate;
  
  // История целей: ключ = 'YYYY-MM-DD', значение = кол-во стаканов
  Map<String, int> dailyGoalsHistory = {};
  String? lastCheckedDay;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
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

    // Загрузка истории целей
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

    // 🔑 ИСПРАВЛЕНИЕ: Если история пуста (первый запуск новой версии), 
    // фиксируем текущую цель для всех дней текущей недели.
    // Это "замораживает" цели прошедших дней.
    if (dailyGoalsHistory.isEmpty) {
      final today = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: i));
        final key = DateFormat('yyyy-MM-dd').format(date);
        dailyGoalsHistory[key] = dailyGoalGlasses;
      }
      await save();
    }

    // Первый запуск приложения вообще
    if (lastCheckedDay == null) {
      dailyGoalGlasses = 8;
      lastCheckedDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayStr = lastCheckedDay!;
      dailyGoalsHistory[todayStr] = 8;
      await save();
    }

    await _migrateOldData();
    
    // 🔑 НОВОЕ: Восстанавливаем пропущенные дни недели
    await _restoreMissedDays();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoalGlasses', dailyGoalGlasses);
    await prefs.setInt('waterGlassesToday', waterGlassesToday);
    await prefs.setBool('isDoneToday', isDoneToday);
    await prefs.setBool('isOnboardingCompleted', isOnboardingCompleted);
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setStringList('weeklyWaterGlasses', weeklyWaterGlasses.map((e) => e.toString()).toList());
    await prefs.setString('lastUpdateDate', lastUpdateDate?.toIso8601String() ?? '');
    await prefs.setString('dailyGoalsHistory', jsonEncode(dailyGoalsHistory));
    await prefs.setString('lastCheckedDay', lastCheckedDay ?? '');
  }

  Future<void> checkDayChange() async {
    final now = DateTime.now();
    final todayString = DateFormat('yyyy-MM-dd').format(now);

    if (lastCheckedDay == null) {
      lastCheckedDay = todayString;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      await save();
      return;
    }

    // Наступил новый день
    if (lastCheckedDay != todayString) {
      final yesterday = now.subtract(Duration(days: 1));
      final yesterdayString = DateFormat('yyyy-MM-dd').format(yesterday);
      
      // Фиксируем цели в истории
      dailyGoalsHistory[yesterdayString] = dailyGoalGlasses;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      
      // Переносим воду вчера в статистику
      final lastIndex = (yesterday.weekday - 1) % 7;
      weeklyWaterGlasses[lastIndex] = waterGlassesToday;
      
      // Сбрасываем воду сегодня
      waterGlassesToday = 0;
      isDoneToday = false;
      lastCheckedDay = todayString;
      
      await save();
    }
  }

  Future<void> setDailyGoal(int glasses) async {
    dailyGoalGlasses = glasses.clamp(1, 50);
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    dailyGoalsHistory[todayString] = dailyGoalGlasses; // Записываем ТОЛЬКО на СЕГОДНЯ
    await save();
  }

  int getGoalForWeekDay(int index) {
    final today = DateTime.now();
    final todayIndex = (today.weekday - 1) % 7;
    final daysDiff = index - todayIndex;
    final targetDate = today.add(Duration(days: daysDiff));
    final dateKey = DateFormat('yyyy-MM-dd').format(targetDate);
    return dailyGoalsHistory[dateKey] ?? dailyGoalGlasses;
  }

  Future<void> addGlass() async {
    waterGlassesToday++;
    if (waterGlassesToday >= dailyGoalGlasses) isDoneToday = true;
    await save();
  }

  Future<void> completeOnboarding(int glasses) async {
    await setDailyGoal(glasses);
    isOnboardingCompleted = true;
    final now = DateTime.now();
    lastUpdateDate = DateTime(now.year, now.month, now.day);
    lastCheckedDay = DateFormat('yyyy-MM-dd').format(now);
    await save();
  }

  Future<void> _migrateOldData() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (lastUpdateDate == null) return;
    final last = DateTime(lastUpdateDate!.year, lastUpdateDate!.month, lastUpdateDate!.day);
    final daysPassed = today.difference(last).inDays;
    if (daysPassed > 7) {
      weeklyWaterGlasses = List.filled(7, 0);
      await save();
      return;
    }
    if (daysPassed >= 1) {
      final lastIndex = (last.weekday - 1) % 7;
      weeklyWaterGlasses[lastIndex] = waterGlassesToday;
      for (int i = 1; i < daysPassed; i++) {
        final missedDate = last.add(Duration(days: i));
        final missedIndex = (missedDate.weekday - 1) % 7;
        weeklyWaterGlasses[missedIndex] = 0;
      }
      await save();
    }
  }

  // 🔑 НОВЫЙ МЕТОД: Восстановление пропущенных дней недели
  // Гарантирует, что все 7 дней текущей недели имеют записи в weeklyWaterGlasses
  // даже если приложение не открывалось несколько дней подряд.
  Future<void> _restoreMissedDays() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayIndex = (today.weekday - 1) % 7; // 0 = Пн, 6 = Вс
    
    // Проверяем каждый день текущей недели (от сегодня назад)
    for (int i = 0; i < 7; i++) {
      final dayIndex = (todayIndex - i + 7) % 7; // Индекс в массиве weeklyWaterGlasses
      final dayDate = today.subtract(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(dayDate);
      
      // Если это не сегодня и данных в массиве нет (0) — убеждаемся, что день есть в истории
      if (i > 0 && weeklyWaterGlasses[dayIndex] == 0) {
        // Если дня нет в истории целей — добавляем его с текущей целью
        if (!dailyGoalsHistory.containsKey(dayKey)) {
          dailyGoalsHistory[dayKey] = dailyGoalGlasses;
        }
        // weeklyWaterGlasses[dayIndex] остаётся 0 — это корректно, если пользователь не пил воду
      }
    }
    
    // Сохраняем изменения, если они были
    await save();
  }
}