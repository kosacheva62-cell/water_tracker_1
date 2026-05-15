import 'package:flutter/material.dart';
import '../app_state.dart';
import '../utils/pluralize.dart';

class StatsPage extends StatelessWidget {
  final FFAppState appState;

  const StatsPage({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    // 🔑 ЧЕТЫРЁХУРОВНЕВАЯ АДАПТАЦИЯ: ОПРЕДЕЛЯЕМ КАТЕГОРИЮ ЭКРАНА
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 700;
    final isTinyScreen = screenHeight < 600 && !isTablet;
    final isSmallScreen = screenHeight < 700 && !isTablet;

    // 🔑 АДАПТИВНЫЕ РАЗМЕРЫ ДЛЯ КАЖДОГО УРОВНЯ (4 уровня)
    final titleFontSize = isTablet 
        ? 30.0 
        : (isTinyScreen ? 20.0 : (isSmallScreen ? 22.0 : 24.0));
    final topPadding = isTablet 
        ? 20.0 
        : (isTinyScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0));
    final spaceAfterTitle = isTablet 
        ? 20.0 
        : (isTinyScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0));
    
    final iconSize = isTablet 
        ? 24.0 
        : (isTinyScreen ? 14.0 : (isSmallScreen ? 16.0 : 18.0));
    final spaceAfterIcon = isTablet 
        ? 12.0 
        : (isTinyScreen ? 8.0 : (isSmallScreen ? 9.0 : 10.0));
    final dayNameFontSize = isTablet 
        ? 30.0 
        : (isTinyScreen ? 20.0 : (isSmallScreen ? 22.0 : 24.0));
    final glassesCountFontSize = isTablet 
        ? 26.0 
        : (isTinyScreen ? 16.0 : (isSmallScreen ? 18.0 : 20.0));
    final mlTextFontSize = isTablet 
        ? 18.0 
        : (isTinyScreen ? 12.0 : (isSmallScreen ? 13.0 : 14.0));
    final spaceBetweenDays = isTablet 
        ? 8.0 
        : (isTinyScreen ? 5.0 : (isSmallScreen ? 6.0 : 7.0));
    final horizontalPadding = isTablet 
        ? 40.0 
        : (isTinyScreen ? 16.0 : (isSmallScreen ? 20.0 : 24.0));
    final spaceBeforeIcon = isTablet 
        ? 12.0 
        : (isTinyScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0));

    const List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final todayIndex = (DateTime.now().weekday - 1) % 7;
    // 🔑 УДАЛЕНО: final dailyGoalMl = appState.dailyGoalGlasses * 250; 
    // (теперь цель вычисляется индивидуально для каждого дня)

    // 🔑 УСЛОВНАЯ ПРОКРУТКА КАК РЕЗЕРВНЫЙ МЕХАНИЗМ
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Недельная статистика:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: const Color(0xFF50FAF1),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.05,
                        shadows: [
                          Shadow(
                            color: const Color(0xCC50FAF1),
                            blurRadius: 12,
                            offset: Offset.zero,
                          ),
                        ],
                      ),
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
                    
                    final mlConsumed = glasses * 250;
                    final day = weekDays[index];
                    
                    // 🔑 КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: Получаем цель КОНКРЕТНО для этого дня из истории
                    final dayGoalGlasses = appState.getGoalForWeekDay(index);
                    final dayGoalMl = dayGoalGlasses * 250;
                    
                    final dayNameColor = isToday 
                        ? const Color(0xFF50FAF1) 
                        : (isFutureDay ? const Color(0xFFB0B8D0) : Colors.white);
                    final quantityColor = isToday 
                        ? const Color(0xFF50FAF1) 
                        : (isFutureDay ? const Color(0xFFB0B8D0) : Colors.white);
                    
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: spaceBeforeIcon),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: const Color(0xFF50FAF1),
                                  size: iconSize,
                                ),
                                SizedBox(width: spaceAfterIcon),
                                Text(
                                  day,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: dayNameColor,
                                    fontSize: dayNameFontSize,
                                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                                    letterSpacing: -0.05,
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
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: quantityColor,
                                    fontSize: glassesCountFontSize,
                                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                    letterSpacing: -0.05,
                                  ),
                                ),
                                // 🔑 КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: Используем индивидуальную цель дня
                                Text(
                                  '$mlConsumed из $dayGoalMl мл',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: const Color(0xFFB0B8D0),
                                    fontSize: mlTextFontSize,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.05,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (index < 6) ...[
                          SizedBox(height: spaceBetweenDays),
                          Container(
                            height: 1,
                            color: const Color(0xFF1A283F),
                          ),
                          SizedBox(height: spaceBetweenDays),
                        ],
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}