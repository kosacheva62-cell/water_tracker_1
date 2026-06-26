import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../app_state.dart';
import '../utils/pluralize.dart';
import '../utils/text_styles.dart';
import '../widgets/animated_button.dart';
import '../widgets/goal_stepper.dart';
import '../utils/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  late int _dailyGoalGlasses;
  bool _shouldShowThanksMessage = false;
  bool _goalInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_goalInitialized) {
      _dailyGoalGlasses = context.read<FFAppState>().dailyGoalGlasses;
      _goalInitialized = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _shouldShowThanksMessage) {
      _showThanksMessage();
      _shouldShowThanksMessage = false;
    }
  }

  void _showThanksMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 140, 
            left: 20, 
            right: 20,
          ),
          duration: const Duration(seconds: 6),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(
                color: AppColors.accent, 
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentMedium,
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.email, 
                  color: AppColors.accent, 
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Если вы отправили нам письмо, мы ответим в течение 3 дней.',
                    style: TextStyles.neon(
                      color: AppColors.accent,
                      fontSize: 19.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      await context.read<FFAppState>().setDailyGoal(_dailyGoalGlasses);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить настройки'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 700;
    final isTinyScreen = screenHeight < 600 && !isTablet;
    final isSmallScreen = screenHeight < 700 && !isTablet;

    final titleFontSize = isTablet ? 32.0 : (isTinyScreen ? 22.0 : (isSmallScreen ? 24.0 : 26.0));
    final topPadding = isTablet ? 24.0 : (isTinyScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0));
    final horizontalPadding = isTablet ? 40.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 20.0 : 24.0));
    
    final controlWidth = isTablet ? 80.0 : (isTinyScreen ? 52.0 : (isSmallScreen ? 58.0 : 64.0));
    final controlHeight = isTablet ? 80.0 : (isTinyScreen ? 52.0 : (isSmallScreen ? 58.0 : 64.0));
    final minusPlusFontSize = isTablet ? 50.0 : (isTinyScreen ? 34.0 : (isSmallScreen ? 37.0 : 40.0));
    final numberFontSize = isTablet ? 80.0 : (isTinyScreen ? 52.0 : (isSmallScreen ? 58.0 : 64.0));
    final numberContainerWidth = isTablet ? 100.0 : (isTinyScreen ? 68.0 : (isSmallScreen ? 74.0 : 80.0));
    final spaceBetweenControls = isTinyScreen ? 1.0 : 2.0;
    
    final spaceAfterTitle = isTablet ? 36.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 24.0 : 28.0));
    final spaceAfterInput = isTablet ? 36.0 : (isTinyScreen ? 24.0 : (isSmallScreen ? 26.0 : 28.0));
    final spaceAfterGoal = isTablet ? 36.0 : (isTinyScreen ? 24.0 : (isSmallScreen ? 26.0 : 28.0));
    final hintFontSize = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0));
    final goalFontSize = isTablet ? 28.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 21.0 : 22.0));
    
    final subtitleFontSize = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0));
    final buttonWidth = isTablet ? 320.0 : (isTinyScreen ? 240.0 : (isSmallScreen ? 250.0 : 260.0));

    String glassesForm = pluralizeGlasses(_dailyGoalGlasses).split(' ').last;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                left: horizontalPadding,
                right: horizontalPadding,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Установите цель на день:',
                    textAlign: TextAlign.center,
                    style: TextStyles.title(fontSize: titleFontSize),
                  ),
                  SizedBox(height: spaceAfterTitle),
                  
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentShadow,
                          blurRadius: 16,
                          spreadRadius: 3,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: GoalStepper(
                      title: '$glassesForm по 250 мл',
                      value: _dailyGoalGlasses,
                      min: FFAppState.minDailyGoalGlasses,
                      max: FFAppState.maxDailyGoalGlasses,
                      onChanged: (value) => setState(() {
                        _dailyGoalGlasses = value;
                      }),
                      controlWidth: controlWidth,
                      controlHeight: controlHeight,
                      minusPlusFontSize: minusPlusFontSize,
                      numberFontSize: numberFontSize,
                      numberContainerWidth: numberContainerWidth,
                      spaceBetweenControls: spaceBetweenControls,
                      hintFontSize: hintFontSize,
                    ),
                  ),
                  SizedBox(height: spaceAfterInput),
                  
                  Text(
                    'Ваша цель: ${_dailyGoalGlasses * 250} мл',
                    style: TextStyles.goal(fontSize: goalFontSize),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spaceAfterGoal),
                  
                  Center(
                    child: AnimatedButton(
                      width: buttonWidth,
                      onPressed: () {
                        Vibration.vibrate(duration: 50);
                        HapticFeedback.lightImpact();
                        _saveSettings();
                      },
                      text: 'Сохранить',
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: 16),
                  
                  GestureDetector(
                    onTap: () async {
                      final deviceInfo = '''
Устройство: ${Platform.operatingSystem}
Версия ОС: ${Platform.operatingSystemVersion}
Версия приложения: 1.0.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 НАПИШИТЕ ЗДЕСЬ ВАШЕ СООБЩЕНИЕ:

''';
                      
                      final encodedBody = deviceInfo
                          .replaceAll(' ', '%20')
                          .replaceAll('\n', '%0D%0A');
                      
                      final subject = '"Трекер воды": обратная связь';
                      final encodedSubject = subject.replaceAll(' ', '%20');
                      
                      final mailtoUri = 'mailto:hello.tiana.apps@gmail.com'
                          '?subject=$encodedSubject'
                          '&body=$encodedBody';
                      
                      final uri = Uri.parse(mailtoUri);
                      
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                        _shouldShowThanksMessage = true;
                      } else {
                        if (!mounted) return;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Не удалось открыть почтовый клиент')),
                          );
                        }
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Написать в службу поддержки',
                          style: TextStyles.subtitle(fontSize: subtitleFontSize),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email,
                              color: AppColors.accent,
                              size: isTablet ? 22.0 : (isTinyScreen ? 15.0 : (isSmallScreen ? 16.0 : 18.0)),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'hello.tiana.apps@gmail.com',
                              style: TextStyles.subtitle(fontSize: subtitleFontSize),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}