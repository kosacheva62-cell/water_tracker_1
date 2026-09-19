import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
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
        // ✅ Верхний отступ от часов (безопасный)
        padding: const EdgeInsets.only(top: 12.0), 
        child: Column(
          // ✅ ИЗМЕНЕНО: Start вместо Center
          // Контент начинается сразу после padding, без лишней пустоты сверху
          mainAxisAlignment: MainAxisAlignment.start, 
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentShadow,
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: AppColors.accentSoft,
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
                Text(
                  title,
                  style: TextStyles.regular(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyles.subtitle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            // ✅ Остальное пространство (~26px) теперь автоматически уходит СЮДА, вниз
            // Это и есть та самая "мертвая зона", которую мы хотим компенсировать
          ],
        ),
      ),
    );
  }

  // ✅ ВОЗВРАЩАЕМ БЕЗОПАСНУЮ ВЫСОТУ 80px
  @override
  Size get preferredSize => const Size.fromHeight(80.0); 
}