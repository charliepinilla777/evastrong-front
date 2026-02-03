import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';
import '../services/motivational_service.dart';

/// Widget dinámico que muestra frases motivacionales animadas
class MotivationalWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final bool showIcon;
  final TextStyle? textStyle;

  const MotivationalWidget({
    super.key,
    this.width,
    this.height,
    this.showIcon = true,
    this.textStyle,
  });

  @override
  State<MotivationalWidget> createState() => _MotivationalWidgetState();
}

class _MotivationalWidgetState extends State<MotivationalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  String _currentPhrase = '';
  int _currentIndex = 0;
  Timer? _phraseTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPhraseRotation();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  void _startPhraseRotation() {
    _updatePhrase();
    _phraseTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _animatePhraseChange();
    });
  }

  void _animatePhraseChange() {
    _controller.reverse().then((_) {
      _updatePhrase();
      _controller.forward();
    });
  }

  void _updatePhrase() {
    setState(() {
      _currentPhrase = MotivationalPhrases.getRandomPhrase();
      _currentIndex = (_currentIndex + 1) % 60; // Total de frases disponibles
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _phraseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      EvaColors.vibrantPink.withOpacity(0.9),
                      EvaColors.cosmicRed.withOpacity(0.8),
                      EvaColors.wellnessPurple.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: EvaColors.vibrantPink.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: EvaColors.cosmicRed.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.showIcon) ...[
                      Icon(
                        _getRandomIcon(),
                        color: Colors.white,
                        size: 40,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      _currentPhrase,
                      textAlign: TextAlign.center,
                      style:
                          widget.textStyle ??
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getRandomIcon() {
    final icons = [
      Icons.fitness_center,
      Icons.favorite,
      Icons.star,
      Icons.local_fire_department,
      Icons.auto_awesome,
      Icons.psychology,
      Icons.self_improvement,
      Icons.sports_gymnastics,
    ];
    return icons[Random().nextInt(icons.length)];
  }
}

/// Widget compacto para frases motivacionales en espacios pequeños
class CompactMotivationalWidget extends StatelessWidget {
  final String? phrase;
  final TextStyle? textStyle;

  const CompactMotivationalWidget({super.key, this.phrase, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final displayPhrase = phrase ?? MotivationalPhrases.getRandomPhrase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EvaColors.vibrantPink.withOpacity(0.8),
            EvaColors.motivationOrange.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              displayPhrase,
              style:
                  textStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para banner motivacional en la parte superior de pantallas
class MotivationalBanner extends StatefulWidget {
  final double height;
  final bool autoRotate;

  const MotivationalBanner({
    super.key,
    this.height = 120,
    this.autoRotate = true,
  });

  @override
  State<MotivationalBanner> createState() => _MotivationalBannerState();
}

class _MotivationalBannerState extends State<MotivationalBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _currentPhrase = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _updatePhrase();
    if (widget.autoRotate) {
      _startAutoRotation();
    }
  }

  void _updatePhrase() {
    setState(() {
      _currentPhrase = MotivationalPhrases.getRandomPhrase();
    });
  }

  void _startAutoRotation() {
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      _controller.reset();
      _updatePhrase();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                EvaColors.vibrantPink,
                EvaColors.cosmicRed,
                EvaColors.wellnessPurple,
              ],
              stops: [
                0.0 + (_animation.value * 0.2),
                0.5,
                1.0 - (_animation.value * 0.2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: EvaColors.vibrantPink.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Colors.white.withOpacity(0.9),
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _currentPhrase,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.star,
                    color: Colors.white.withOpacity(0.9),
                    size: 30,
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
