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
import '../utils/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  late int _dailyGoalMl;
  late int _glassSizeMl;
  late TextEditingController _dailyGoalController;
  late TextEditingController _glassSizeController;
  bool _shouldShowThanksMessage = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final appState = context.read<FFAppState>();
      _dailyGoalMl = appState.dailyGoalMl;
      _glassSizeMl = appState.glassSizeMl;
      _dailyGoalController = TextEditingController(text: _dailyGoalMl.toString());
      _glassSizeController = TextEditingController(text: _glassSizeMl.toString());
      _initialized = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dailyGoalController.dispose();
    _glassSizeController.dispose();
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
          margin: const EdgeInsets.only(bottom: 140, left: 20, right: 20),
          duration: const Duration(seconds: 6),
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.accent, width: 2.0),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.accentMedium, blurRadius: 15, spreadRadius: 2),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.email, color: AppColors.accent, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Если вы отправили нам письмо, мы ответим в течение 3 дней.',
                    style: TextStyles.neon(color: AppColors.accent, fontSize: 19.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> _saveDailyGoal() async {
    try {
      await context.read<FFAppState>().setDailyGoalMl(_dailyGoalMl);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить цель'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _saveGlassSize() async {
    try {
      await context.read<FFAppState>().setGlassSize(_glassSizeMl);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить объём'), duration: Duration(seconds: 2)),
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
    final topPadding = 8.0;
    final horizontalPadding = isTablet ? 24.0 : (isTinyScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0));

    final numberFontSize = isTablet ? 80.0 : (isTinyScreen ? 52.0 : (isSmallScreen ? 58.0 : 64.0));
    final numberContainerWidth = isTablet ? 200.0 : (isTinyScreen ? 130.0 : (isSmallScreen ? 150.0 : 180.0));

    final spaceAfterTitle = isTablet ? 20.0 : (isTinyScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0));
    final spaceAfterInput = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 16.0 : 18.0));
    final hintFontSize = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0));
    final subtitleFontSize = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0));
    final buttonWidth = isTablet ? 320.0 : (isTinyScreen ? 240.0 : (isSmallScreen ? 250.0 : 260.0));

    // 🥛 ДИНАМИЧЕСКИЙ РАСЧЁТ КОЛИЧЕСТВА СТАКАНОВ ДЛЯ ПОДСКАЗКИ
    final glassesCount = (_dailyGoalMl / _glassSizeMl).ceil();
    final glassesForm = pluralizeGlasses(glassesCount).split(' ').last;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.only(top: topPadding, left: horizontalPadding, right: horizontalPadding, bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ═══════════════════════════════════════
                  // 🔹 БЛОК 1: ЦЕЛЬ НА ДЕНЬ (TextField)
                  // ═══════════════════════════════════════
                  Text(
                    'Введите цель на день:',
                    textAlign: TextAlign.center,
                    style: TextStyles.title(fontSize: titleFontSize),
                  ),
                  SizedBox(height: spaceAfterTitle),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.accentShadow, blurRadius: 16, spreadRadius: 3)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              SizedBox(
                                width: numberContainerWidth,
                                child: TextField(
                                  controller: _dailyGoalController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: numberFontSize,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '2000',
                                    hintStyle: TextStyle(
                                      fontSize: numberFontSize,
                                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    final parsed = int.tryParse(value);
                                    if (parsed != null) {
                                      setState(() {
                                        _dailyGoalMl = parsed.clamp(
                                          FFAppState.minDailyGoalMl,
                                          FFAppState.maxDailyGoalMl,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'мл',
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          '$glassesCount $glassesForm по $_glassSizeMl мл',
                          style: TextStyle(
                            fontSize: hintFontSize,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spaceAfterInput + 8),

                  Center(
                    child: AnimatedButton(
                      width: buttonWidth,
                      onPressed: () {
                        Vibration.vibrate(duration: 50);
                        HapticFeedback.lightImpact();
                        _saveDailyGoal();
                      },
                      text: 'Сохранить',
                    ),
                  ),

                  // ═══════════════════════════════════════
                  // 🔹 РАЗДЕЛИТЕЛЬНАЯ ЛИНИЯ 1
                  // ═══════════════════════════════════════
                  const SizedBox(height: 10),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: 0), // ✅ ИЗМЕНЕНО: было 10, стало 0

                  // ═══════════════════════════════════════
                  // 🔹 БЛОК 2: ОБЪЁМ СТАКАНА (TextField)
                  // ═══════════════════════════════════════
                  Text(
                    'Введите объём стакана:',
                    textAlign: TextAlign.center,
                    style: TextStyles.title(fontSize: titleFontSize),
                  ),
                  SizedBox(height: spaceAfterTitle),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.accentShadow, blurRadius: 16, spreadRadius: 3)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              SizedBox(
                                width: numberContainerWidth,
                                child: TextField(
                                  controller: _glassSizeController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: numberFontSize,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '250',
                                    hintStyle: TextStyle(
                                      fontSize: numberFontSize,
                                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    final parsed = int.tryParse(value);
                                    if (parsed != null) {
                                      setState(() {
                                        _glassSizeMl = parsed.clamp(
                                          FFAppState.minGlassSizeMl,
                                          FFAppState.maxGlassSizeMl,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'мл',
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'от ${FFAppState.minGlassSizeMl} до ${FFAppState.maxGlassSizeMl} мл',
                          style: TextStyle(
                            fontSize: hintFontSize,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spaceAfterInput + 8),

                  Center(
                    child: AnimatedButton(
                      width: buttonWidth,
                      onPressed: () {
                        Vibration.vibrate(duration: 50);
                        HapticFeedback.lightImpact();
                        _saveGlassSize();
                      },
                      text: 'Сохранить',
                    ),
                  ),

                  // ═══════════════════════════════════════
                  // 🔹 РАЗДЕЛИТЕЛЬНАЯ ЛИНИЯ 2
                  // ═══════════════════════════════════════
                  const SizedBox(height: 10),
                  Divider(color: AppColors.divider),
                  const SizedBox(height: 0), // ✅ ИЗМЕНЕНО: было 10, стало 0

                  // ═══════════════════════════════════════
                  //  БЛОК 3: СЛУЖБА ПОДДЕРЖКИ
                  // ═══════════════════════════════════════
                  GestureDetector(
                    onTap: () async {
                      final deviceInfo = '''
Устройство: ${Platform.operatingSystem}
Версия ОС: ${Platform.operatingSystemVersion}
Версия приложения: 1.0.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📝 НАПИШИТЕ ЗДЕСЬ ВАШЕ СООБЩЕНИЕ:

''';
                      final encodedBody = deviceInfo.replaceAll(' ', '%20').replaceAll('\n', '%0D%0A');
                      final subject = '"Трекер воды": обратная связь';
                      final encodedSubject = subject.replaceAll(' ', '%20');
                      final mailtoUri = 'mailto:hello.tiana.apps@gmail.com?subject=$encodedSubject&body=$encodedBody';
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