import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../app_state.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/goal_stepper.dart';
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

  Future<void> _onSave() async {
    Vibration.vibrate(duration: 50);
    HapticFeedback.lightImpact();
    
    try {
      await context.read<FFAppState>().completeOnboarding(_inputValue);
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

    final titleFontSize = isTablet ? 32.0 : (isTinyScreen ? 22.0 : (isSmallScreen ? 24.0 : 26.0));
    final topPadding = isTablet ? 24.0 : (isTinyScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0));
    final spaceAfterTitle = isTablet ? 36.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 24.0 : 28.0));
    
    final controlWidth = isTablet ? 80.0 : (isTinyScreen ? 56.0 : (isSmallScreen ? 60.0 : 64.0));
    final controlHeight = isTablet ? 80.0 : (isTinyScreen ? 56.0 : (isSmallScreen ? 60.0 : 64.0));
    final minusPlusFontSize = isTablet ? 50.0 : (isTinyScreen ? 36.0 : (isSmallScreen ? 38.0 : 40.0));
    final numberFontSize = isTablet ? 80.0 : (isTinyScreen ? 56.0 : (isSmallScreen ? 60.0 : 64.0));
    final numberContainerWidth = isTablet ? 100.0 : (isTinyScreen ? 72.0 : (isSmallScreen ? 76.0 : 80.0));
    final spaceBetweenControls = isTinyScreen ? 1.0 : 2.0;
    final hintFontSize = isTablet ? 20.0 : (isTinyScreen ? 14.0 : (isSmallScreen ? 15.0 : 16.0));
    
    final spaceAfterInput = isTablet ? 36.0 : (isTinyScreen ? 24.0 : (isSmallScreen ? 26.0 : 28.0));
    final goalFontSize = isTablet ? 28.0 : (isTinyScreen ? 20.0 : (isSmallScreen ? 21.0 : 22.0));
    final spaceAfterGoal = isTablet ? 36.0 : (isTinyScreen ? 24.0 : (isSmallScreen ? 26.0 : 28.0));
    
    final buttonWidth = isTablet ? 320.0 : (isTinyScreen ? 240.0 : (isSmallScreen ? 250.0 : 260.0));
    final buttonHeight = isTablet ? 72.0 : (isTinyScreen ? 56.0 : (isSmallScreen ? 58.0 : 60.0));
    final buttonFontSize = isTablet ? 32.0 : (isTinyScreen ? 24.0 : (isSmallScreen ? 25.0 : 26.0));

    final previewMl = _inputValue * 250;
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
                        'Привет! Какая ваша цель по воде на день?',
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
                          value: _inputValue,
                          min: FFAppState.minDailyGoalGlasses,
                          max: FFAppState.maxDailyGoalGlasses,
                          onChanged: (value) => setState(() => _inputValue = value),
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
                        'Ваша цель: $previewMl мл',
                        style: TextStyles.goal(fontSize: goalFontSize),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spaceAfterGoal),

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