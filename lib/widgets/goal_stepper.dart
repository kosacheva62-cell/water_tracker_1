import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../utils/text_styles.dart';
import '../utils/app_colors.dart';

class GoalStepper extends StatelessWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final double controlWidth;
  final double controlHeight;
  final double minusPlusFontSize;
  final double numberFontSize;
  final double numberContainerWidth;
  final double spaceBetweenControls;
  final double hintFontSize;

  const GoalStepper({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.controlWidth,
    required this.controlHeight,
    required this.minusPlusFontSize,
    required this.numberFontSize,
    required this.numberContainerWidth,
    required this.spaceBetweenControls,
    required this.hintFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (value > min) {
                    Vibration.vibrate(duration: 30);
                    HapticFeedback.lightImpact();
                    onChanged(value - 1);
                  }
                },
                child: Container(
                  width: controlWidth,
                  height: controlHeight,
                  alignment: Alignment.center,
                  child: Text(
                    '–',
                    style: TextStyles.plusMinus(fontSize: minusPlusFontSize),
                  ),
                ),
              ),
              SizedBox(width: spaceBetweenControls),
              Container(
                width: numberContainerWidth,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: TextStyles.number(fontSize: numberFontSize),
                ),
              ),
              SizedBox(width: spaceBetweenControls),
              GestureDetector(
                onTap: () {
                  if (value < max) {
                    Vibration.vibrate(duration: 30);
                    HapticFeedback.lightImpact();
                    onChanged(value + 1);
                  }
                },
                child: Container(
                  width: controlWidth,
                  height: controlHeight,
                  alignment: Alignment.center,
                  child: Text(
                    '+',
                    style: TextStyles.plusMinus(fontSize: minusPlusFontSize),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyles.hint(fontSize: hintFontSize),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}