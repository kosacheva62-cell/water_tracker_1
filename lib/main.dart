import 'package:flutter/material.dart';
import 'app_state.dart';
import 'pages/onboarding_page.dart';
import 'pages/home_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';
import 'widgets/custom_app_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = FFAppState();
  await appState.load();
  await appState.checkDayChange();

  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  final FFAppState appState;

  const MyApp({super.key, required this.appState});

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
          scaffoldBackgroundColor: const Color(0xFF0D152A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D152A),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 57,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            displayMedium: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 45,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            displaySmall: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.15,
            ),
            headlineLarge: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            titleLarge: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            titleMedium: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            titleSmall: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            bodyLarge: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            bodySmall: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFFB0B8D0),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            labelLarge: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            labelMedium: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
            labelSmall: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              textStyle: WidgetStateProperty.resolveWith((_) => const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                letterSpacing: -0.05,
                fontSize: 16,
              )),
            ),
          ),
          tabBarTheme: const TabBarThemeData(
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
              fontSize: 16,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
              fontSize: 14,
            ),
          ),
        ),
        home: _HomeWrapper(appState: appState),
      ),
    );
  }
}

class _HomeWrapper extends StatefulWidget {
  final FFAppState appState;

  const _HomeWrapper({required this.appState});

  @override
  State<_HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<_HomeWrapper> {
  late FFAppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = widget.appState;
  }

  void _onDataChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 ИСПОЛЬЗУЕМ Offstage ВМЕСТО УСЛОВНОГО РЕНДЕРИНГА
    // Обе страницы всегда в дереве, но одна скрыта через Offstage
    return Stack(
      children: [
        // Основное приложение (скрыто во время онбординга)
        Offstage(
          offstage: !_appState.isOnboardingCompleted,
          child: MainApp(
            appState: _appState,
            onDataChanged: _onDataChanged,
          ),
        ),
        // Онбординг (скрыт после завершения)
        Offstage(
          offstage: _appState.isOnboardingCompleted,
          child: OnboardingPage(
            appState: _appState,
            onDataChanged: _onDataChanged,
          ),
        ),
      ],
    );
  }
}

class MainApp extends StatefulWidget {
  final FFAppState appState;
  final VoidCallback onDataChanged;

  const MainApp({super.key, required this.appState, required this.onDataChanged});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget Function(FFAppState, VoidCallback)> _pageBuilders = [
    (appState, onDataChanged) => HomePage(appState: appState, onDataChanged: onDataChanged),
    (appState, onDataChanged) => StatsPage(appState: appState),
    (appState, onDataChanged) => SettingsPage(appState: appState, onDataChanged: onDataChanged),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D152A),
      appBar: const CustomAppBar(),
      // 🔑 СТРУКТУРА С МЕСТОМ ПОД РЕКЛАМУ (60 dp)
      body: Column(
        children: [
          // Контент страницы занимает всё доступное пространство НАД рекламным блоком
          Flexible(
            child: _pageBuilders[_currentIndex](widget.appState, widget.onDataChanged),
          ),
          // 🔑 МЕСТО ПОД РЕКЛАМУ (нейтральное, сливается с фоном)
          Container(
            height: 60,
            color: const Color(0xFF0D152A), // ← ЦВЕТ ОСНОВНОГО ФОНА
            child: const SizedBox.shrink(), // ← ПУСТО (без текста)
          ),
        ],
      ),
      // 🔑 ГРАНИЦА МЕЖДУ РЕКЛАМНЫМ БЛОКОМ И ПАНЕЛЬЮ НАВИГАЦИИ
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFF1A283F),
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
          backgroundColor: const Color(0xFF0D152A),
          selectedItemColor: const Color(0xFF50FAF1),
          unselectedItemColor: const Color(0xFFB0B8D0),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.05,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.05,
          ),
          elevation: 0,
        ),
      ),
      extendBody: false,
    );
  }
}