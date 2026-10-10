import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import '../app_state.dart';
import '../utils/pluralize.dart';
import '../utils/text_styles.dart';
import '../utils/app_colors.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with WidgetsBindingObserver {
  bool _shouldShowThanksMessage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Если вы отправили нам письмо, мы ответим в течение 3 дней.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 700;
    // ✅ ИЗМЕНЕНО: упрощенная логика отступа (2px для телефонов, 16px для планшетов)
    final isTinyScreen = screenHeight < 600 && !isTablet;
    final isSmallScreen = screenHeight < 700 && !isTablet;

    final titleFontSize = isTablet ? 30.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 22.0 : 24.0));
    final topPadding = isTablet ? 16.0 : 2.0; 
    final spaceAfterTitle = isTablet ? 20.0 : (isTinyScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0));
    final iconSize = isTablet ? 24.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 16.0 : 18.0));
    final spaceAfterIcon = isTablet ? 12.0 : (isTinyScreen ? 8.0 : (isSmallScreen ? 9.0 : 10.0));
    final dayNameFontSize = isTablet ? 30.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 22.0 : 24.0));
    final glassesCountFontSize = isTablet ? 26.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 18.0 : 20.0));
    final mlTextFontSize = isTablet ? 18.0 : (isTinyScreen ? 12.0 : (isSmallScreen ? 13.0 : 14.0));
    
    final spaceBetweenDays = isTablet ? 8.0 : (isTinyScreen ? 5.0 : (isSmallScreen ? 6.0 : 7.0));
    
    final horizontalPadding = isTablet ? 40.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 20.0 : 24.0));
    final spaceBeforeIcon = isTablet ? 12.0 : (isTinyScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0));
    final subtitleFontSize = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0));

    final bottomPadding = isTinyScreen ? 80.0 : (isSmallScreen ? 60.0 : 16.0);

    // Переменные для блока поддержки
    final buttonWidth = isTablet ? 320.0 : (isTinyScreen ? 240.0 : (isSmallScreen ? 250.0 : 260.0));
    final spaceAfterDonateButton = isTablet ? 24.0 : (isTinyScreen ? 18.0 : (isSmallScreen ? 18.0 : 20.0));
    final spaceAfterSupportText = isTablet ? 24.0 : (isTinyScreen ? 18.0 : (isSmallScreen ? 18.0 : 20.0));

    const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final todayIndex = (DateTime.now().weekday - 1) % 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: topPadding,
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: bottomPadding, 
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Недельная статистика:',
                    style: TextStyles.title(fontSize: titleFontSize),
                  ),
                ),
                SizedBox(height: spaceAfterTitle),
                
                ...List.generate(7, (index) {
                  final isToday = index == todayIndex;
                  final isFutureDay = index > todayIndex;
                  
                  final glasses = isFutureDay 
                      ? 0 
                      : (isToday 
                          ? appState.waterGlassesToday 
                          : appState.weeklyWaterGlasses[index]);
                  
                  int cupVolumeForThisDay;
                  if (isToday || isFutureDay) {
                    cupVolumeForThisDay = appState.cupVolume;
                  } else {
                    final dateKey = _getDateKeyForWeekDay(index);
                    cupVolumeForThisDay = appState.getCupVolumeForDate(dateKey);
                  }

                  final mlConsumed = glasses * cupVolumeForThisDay;
                  final day = weekDays[index];
                  
                  final dayGoalGlasses = appState.getGoalForWeekDay(index);
                  
                  int dayGoalCupVolume;
                  if (isToday || isFutureDay) {
                    dayGoalCupVolume = appState.cupVolume;
                  } else {
                    final dateKey = _getDateKeyForWeekDay(index);
                    dayGoalCupVolume = appState.getCupVolumeForDate(dateKey);
                  }
                      
                  final dayGoalMl = dayGoalGlasses * dayGoalCupVolume;
                  
                  final dayNameColor = isToday 
                      ? AppColors.accent 
                      : (isFutureDay ? AppColors.textSecondary : AppColors.textPrimary);
                  final quantityColor = isToday 
                      ? AppColors.accent 
                      : (isFutureDay ? AppColors.textSecondary : AppColors.textPrimary);
                  
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: spaceBeforeIcon),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.water_drop, color: AppColors.accent, size: iconSize),
                              SizedBox(width: spaceAfterIcon),
                              Text(
                                day,
                                style: TextStyles.base.copyWith(
                                  color: dayNameColor,
                                  fontSize: dayNameFontSize,
                                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$glasses ${pluralizeGlasses(glasses)}',
                                style: TextStyles.base.copyWith(
                                  color: quantityColor,
                                  fontSize: glassesCountFontSize,
                                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$mlConsumed из $dayGoalMl мл',
                                style: TextStyles.subtitle(fontSize: mlTextFontSize),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (index < 6) ...[
                        SizedBox(height: spaceBetweenDays),
                        Container(height: 1, color: AppColors.divider),
                        SizedBox(height: spaceBetweenDays),
                      ],
                    ],
                  );
                }),

                SizedBox(height: spaceBetweenDays), 
                Divider(color: AppColors.divider, thickness: 1),
                SizedBox(height: spaceAfterSupportText), 
                
                // Блок поддержки
                Column(
                  children: [
                    // Кнопка "Поддержать"
                    Container(
                      width: buttonWidth, height: 72, 
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30), color: AppColors.card,
                        boxShadow: [BoxShadow(color: AppColors.accentShadow, blurRadius: 16, spreadRadius: 3)],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          
                          final url = Uri.parse('https://pay.cloudtips.ru/p/ee11f14f');
                          if (!mounted) return;
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Не удалось открыть ссылку'), duration: Duration(seconds: 2)),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, foregroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0, padding: EdgeInsets.zero,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Поддержать',
                              style: TextStyle(
                                fontSize: isTablet ? 24.0 : (isTinyScreen ? 18.0 : (isSmallScreen ? 20.0 : 22.0)),
                                fontWeight: FontWeight.w600, color: AppColors.accent, height: 1.0,
                                shadows: [Shadow(color: AppColors.accent.withValues(alpha: 0.7), blurRadius: 12, offset: Offset.zero)],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('приложение ',
                                style: TextStyle(
                                  fontSize: isTablet ? 24.0 : (isTinyScreen ? 18.0 : (isSmallScreen ? 20.0 : 22.0)),
                                  fontWeight: FontWeight.w600, color: AppColors.accent, height: 1.0,
                                  shadows: [Shadow(color: AppColors.accent.withValues(alpha: 0.7), blurRadius: 12, offset: Offset.zero)],
                                ),
                              ),
                              Text('❤️', style: TextStyle(fontSize: 28, color: Colors.redAccent, height: 1.0)),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    
                    // Отступ между кнопкой и текстом
                    SizedBox(height: spaceAfterDonateButton), 
                    
                    // Текст под кнопкой
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.8),
                      child: Text(
                        'Это приложение бесплатное и без рекламы. Ваша поддержка поможет ему развиваться',
                        style: TextStyles.subtitle(fontSize: subtitleFontSize).copyWith(height: 1.0), 
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Отступ между текстом "Это..." и Divider под ним
                    SizedBox(height: spaceBetweenDays), 
                    
                    // Разделительная линия между текстом и "Написать разработчику"
                    Divider(color: AppColors.divider, thickness: 1),
                    
                    // Отступ между Divider и текстом "Написать разработчику..."
                    SizedBox(height: spaceBetweenDays), 
                  ],
                ),

                // Блок "Написать разработчику"
                Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      
                      final deviceInfo = '''
Устройство: ${Platform.operatingSystem}
Версия ОС: ${Platform.operatingSystemVersion}
Версия приложения: 1.0.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 НАПИШИТЕ ЗДЕСЬ ВАШЕ СООБЩЕНИЕ:

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
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Не удалось открыть почтовый клиент'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Написать разработчику приложения',
                          style: TextStyles.subtitle(fontSize: subtitleFontSize).copyWith(height: 1.0), 
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2), 
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.email, color: AppColors.accent,
                              size: isTablet ? 22.0 : (isTinyScreen ? 15.0 : (isSmallScreen ? 16.0 : 18.0))),
                            const SizedBox(width: 4),
                            Text('hello.tiana.apps@gmail.com',
                              style: TextStyles.subtitle(fontSize: subtitleFontSize).copyWith(height: 1.0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDateKeyForWeekDay(int index) {
    final today = DateTime.now();
    final todayIndex = (today.weekday - 1) % 7;
    final daysDiff = index - todayIndex;
    final targetDate = today.add(Duration(days: daysDiff));
    return '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
  }
}