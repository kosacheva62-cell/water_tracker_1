import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../app_state.dart';
import '../utils/pluralize.dart';
import '../utils/text_styles.dart';
import '../widgets/animated_button.dart';
import '../utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  void _startConfettiRain() {
    const particleCount = 25;
    const maxDelay = 0.5;
    const minScale = 1.5;
    const maxScale = 2.5;
    const fallSpeed = 0.75;

    setState(() {
      _showRain = true;
      _particles = List.generate(particleCount, (index) => _ConfettiParticle(
        x: (index + Random().nextDouble()) / particleCount,
        delay: Random().nextDouble() * maxDelay,
        speed: fallSpeed,
        scale: minScale + Random().nextDouble() * (maxScale - minScale),
        rotation: 0.0,
      ));
    });
    _rainController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();
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
    final topPadding = isTablet ? 32.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 20.0 : 24.0));
    final spaceAfterCircle = isTablet ? 32.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 18.0 : 24.0));
    final spaceBetweenTexts = 2.0;
    final spaceAfterMl = isTablet ? 16.0 : (isTinyScreen ? 10.0 : (isSmallScreen ? 10.0 : 14.0));
    final spaceAfterButton = isTablet ? 16.0 : (isTinyScreen ? 10.0 : (isSmallScreen ? 10.0 : 14.0));
    final glassesTextFontSize = isTablet ? 28.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 21.0 : 22.0));
    final mlTextFontSize = isTablet ? 26.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 21.0 : 22.0));
    final congratsFontSize = isTablet ? 30.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 22.0 : 24.0));
    final buttonWidth = isTablet ? 320.0 : (isTinyScreen ? 240.0 : (isSmallScreen ? 250.0 : 260.0));

    // 🥛 ИСПОЛЬЗУЕМ НОВЫЕ ГЕТТЕРЫ ИЗ APP_STATE
    final progress = appState.progress;
    final isDone = appState.isGoalReached;
    final percent = (progress * 100).floor();
    final currentMl = appState.waterMlToday;
    final goalMl = appState.dailyGoalMl;
    
    // Для отображения стаканов (визуальная подсказка)
    final glassesCount = appState.waterGlassesToday;
    final goalGlasses = appState.dailyGoalGlasses;
    final glassesGenitive = pluralizeGlassesGenitive(goalGlasses);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding, bottom: 16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppColors.accentShadow, blurRadius: 16, spreadRadius: 3)],
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
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                                    backgroundColor: AppColors.progressBackground,
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Container(
                                  width: centerCircleSize,
                                  height: centerCircleSize,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.background),
                                ),
                                Text(
                                  '$percent%',
                                  style: TextStyles.neon(color: AppColors.accent, fontSize: percentFontSize, letterSpacing: -0.15),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: spaceAfterCircle),

                          // 🥛 ТЕКСТ С СТАКАНАМИ (визуальная подсказка)
                          Text(
                            'Выпито: $glassesCount из $goalGlasses $glassesGenitive',
                            style: TextStyles.regular(color: AppColors.textPrimary, fontSize: glassesTextFontSize),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spaceBetweenTexts),

                          // 🥛 ОСНОВНОЙ ТЕКСТ В МЛ
                          Text(
                            '$currentMl мл из $goalMl мл',
                            style: TextStyles.regular(color: AppColors.textSecondary, fontSize: mlTextFontSize),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spaceAfterMl),

                          Center(
                            child: AnimatedButton(
                              width: buttonWidth,
                              onPressed: () async {
                                try {
                                  final state = context.read<FFAppState>();
                                  final willCompleteGoal = !state.isGoalReached && 
                                      (state.waterMlToday + state.glassSizeMl) >= state.dailyGoalMl;

                                  if (willCompleteGoal) {
                                    _startConfettiRain();
                                    await Vibration.vibrate(duration: 1000);
                                    HapticFeedback.mediumImpact();
                                  } else {
                                    await Vibration.vibrate(duration: 50);
                                    HapticFeedback.mediumImpact();
                                  }
                                  await state.addGlass();
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Не удалось сохранить данные'), duration: Duration(seconds: 2)),
                                  );
                                }
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
                            style: TextStyles.base.copyWith(
                              color: isDone ? AppColors.accent : AppColors.textSecondary,
                              fontSize: congratsFontSize,
                              shadows: isDone ? [Shadow(color: AppColors.accentGlow, blurRadius: 12, offset: Offset.zero)] : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (_showRain)
              AnimatedBuilder(
                animation: _rainController,
                builder: (context, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: _particles.map((particle) {
                          final animProgress = (_rainController.value - particle.delay).clamp(0.0, 1.0);
                          final top = animProgress * particle.speed * constraints.maxHeight;
                          final emojiWidth = 24 * particle.scale;
                          final leftPos = particle.x * constraints.maxWidth - emojiWidth / 2;
                          return Positioned(
                            left: leftPos,
                            top: top,
                            child: Opacity(
                              opacity: 1.0,
                              child: Text('🎉', style: TextStyles.emoji(fontSize: 24 * particle.scale)),
                            ),
                          );
                        }).toList(),
                      );
                    },
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
  _ConfettiParticle({required this.x, required this.delay, required this.speed, required this.scale, required this.rotation});
}