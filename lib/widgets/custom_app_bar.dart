import 'package:flutter/material.dart';

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
        color: const Color(0xFF0D152A),
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
                          color: const Color(0x9950FAF1), // ← 60% непрозрачности
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                        // ДОПОЛНИТЕЛЬНОЕ СВЕЧЕНИЕ (ЕДВА ЗАМЕТНОЕ)
                        BoxShadow(
                          color: const Color(0x3350FAF1), // ← 20% непрозрачности
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF50FAF1),
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
                    color: Colors.white,
                    fontSize: 26, // ← ТОЧНЫЙ РАЗМЕР 26 ПИКСЕЛЕЙ
                    fontWeight: FontWeight.w500,
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
                color: const Color(0xFFB0B8D0),
                fontSize: 16, // ← ТОЧНЫЙ РАЗМЕР 16 ПИКСЕЛЕЙ (как в навигации)
                fontWeight: FontWeight.w500,
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