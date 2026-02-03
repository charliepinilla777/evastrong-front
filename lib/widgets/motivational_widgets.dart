import 'package:flutter/material.dart';
import '../services/motivational_service.dart';
import '../theme/eva_colors.dart';

/// Widget para mostrar frases motivacionales animadas
class MotivationalCard extends StatefulWidget {
  const MotivationalCard({super.key});

  @override
  State<MotivationalCard> createState() => _MotivationalCardState();
}

class _MotivationalCardState extends State<MotivationalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _currentPhrase = '';
  int _currentPhraseIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _loadNewPhrase();
    _startAnimation();
  }

  void _loadNewPhrase() {
    final phrases = MotivationalPhrases.getRandomPhrases(5);
    setState(() {
      _currentPhrase = phrases[_currentPhraseIndex % phrases.length];
      _currentPhraseIndex++;
    });
  }

  void _startAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  void _changePhrase() {
    _loadNewPhrase();
    _startAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: EvaColors.lightGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: EvaColors.darkPink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _changePhrase,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono animado
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_fadeAnimation.value * 0.2),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: EvaColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: EvaColors.hotPink.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: EvaColors.textOnPink,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Frase motivacional
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          _currentPhrase,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: EvaColors.textDark,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Botón para cambiar frase
                ElevatedButton.icon(
                  onPressed: _changePhrase,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nueva frase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EvaColors.hotPink,
                    foregroundColor: EvaColors.textOnPink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar frases en diferentes estilos
class MotivationalBanner extends StatefulWidget {
  const MotivationalBanner({super.key});

  @override
  State<MotivationalBanner> createState() => _MotivationalBannerState();
}

class _MotivationalBannerState extends State<MotivationalBanner>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _textController;
  String _phrase = '';

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadPhrase();
    _startTextAnimation();
  }

  void _loadPhrase() {
    setState(() {
      _phrase = MotivationalPhrases.getRandomPhrase();
    });
  }

  void _startTextAnimation() {
    _textController.reset();
    _textController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                EvaColors.primaryPink,
                EvaColors.hotPink,
                EvaColors.deepPink,
              ],
              stops: [0.0, (_gradientController.value * 2) % 1.0, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: EvaColors.textOnPink,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'MOTIVACIÓN DEL DÍA',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: EvaColors.textOnPink,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textController,
                    child: Text(
                      _phrase,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: EvaColors.textOnPink,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
