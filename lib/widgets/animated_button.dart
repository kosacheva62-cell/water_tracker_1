// lib/widgets/animated_button.dart
import 'package:flutter/material.dart';
import '../utils/text_styles.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width;
  final double? height;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _shadowColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _shadowColorAnimation = ColorTween(
      begin: const Color(0x8850FAF1),
      end: const Color(0xCC50FAF1),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    _animationController.forward().then((_) {
      _animationController.animateTo(0.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeIn,
      );
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? 260,
              height: widget.height ?? 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF50FAF1),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: _shadowColorAnimation.value ?? const Color(0x8850FAF1),
                    blurRadius: 16,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Text(
                widget.text,
                // ✅ ЗАМЕНЕНО: Используем TextStyles.button
                style: TextStyles.button,
              ),
            ),
          );
        },
      ),
    );
  }
}