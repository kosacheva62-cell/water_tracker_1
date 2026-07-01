import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

String formatDateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class FFAppState extends ChangeNotifier {
  static final FFAppState _instance = FFAppState._internal();
  factory FFAppState() => _instance;
  FFAppState._internal();

  // 🎯 КОНСТАНТЫ ДЛЯ ЦЕЛИ В МЛ (V2)
  static const int minDailyGoalMl = 500;
  static const int maxDailyGoalMl = 5000;
  static const int dailyGoalStepMl = 100;
  static const int defaultDailyGoalMl = 2000;

  // 🥛 КОНСТАНТЫ ДЛЯ ОБЪЁМА СТАКАНА (V2)
  static const int minGlassSizeMl = 50;
  static const int maxGlassSizeMl = 1000;
  static const int glassSizeStepMl = 50;
  static const int defaultGlassSizeMl = 250;

  // 🎯 Основные настройки
  // ✅ ТЕПЕРЬ ХРАНИМ ЦЕЛЬ В МЛ, А НЕ В СТАКАНАХ
  int dailyGoalMl = defaultDailyGoalMl;
  int glassSizeMl = defaultGlassSizeMl;

  // 📊 Вычисляемые свойства
  int get dailyGoalGlasses => (dailyGoalMl / glassSizeMl).ceil();
  int get waterMlToday => waterGlassesToday * glassSizeMl;
  double get progress => dailyGoalMl > 0 ? (waterMlToday / dailyGoalMl).clamp(0.0, 1.0) : 0.0;
  bool get isGoalReached => waterMlToday >= dailyGoalMl;

  int waterGlassesToday = 0;
  List<int> weeklyWaterGlasses = List.filled(7, 0);

  bool isDarkMode = true;
  bool isOnboardingCompleted = false;
  Map<String, int> dailyGoalsHistory = {};
  String? lastCheckedDay;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> load() async {
    final prefs = await _preferences;

    // 🥛 ЗАГРУЗКА НОВЫХ ПАРАМЕТРОВ
    dailyGoalMl = prefs.getInt('dailyGoalMl') ?? defaultDailyGoalMl;
    glassSizeMl = prefs.getInt('glassSizeMl') ?? defaultGlassSizeMl;
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

    if (dailyGoalsHistory.isEmpty) {
      final today = DateTime.now();
      for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: i));
        final key = formatDateKey(date);
        dailyGoalsHistory[key] = dailyGoalMl;
      }
      await save();
    }

    if (lastCheckedDay == null) {
      lastCheckedDay = formatDateKey(DateTime.now());
      dailyGoalsHistory[lastCheckedDay!] = dailyGoalMl;
      await save();
    }

    final todayIndex = (DateTime.now().weekday - 1) % 7;
    if (waterGlassesToday > weeklyWaterGlasses[todayIndex]) {
      weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    }
  }

  Future<void> save() async {
    try {
      final prefs = await _preferences;
      await Future.wait([
        prefs.setInt('dailyGoalMl', dailyGoalMl),
        prefs.setInt('glassSizeMl', glassSizeMl),
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

  Future<void> checkDayChange() async {
    final now = DateTime.now();
    final todayString = formatDateKey(now);

    if (lastCheckedDay == null) {
      lastCheckedDay = todayString;
      dailyGoalsHistory[todayString] = dailyGoalMl;
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
        dailyGoalsHistory[missedKey] = dailyGoalMl;
      }

      dailyGoalsHistory[yesterdayString] = dailyGoalMl;
      dailyGoalsHistory[todayString] = dailyGoalMl;

      final cutoffDate = now.subtract(const Duration(days: 90));
      final cutoffString = formatDateKey(cutoffDate);
      dailyGoalsHistory.removeWhere((key, value) => key.compareTo(cutoffString) < 0);

      waterGlassesToday = 0;
      lastCheckedDay = todayString;

      await save();
      notifyListeners();
    }
  }

  // 🎯 ИЗМЕНЕНИЕ ЦЕЛИ В МЛ
  Future<void> setDailyGoalMl(int ml) async {
    final rounded = (ml / dailyGoalStepMl).round() * dailyGoalStepMl;
    dailyGoalMl = rounded.clamp(minDailyGoalMl, maxDailyGoalMl);
    final todayString = formatDateKey(DateTime.now());
    dailyGoalsHistory[todayString] = dailyGoalMl;
    await save();
    notifyListeners();
  }

  // 🥛 ИЗМЕНЕНИЕ ОБЪЁМА СТАКАНА
  Future<void> setGlassSize(int ml) async {
    final rounded = (ml / glassSizeStepMl).round() * glassSizeStepMl;
    glassSizeMl = rounded.clamp(minGlassSizeMl, maxGlassSizeMl);
    await save();
    notifyListeners();
  }

  int getGoalForWeekDay(int index) {
    final today = DateTime.now();
    final todayIndex = (today.weekday - 1) % 7;
    final daysDiff = index - todayIndex;
    final targetDate = today.add(Duration(days: daysDiff));
    final dateKey = formatDateKey(targetDate);
    return dailyGoalsHistory[dateKey] ?? dailyGoalMl;
  }

  Future<void> addGlass() async {
    waterGlassesToday++;
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    await save();
    notifyListeners();
  }

  Future<void> completeOnboarding(int goalMl) async {
    await setDailyGoalMl(goalMl);
    isOnboardingCompleted = true;
    lastCheckedDay = formatDateKey(DateTime.now());
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = 0;
    waterGlassesToday = 0;
    await save();
    notifyListeners();
  }
}