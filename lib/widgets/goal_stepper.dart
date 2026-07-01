import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../utils/app_colors.dart';

class GoalStepper extends StatelessWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final int step;
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
    this.step = 1,
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
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (value - step >= min) {
                      Vibration.vibrate(duration: 30);
                      HapticFeedback.lightImpact();
                      onChanged(value - step);
                    }
                  },
                  child: Container(
                    width: controlWidth,
                    height: controlHeight,
                    alignment: Alignment.center,
                    child: Text(
                      '–',
                      style: TextStyle(
                        fontSize: minusPlusFontSize,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spaceBetweenControls),
                
                // ✅ ВОССТАНОВЛЕНО: используем numberContainerWidth без увеличения
                Container(
                  width: numberContainerWidth,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: numberFontSize,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: spaceBetweenControls),
                
                GestureDetector(
                  onTap: () {
                    if (value + step <= max) {
                      Vibration.vibrate(duration: 30);
                      HapticFeedback.lightImpact();
                      onChanged(value + step);
                    }
                  },
                  child: Container(
                    width: controlWidth,
                    height: controlHeight,
                    alignment: Alignment.center,
                    child: Text(
                      '+',
                      style: TextStyle(
                        fontSize: minusPlusFontSize,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            title,
            style: TextStyle(
              fontSize: hintFontSize,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}