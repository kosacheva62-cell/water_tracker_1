import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ ВЕРНУЛ ЭТОТ ИМПОРТ!
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

class _SettingsPageState extends State<SettingsPage> {
  late int _dailyGoalGlasses;
  int _cupVolume = 250;
  bool _initialized = false;

  final List<int> _standardVolumes = [150, 200, 250, 300, 500];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final appState = context.read<FFAppState>();
      _dailyGoalGlasses = appState.dailyGoalGlasses;
      _cupVolume = appState.cupVolume;
      _initialized = true;
    }
  }

  Future<void> _saveSettings() async {
    try {
      await context.read<FFAppState>().setDailyGoal(_dailyGoalGlasses);
      await context.read<FFAppState>().setCupVolume(_cupVolume); 
      
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настройки сохранены'), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      if (!mounted) return;
      // ✅ ОБНОВЛЕНО: Добавлена рекомендация и увеличена длительность
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить настройки. Перезапустите приложение.'), 
          duration: Duration(seconds: 3)
        ),
      );
    }
  }

  void _showCustomVolumeSheet(BuildContext context) {
    final controller = TextEditingController(text: _cupVolume.toString());
    int tempVolume = _cupVolume;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24, right: 24, top: 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Icon(Icons.drag_handle, color: Colors.white38, size: 32)),
            const SizedBox(height: 16),
            Text('Укажите свой объём стакана', 
              style: TextStyles.title(fontSize: 20), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'мл',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                suffixText: 'мл',
                suffixStyle: TextStyle(color: AppColors.accent, fontSize: 24),
              ),
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null && parsed > 0 && parsed < 2000) tempVolume = parsed;
              },
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() => _cupVolume = tempVolume);
                Navigator.pop(ctx);
                controller.dispose();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Применить', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String text, VoidCallback onPressed, double fontSize) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Vibration.vibrate(duration: 30);
        onPressed();
      },
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Center(
          child: Text(text, 
            style: TextStyle(fontSize: fontSize, color: AppColors.accent, fontWeight: FontWeight.w300),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 700;
    final isTinyScreen = screenHeight < 600 && !isTablet;
    final isSmallScreen = screenHeight < 700 && !isTablet;

    // Адаптивные размеры шрифтов и контролов
    final titleFontSize = isTablet ? 32.0 : (isTinyScreen ? 22.0 : (isSmallScreen ? 24.0 : 26.0));
    final topPadding = isTablet ? 16.0 : (isTinyScreen ? 4.0 : 6.0); 
    final horizontalPadding = isTablet ? 40.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 20.0 : 24.0));
    final minusPlusFontSize = isTablet ? 50.0 : (isTinyScreen ? 34.0 : (isSmallScreen ? 37.0 : 40.0));
    final numberFontSize = isTablet ? 80.0 : (isTinyScreen ? 52.0 : (isSmallScreen ? 58.0 : 64.0));
    final goalFontSize = isTablet ? 28.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 21.0 : 22.0));
    final subtitleFontSize = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0));
    final buttonWidth = isTablet ? 320.0 : (isTinyScreen ? 240.0 : (isSmallScreen ? 250.0 : 260.0));

    // УМНЫЕ АДАПТИВНЫЕ ОТСТУПЫ С ЗАЩИТОЙ ОТ СЛИЯНИЯ СВЕЧЕНИЙ
    final spaceAfterTitle = isTablet ? 30.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 18.0 : 24.0)); 
    
    final minSafeGap = 32.0;
    final baseAddition = 10.0; 
    double calculatedGap = spaceAfterTitle + baseAddition;
    if (calculatedGap < minSafeGap) calculatedGap = minSafeGap;
    final spaceAboveSaveButton = calculatedGap;
    
    final spaceBelowSaveButton = isTablet ? 16.0 : (isTinyScreen ? 10.0 : (isSmallScreen ? 10.0 : 14.0));
    final spaceAfterSupportText = isTablet ? 24.0 : (isTinyScreen ? 18.0 : (isSmallScreen ? 18.0 : 20.0));
    final spaceAfterDonateButton = isTablet ? 24.0 : (isTinyScreen ? 18.0 : (isSmallScreen ? 18.0 : 20.0));

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
                    style: TextStyles.title(fontSize: titleFontSize).copyWith(height: 1.1), 
                  ),
                  
                  SizedBox(height: spaceAfterTitle),
                  
                  // ЕДИНАЯ КАРТОЧКА "УМНОЙ ЦЕЛИ"
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.accentShadow, blurRadius: 16, spreadRadius: 2)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _standardVolumes.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              if (index == _standardVolumes.length) {
                                return GestureDetector(
                                  onTap: () => _showCustomVolumeSheet(context),
                                  child: Container(
                                    width: 60, height: 90,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.5),
                                      borderRadius: BorderRadius.circular(16),
                                      color: AppColors.accent.withValues(alpha: 0.05),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit_outlined, color: AppColors.accent, size: 20),
                                        const SizedBox(height: 4),
                                        Text('Ваш\nобъем', 
                                          style: TextStyle(fontSize: 9, color: AppColors.accent, height: 1.1),
                                          textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final volume = _standardVolumes[index];
                              final isSelected = _cupVolume == volume;
                              final glassHeight = 30.0 + (volume / 500) * 30; 

                              return GestureDetector(
                                onTap: () => setState(() => _cupVolume = volume),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36, height: glassHeight,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                          colors: [
                                            AppColors.accent.withValues(alpha: isSelected ? 1.0 : 0.4),
                                            AppColors.accent.withValues(alpha: isSelected ? 0.8 : 0.2),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: isSelected ? AppColors.accent : Colors.white24,
                                          width: isSelected ? 2 : 1.5,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8),
                                          topLeft: Radius.circular(4), topRight: Radius.circular(4),
                                        ),
                                        boxShadow: isSelected ? [
                                          BoxShadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 8)
                                        ] : null,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text('$volume мл', 
                                      style: TextStyle(
                                        fontSize: 11, 
                                        color: isSelected ? AppColors.accent : Colors.white54,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildControlButton('-', () {
                              if (_dailyGoalGlasses > FFAppState.minDailyGoalGlasses) {
                                setState(() => _dailyGoalGlasses--);
                              }
                            }, minusPlusFontSize),
                            const SizedBox(width: 20),
                            Text('$_dailyGoalGlasses', 
                              style: TextStyles.goal(fontSize: numberFontSize).copyWith(color: AppColors.accent)),
                            const SizedBox(width: 20),
                            _buildControlButton('+', () {
                              if (_dailyGoalGlasses < FFAppState.maxDailyGoalGlasses) {
                                setState(() => _dailyGoalGlasses++);
                              }
                            }, minusPlusFontSize),
                          ],
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.only(top: 4), 
                          child: Text('$glassesForm в день', 
                            style: TextStyles.subtitle(fontSize: subtitleFontSize).copyWith(color: Colors.white54)),
                        ),

                        Text(
                          'Ваша цель: ${_dailyGoalGlasses * _cupVolume} мл',
                          style: TextStyles.goal(fontSize: goalFontSize).copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spaceAboveSaveButton),
                  
                  Center(
                    child: AnimatedButton(
                      width: buttonWidth,
                      onPressed: _saveSettings,
                      text: 'Сохранить',
                    ),
                  ),
                  
                  SizedBox(height: spaceBelowSaveButton), 
                  
                  Divider(color: AppColors.divider, thickness: 1),
                  const SizedBox(height: 12), 
                  
                  // БЛОК ПОДДЕРЖКИ
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.8),
                        child: Text(
                          'Это приложение бесплатное и без рекламы. Ваша поддержка поможет ему развиваться',
                          style: TextStyles.subtitle(fontSize: subtitleFontSize).copyWith(height: 1.0), 
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: spaceAfterSupportText), 
                      
                      Container(
                        width: buttonWidth, height: 72, 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30), color: AppColors.card,
                          boxShadow: [BoxShadow(color: AppColors.accentShadow, blurRadius: 16, spreadRadius: 3)],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final url = Uri.parse('https://pay.cloudtips.ru/p/ee11f14f');
                            if (!mounted) return;
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
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
                      SizedBox(height: spaceAfterDonateButton), 
                    ],
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