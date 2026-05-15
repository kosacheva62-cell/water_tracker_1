import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../app_state.dart'; 
import '../utils/pluralize.dart';
import '../widgets/animated_button.dart';

class HomePage extends StatefulWidget {
  final FFAppState appState;
  final VoidCallback onDataChanged;

  const HomePage({super.key, required this.appState, required this.onDataChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _rainController;
  List<_ConfettiParticle> _particles = [];
  bool _showRain = false;

  @override
  void initState() {
    super.initState();
    
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showRain = false);
        _rainController.reset();
      }
    });
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
  }

  // 🔑 Запуск дождя из 🎉 — 60 ЭМОДЗИ, ФИКСИРОВАННАЯ НЕПРОЗРАЧНОСТЬ
  void _startConfettiRain() {
    // 🎨 НАСТРАИВАЕМЫЕ ПАРАМЕТРЫ АНИМАЦИИ
    const particleCount = 60;           // 🔑 УВЕЛИЧЕНО: 60 эмодзи (было 30)
    const maxDelay = 0.5;               // Макс. задержка появления в сек
    const minOpacity = 1.0;             // 🔑 ФИКСИРОВАННАЯ: 100% непрозрачность
    const maxOpacity = 1.0;             // 🔑 ФИКСИРОВАННАЯ: 100% непрозрачность
    const minScale = 0.8;               // Мин. размер эмодзи
    const maxScale = 1.4;               // Макс. размер эмодзи
    const fallSpeed = 0.75;             // Скорость падения для всех

    setState(() {
      _showRain = true;
      _particles = List.generate(particleCount, (index) => _ConfettiParticle(
        x: Random().nextDouble(),
        delay: Random().nextDouble() * maxDelay,
        speed: fallSpeed,
        scale: minScale + Random().nextDouble() * (maxScale - minScale),
        rotation: 0.0,                  // Без вращения
        minOpacity: minOpacity,         // 🔑 Фиксированная непрозрачность
        maxOpacity: maxOpacity,         // 🔑 Фиксированная непрозрачность
      ));
    });
    
    _rainController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 700;
    final isTinyScreen = screenHeight < 600 && !isTablet;
    final isSmallScreen = screenHeight < 700 && !isTablet;

    // 🔑 Адаптивные размеры
    final circleSize = isTablet ? 300.0 : (isTinyScreen ? 160.0 : (isSmallScreen ? 200.0 : 240.0));
    final ringSize = isTablet ? 285.0 : (isTinyScreen ? 150.0 : (isSmallScreen ? 190.0 : 228.0));
    final ringWidth = isTablet ? 20.0 : (isTinyScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0));
    final centerCircleSize = isTablet ? 265.0 : (isTinyScreen ? 138.0 : (isSmallScreen ? 176.0 : 212.0));
    final percentFontSize = isTablet ? 72.0 : (isTinyScreen ? 40.0 : (isSmallScreen ? 48.0 : 56.0));
    
    // 🔑 УВЕЛИЧЕНО: Отступы для визуального соответствия другим страницам
    final topPadding = isTablet 
        ? 32.0      // было 24.0
        : (isTinyScreen ? 16.0 : (isSmallScreen ? 20.0 : 24.0));  // было 12.0/14.0/16.0
    
    final spaceAfterCircle = isTablet ? 32.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 18.0 : 24.0));
    final spaceBetweenTexts = isTinyScreen ? 2.0 : 2.0;
    final spaceAfterMl = isTablet ? 16.0 : (isTinyScreen ? 10.0 : (isSmallScreen ? 10.0 : 14.0));
    final spaceAfterButton = isTablet ? 16.0 : (isTinyScreen ? 10.0 : (isSmallScreen ? 10.0 : 14.0));
    
    final glassesTextFontSize = isTablet ? 28.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 21.0 : 22.0));
    final mlTextFontSize = isTablet ? 26.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 21.0 : 22.0));
    final congratsFontSize = isTablet ? 30.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 22.0 : 24.0));

    // 🔑 Адаптивная ширина кнопки (как в onboarding_page.dart)
    final buttonWidth = isTablet 
        ? 320.0 
        : (isTinyScreen ? 240.0 : (isSmallScreen ? 250.0 : 260.0));

    final progress = widget.appState.dailyGoalGlasses > 0
        ? (widget.appState.waterGlassesToday / widget.appState.dailyGoalGlasses).clamp(0.0, 1.0)
        : 0.0;
    
    final isDone = widget.appState.waterGlassesToday >= widget.appState.dailyGoalGlasses;
    final percent = (progress * 100).floor();
    final glassesGenitive = pluralizeGlassesGenitive(widget.appState.dailyGoalGlasses);
    final currentMl = widget.appState.waterGlassesToday * 250;
    final goalMlValue = widget.appState.dailyGoalGlasses * 250;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding, bottom: 16),
                  child: Align(  // ✅ topCenter: центр по горизонтали, верх по вертикали
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(  // ✅ Ограничение ширины на планшетах
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 600 : double.infinity,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Внешнее свечение (прогресс-круг)
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x8850FAF1),
                                  blurRadius: 16,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: ringSize,
                                  height: ringSize,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: ringWidth,
                                    valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF50FAF1)),
                                    backgroundColor: const Color(0xFF143A47),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Container(
                                  width: centerCircleSize,
                                  height: centerCircleSize,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0D152A),
                                  ),
                                ),
                                Text(
                                  '$percent%',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: const Color(0xFF50FAF1),
                                    fontSize: percentFontSize,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.15,
                                    shadows: [
                                      Shadow(
                                        color: const Color(0xCC50FAF1),
                                        blurRadius: 12,
                                        offset: Offset.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: spaceAfterCircle),
                          
                          Text(
                            'Выпито: ${widget.appState.waterGlassesToday} из ${widget.appState.dailyGoalGlasses} $glassesGenitive',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: glassesTextFontSize,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.05,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spaceBetweenTexts),
                          
                          Text(
                            '$currentMl мл из $goalMlValue мл',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: const Color(0xFFB0B8D0),
                              fontSize: mlTextFontSize,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.05,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spaceAfterMl),
                          
                          // 🔑 Кнопка с адаптивной фиксированной шириной
                          Center(
                            child: AnimatedButton(
                              width: buttonWidth,  // ✅ Адаптивная ширина
                              onPressed: () {
                                final willCompleteGoal = widget.appState.dailyGoalGlasses > 0 
                                    && widget.appState.waterGlassesToday + 1 >= widget.appState.dailyGoalGlasses;
                                
                                if (willCompleteGoal) {
                                  _startConfettiRain();
                                  Vibration.vibrate(duration: 3000);
                                  HapticFeedback.mediumImpact();
                                } else {
                                  Vibration.vibrate(duration: 50);
                                  HapticFeedback.mediumImpact();
                                }
                                
                                widget.appState.addGlass();
                                widget.onDataChanged();
                              },
                              text: '+1 стакан',
                            ),
                          ),
                          SizedBox(height: spaceAfterButton),
                          
                          Text(
                            isDone
                                ? 'Поздравляю, ваша цель на сегодня достигнута!🎉🎉🎉'
                                : 'Продолжайте, ваша цель ещё не достигнута!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: isDone ? const Color(0xFF50FAF1) : const Color(0xFFB0B8D0),
                              fontSize: congratsFontSize,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.05,
                              shadows: isDone
                                  ? [
                                      Shadow(
                                        color: const Color(0xCC50FAF1),
                                        blurRadius: 12,
                                        offset: Offset.zero,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 🔑 Дождь из 🎉
            if (_showRain)
              AnimatedBuilder(
                animation: _rainController,
                builder: (context, child) {
                  return Stack(
                    children: _particles.map((particle) {
                      final progress = (_rainController.value - particle.delay).clamp(0.0, 1.0);
                      final opacity = 1.0; 
                      final top = progress * particle.speed * MediaQuery.of(context).size.height;
                      
                      return Positioned(
                        left: particle.x * MediaQuery.of(context).size.width,
                        top: top,
                        child: Opacity(
                          opacity: opacity,
                          child: Text(
                            '🎉',
                            style: TextStyle(fontSize: 24 * particle.scale),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x, delay, speed, scale, rotation;
  final double minOpacity, maxOpacity;
  
  _ConfettiParticle({
    required this.x, 
    required this.delay, 
    required this.speed, 
    required this.scale, 
    required this.rotation,
    this.minOpacity = 0.0,
    this.maxOpacity = 1.0,
  });
}