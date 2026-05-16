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
        final key = DateFormat('yyyy-MM-dd').format(date);
        dailyGoalsHistory[key] = dailyGoalGlasses;
      }
      await save();
    }

    if (lastCheckedDay == null) {
      dailyGoalGlasses = 8;
      lastCheckedDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
      dailyGoalsHistory[lastCheckedDay!] = 8;
      await save();
    }

    final todayIndex = (DateTime.now().weekday - 1) % 7;
    if (waterGlassesToday > weeklyWaterGlasses[todayIndex]) {
      weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    }
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

    if (lastCheckedDay != todayString) {
      final yesterday = now.subtract(Duration(days: 1));
      final yesterdayString = DateFormat('yyyy-MM-dd').format(yesterday);
      
      final yesterdayIndex = (yesterday.weekday - 1) % 7;
      weeklyWaterGlasses[yesterdayIndex] = waterGlassesToday;
      
      dailyGoalsHistory[yesterdayString] = dailyGoalGlasses;
      dailyGoalsHistory[todayString] = dailyGoalGlasses;
      
      waterGlassesToday = 0;
      isDoneToday = false;
      lastCheckedDay = todayString;
      
      await save();
    }
  }

  Future<void> setDailyGoal(int glasses) async {
    dailyGoalGlasses = glasses.clamp(1, 50);
    final todayString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    dailyGoalsHistory[todayString] = dailyGoalGlasses;
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
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    if (waterGlassesToday >= dailyGoalGlasses) isDoneToday = true;
    await save();
  }

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