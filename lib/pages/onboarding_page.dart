import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_state.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/pluralize.dart';
import '../utils/text_styles.dart';
import '../utils/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late int _inputValue;
  late TextEditingController _controller;
  bool _initialized = false;
  
  // ✅ Переменная для выбранного объёма стакана (по умолчанию 250 мл)
  int _selectedCupVolume = 250;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _inputValue = context.read<FFAppState>().dailyGoalGlasses.clamp(
        FFAppState.minDailyGoalGlasses,
        FFAppState.maxDailyGoalGlasses,
      );
      _controller = TextEditingController(text: _inputValue.toString());
      _controller.addListener(_onTextChanged);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    if (text.isEmpty) {
      _inputValue = 8;
      return;
    }
    try {
      final value = int.parse(text);
      _inputValue = value.clamp(
        FFAppState.minDailyGoalGlasses,
        FFAppState.maxDailyGoalGlasses,
      );
    } catch (e) {
      _inputValue = 8;
    }
    setState(() {});
  }

  // ✅ Виджет карточки объёма (копия из настроек)
  Widget _buildGlassIcon(int volume, double height, double fontSize) {
    final isSelected = _selectedCupVolume == volume;
    
    final baseStyle = TextStyles.subtitle(fontSize: fontSize).copyWith(
      height: 0.9, 
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Vibration.vibrate(duration: 30);
        setState(() => _selectedCupVolume = volume);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(
            'assets/icons/glass_$volume.svg',
            height: height,
            colorFilter: ColorFilter.mode(
              isSelected ? AppColors.accent : Colors.white30,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Column(
            children: [
              Text(
                '$volume',
                style: baseStyle.copyWith(
                  color: isSelected ? AppColors.accent : Colors.white54,
                ),
              ),
              Text(
                'мл',
                style: baseStyle.copyWith(
                  color: isSelected ? AppColors.accent : Colors.white54,
                  fontSize: fontSize - 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Виджет кнопки +/- (копия из настроек)
  Widget _buildControlButton(String text, VoidCallback onPressed, double fontSize) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Vibration.vibrate(duration: 30);
        onPressed();
      },
      child: Container(
        width: 64, 
        height: 64,
        decoration: BoxDecoration(
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text, 
            style: TextStyles.plusMinus(fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    Vibration.vibrate(duration: 50);
    HapticFeedback.lightImpact();
    
    try {
      final appState = context.read<FFAppState>();
      // ✅ Сохраняем оба параметра при завершении онбординга
      await appState.setCupVolume(_selectedCupVolume);
      await appState.completeOnboarding(_inputValue);
      await Future.delayed(const Duration(milliseconds: 100));
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

  String _getGlassesForm(int value) {
    return pluralizeGlasses(value).split(' ').last;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 700;
    final isTinyScreen = screenHeight < 600 && !isTablet;
    final isSmallScreen = screenHeight < 700 && !isTablet;

    // ✅ Отступы синхронизированы с другими экранами
    final topPadding = isTablet ? 16.0 : 2.0; 
    
    // Шрифты и размеры для единого блока
    final titleFontSize = isTablet ? 32.0 : (isTinyScreen ? 22.0 : (isSmallScreen ? 24.0 : 26.0));
    
    // ✅ СИНХРОНИЗИРОВАНО: spaceAfterTitle теперь как в настройках
    final spaceAfterTitle = isTablet ? 30.0 : (isTinyScreen ? 16.0 : (isSmallScreen ? 18.0 : 24.0));
    
    final minusPlusFontSize = isTablet ? 50.0 : (isTinyScreen ? 34.0 : (isSmallScreen ? 37.0 : 40.0));
    final numberFontSize = isTablet ? 80.0 : (isTinyScreen ? 52.0 : (isSmallScreen ? 58.0 : 64.0));
    final goalFontSize = isTablet ? 28.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 21.0 : 22.0));
    final subtitleFontSize = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0));
    
    // ✅ СИНХРОНИЗИРОВАНО: spaceAfterInput теперь использует minSafeGap как в настройках
    final minSafeGap = 32.0;
    final baseAddition = 10.0; 
    double calculatedGap = spaceAfterTitle + baseAddition;
    if (calculatedGap < minSafeGap) calculatedGap = minSafeGap;
    final spaceAfterInput = calculatedGap;
    
    final buttonWidth = isTablet ? 320.0 : (isTinyScreen ? 240.0 : (isSmallScreen ? 250.0 : 260.0));
    final buttonHeight = isTablet ? 72.0 : (isTinyScreen ? 56.0 : (isSmallScreen ? 58.0 : 60.0));
    final buttonFontSize = isTablet ? 32.0 : (isTinyScreen ? 24.0 : (isSmallScreen ? 25.0 : 26.0));

    // ✅ Расчёт на основе выбранного объёма
    final previewMl = _inputValue * _selectedCupVolume;
    final glassesForm = _getGlassesForm(_inputValue);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'Трекер воды',
            subtitle: 'Следите за вашим водным балансом',
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(height: topPadding),
                      
                      Text(
                        'Привет! Установите вашу дневную цель по воде',
                        textAlign: TextAlign.center,
                        style: TextStyles.title(fontSize: titleFontSize),
                      ),
                      SizedBox(height: spaceAfterTitle),

                      // ✅ ЕДИНЫЙ БЛОК ВВОДА ЦЕЛИ (идентичен настройкам)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: AppColors.accentShadow, blurRadius: 16, spreadRadius: 2)],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Верхняя часть: Выбор объёма
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Выберите объём стакана',
                                style: TextStyles.goal(fontSize: goalFontSize).copyWith(
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            SizedBox(
                              height: 140, 
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildGlassIcon(150, 52, subtitleFontSize),
                                  _buildGlassIcon(200, 64, subtitleFontSize),
                                  _buildGlassIcon(250, 76, subtitleFontSize),
                                  _buildGlassIcon(300, 88, subtitleFontSize),
                                  _buildGlassIcon(500, 100, subtitleFontSize),
                                ],
                              ),
                            ),

                            // ✅ Отступ между секциями как в настройках (24px)
                            const SizedBox(height: 24),

                            // Нижняя часть: Выбор количества
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Выберите количество стаканов',
                                style: TextStyles.goal(fontSize: goalFontSize).copyWith(
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildControlButton('-', () {
                                  if (_inputValue > FFAppState.minDailyGoalGlasses) {
                                    setState(() => _inputValue--);
                                  }
                                }, minusPlusFontSize),
                                const SizedBox(width: 20),
                                Text('$_inputValue', 
                                  style: TextStyles.number(fontSize: numberFontSize)),
                                const SizedBox(width: 20),
                                _buildControlButton('+', () {
                                  if (_inputValue < FFAppState.maxDailyGoalGlasses) {
                                    setState(() => _inputValue++);
                                  }
                                }, minusPlusFontSize),
                              ],
                            ),
                            
                            // ✅ ИЗМЕНЕНО: top уменьшен с 8 до 4
                            Padding(
                              padding: const EdgeInsets.only(top: 4), 
                              child: Text('$glassesForm по $_selectedCupVolume мл', 
                                style: TextStyles.subtitle(fontSize: subtitleFontSize).copyWith(color: Colors.white54)),
                            ),

                            // Тексты идут вплотную друг к другу, как в Настройках
                            Text(
                              'Ваша цель: $previewMl мл',
                              style: TextStyles.goal(fontSize: goalFontSize).copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: spaceAfterInput),

                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _onSave,
                        child: Container(
                          width: buttonWidth,
                          height: buttonHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentShadow,
                                blurRadius: 16,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Text(
                            'Сохранить',
                            style: TextStyles.button.copyWith(
                              fontSize: buttonFontSize,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}