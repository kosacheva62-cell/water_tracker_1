import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';
import 'widgets/custom_app_bar.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = FFAppState();
  await appState.load();
  await appState.checkDayChange();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔑 ГЛОБАЛЬНЫЙ КОНТРОЛЬ МАСШТАБИРОВАНИЯ ШРИФТОВ (РЕШАЕТ ПРОБЛЕМУ С КРУПНЫМИ ШРИФТАМИ НА HONOR)
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling, // ← АКТУАЛЬНЫЙ МЕТОД (ВМЕСТО УСТАРЕВШЕГО textScaleFactor)
      ),
      child: MaterialApp(
        title: '💧Трекер воды',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Inter', // ✅ ЗАМЕНЕНО: было GoogleFonts.inter().fontFamily
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 57,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
            displayMedium: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 45,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
            displaySmall: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.15,
            ),
            headlineLarge: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            titleLarge: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            titleMedium: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            titleSmall: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            bodyLarge: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            bodySmall: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            labelLarge: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            labelMedium: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
            labelSmall: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              textStyle: WidgetStateProperty.resolveWith((_) => const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.05,
                fontSize: 16,
              )),
            ),
          ),
          tabBarTheme: const TabBarThemeData(
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
              fontSize: 16,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
              fontSize: 14,
            ),
          ),
        ),
        home: const _HomeWrapper(),
      ),
    );
  }
}

// ✅ ЗАДАЧА 3.1: УСЛОВНЫЙ РЕНДЕРИНГ вместо Offstage
class _HomeWrapper extends StatelessWidget {
  const _HomeWrapper();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();
    
    // ✅ Создаётся только нужная страница (экономия памяти)
    if (appState.isOnboardingCompleted) {
      return const MainApp();
    } else {
      return const OnboardingPage();
    }
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    HomePage(),
    StatsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      // 🔑 СТРУКТУРА С МЕСТОМ ПОД РЕКЛАМУ (60 dp)
      body: Column(
        children: [
          // Контент страницы занимает всё доступное пространство НАД рекламным блоком
          Flexible(
            child: _pages[_currentIndex],
          ),
          // 🔑 МЕСТО ПОД РЕКЛАМУ (нейтральное, сливается с фоном)
          Container(
            height: 60,
            color: AppColors.background, // ← ЦВЕТ ОСНОВНОГО ФОНА
            child: const SizedBox.shrink(), // ← ПУСТО (без текста)
          ),
        ],
      ),
      // 🔑 ГРАНИЦА МЕЖДУ РЕКЛАМНЫМ БЛОКОМ И ПАНЕЛЬЮ НАВИГАЦИИ
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.divider,
              width: 1.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Статистика'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
          ],
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.05,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.05,
          ),
          elevation: 0,
        ),
      ),
      extendBody: false,
    );
  }
}