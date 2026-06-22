import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  const CustomAppBar({
    super.key,
    this.title = 'Трекер воды',
    this.subtitle = 'Следите за вашим водным балансом',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.background,
        height: preferredSize.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Капля со свечением (ЕЩЁ МЕНЬШАЯ ИНТЕНСИВНОСТЬ)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // ОСНОВНОЕ СВЕЧЕНИЕ (ОЧЕНЬ МЯГКОЕ)
                        BoxShadow(
                          color: AppColors.accentShadow, // ← 60% непрозрачности
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                        // ДОПОЛНИТЕЛЬНОЕ СВЕЧЕНИЕ (ЕДВА ЗАМЕТНОЕ)
                        BoxShadow(
                          color: AppColors.accentSoft, // ← 20% непрозрачности
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        AppColors.accent,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/icons/drop_neon.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // КАСТОМНЫЙ СТИЛЬ с точным размером 26 пикселей
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                    fontSize: 26, // ← ТОЧНЫЙ РАЗМЕР 26 ПИКСЕЛЕЙ
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2), // ← УМЕНЬШЕННЫЙ ОТСТУП (было 4)
            // КАСТОМНЫЙ СТИЛЬ с точным размером 16 пикселей (как микротекст)
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
                fontSize: 16, // ← ТОЧНЫЙ РАЗМЕР 16 ПИКСЕЛЕЙ (как в навигации)
                fontWeight: FontWeight.w600,
                letterSpacing: -0.05,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}