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

  static const int minDailyGoalGlasses = 1;
  static const int maxDailyGoalGlasses = 50;
  static const int minCupVolume = 50;
  static const int maxCupVolume = 1000;

  int dailyGoalGlasses = 8;
  int cupVolume = 250;
  
  int get dailyGoalMl => dailyGoalGlasses * cupVolume; 
  
  int waterGlassesToday = 0;
  List<int> weeklyWaterGlasses = List.filled(7, 0);
  
  bool isDarkMode = true;
  bool isOnboardingCompleted = false;
  
  // ✅ НОВАЯ СТРУКТУРА: Map<String, Map<String, int>>
  Map<String, Map<String, int>> dailyGoalsHistory = {};
  String? lastCheckedDay;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> load() async {
    final prefs = await _preferences;
    
    dailyGoalGlasses = prefs.getInt('dailyGoalGlasses') ?? 8;
    cupVolume = prefs.getInt('cupVolume') ?? 250;
    waterGlassesToday = prefs.getInt('waterGlassesToday') ?? 0;
    isOnboardingCompleted = prefs.getBool('isOnboardingCompleted') ?? false;
    isDarkMode = prefs.getBool('isDarkMode') ?? true;
    
    final saved = prefs.getStringList('weeklyWaterGlasses');
    weeklyWaterGlasses = (saved != null && saved.length == 7)
        ? saved.map((e) => int.tryParse(e) ?? 0).toList()
        : List.filled(7, 0);

    // ✅ ЗАГРУЗКА ИСТОРИИ С ОБРАБОТКОЙ СТАРОГО ФОРМАТА
    final historyJson = prefs.getString('dailyGoalsHistory');
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(historyJson);
        if (decoded is Map) {
          dailyGoalsHistory = decoded.map((key, value) {
            if (value is Map && value.containsKey('g')) {
              return MapEntry(key as String, {
                'g': (value['g'] as num).toInt(),
                'v': (value['v'] as num?)?.toInt() ?? 250,
              });
            } else if (value is num) {
              // Конвертация старых данных (просто число) в новый формат
              return MapEntry(key as String, {
                'g': value.toInt(),
                'v': 250, 
              });
            }
            return MapEntry(key as String, {'g': 0, 'v': 250});
          });
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
        dailyGoalsHistory[key] = {'g': dailyGoalGlasses, 'v': cupVolume};
      }
      await save();
    }

    if (lastCheckedDay == null) {
      dailyGoalGlasses = 8;
      cupVolume = 250;
      lastCheckedDay = formatDateKey(DateTime.now());
      dailyGoalsHistory[lastCheckedDay!] = {'g': dailyGoalGlasses, 'v': cupVolume};
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
        prefs.setInt('dailyGoalGlasses', dailyGoalGlasses),
        prefs.setInt('cupVolume', cupVolume),
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
      dailyGoalsHistory[todayString] = {'g': dailyGoalGlasses, 'v': cupVolume};
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
        dailyGoalsHistory[missedKey] = {'g': dailyGoalGlasses, 'v': cupVolume};
      }
      
      dailyGoalsHistory[yesterdayString] = {'g': dailyGoalGlasses, 'v': cupVolume};
      dailyGoalsHistory[todayString] = {'g': dailyGoalGlasses, 'v': cupVolume};
      
      final cutoffDate = now.subtract(const Duration(days: 90));
      final cutoffString = formatDateKey(cutoffDate);
      dailyGoalsHistory.removeWhere((key, value) => key.compareTo(cutoffString) < 0);
      
      waterGlassesToday = 0;
      lastCheckedDay = todayString;
      
      await save();
      notifyListeners();
    }
  }

  Future<void> setDailyGoal(int glasses) async {
    dailyGoalGlasses = glasses.clamp(minDailyGoalGlasses, maxDailyGoalGlasses);
    final todayString = formatDateKey(DateTime.now());
    final currentVol = dailyGoalsHistory[todayString]?['v'] ?? cupVolume;
    dailyGoalsHistory[todayString] = {'g': dailyGoalGlasses, 'v': currentVol};
    await save();
    notifyListeners();
  }

  Future<void> setCupVolume(int volume) async {
    cupVolume = volume.clamp(minCupVolume, maxCupVolume);
    final todayString = formatDateKey(DateTime.now());
    final currentGlasses = dailyGoalsHistory[todayString]?['g'] ?? dailyGoalGlasses;
    dailyGoalsHistory[todayString] = {'g': currentGlasses, 'v': cupVolume};
    await save();
    notifyListeners();
  }

  int getGoalForWeekDay(int index) {
    final today = DateTime.now();
    final todayIndex = (today.weekday - 1) % 7;
    final daysDiff = index - todayIndex;
    final targetDate = today.add(Duration(days: daysDiff));
    final dateKey = formatDateKey(targetDate);
    return dailyGoalsHistory[dateKey]?['g'] ?? dailyGoalGlasses;
  }

  // ✅ МЕТОД ВОЗВРАЩАЕТ int (не nullable), поэтому ?? в stats_page не нужен
  int getCupVolumeForDate(String dateKey) {
    return dailyGoalsHistory[dateKey]?['v'] ?? cupVolume;
  }

  Future<void> addGlass() async {
    waterGlassesToday++;
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    weeklyWaterGlasses[todayIndex] = waterGlassesToday;
    await save();
    notifyListeners();
  }

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