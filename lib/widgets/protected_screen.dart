import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:particles_fly/particles_fly.dart';
import '../services/access_control_service.dart';
import '../theme/eva_colors.dart';

class ProtectedScreen extends StatelessWidget {
  final Widget child;
  final String screenName;
  final bool requireSubscription;
  final bool requireAdmin;

  const ProtectedScreen({
    Key? key,
    required this.child,
    required this.screenName,
    this.requireSubscription = true,
    this.requireAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A0050), Color(0xFF1A0030)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == false) {
          return requireAdmin
              ? _AdminDeniedScreen()
              : const _SubscriptionGateScreen();
        }

        return child;
      },
    );
  }

  Future<bool> _checkAccess() async {
    if (requireAdmin) return await AccessControlService.isAdmin();
    if (requireSubscription)
      return await AccessControlService.hasValidSubscription();
    return true;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla de invitación a suscripción — diseño marketing premium
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionGateScreen extends StatefulWidget {
  const _SubscriptionGateScreen();

  @override
  State<_SubscriptionGateScreen> createState() =>
      _SubscriptionGateScreenState();
}

class _SubscriptionGateScreenState extends State<_SubscriptionGateScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _entryCtrl;

  late final Animation<double> _pulseAnim;
  late final Animation<double> _benefit1Opacity;
  late final Animation<Offset> _benefit1Slide;
  late final Animation<double> _benefit2Opacity;
  late final Animation<Offset> _benefit2Slide;
  late final Animation<double> _benefit3Opacity;
  late final Animation<Offset> _benefit3Slide;

  @override
  void initState() {
    super.initState();

    // Corona giratoria — 8s loop
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Pulso del botón CTA — 2s repeat reverse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Fade-in escalonado de beneficios
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _benefit1Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
      ),
    );
    _benefit1Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
    ));

    _benefit2Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
      ),
    );
    _benefit2Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
    ));

    _benefit3Opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );
    _benefit3Slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fondo oscuro premium ────────────────────────────────────────
          AnimateGradient(
            primaryBeginGeometry: const AlignmentDirectional(-1, -1),
            primaryEndGeometry: const AlignmentDirectional(1, 1),
            secondaryBeginGeometry: const AlignmentDirectional(1, -1),
            secondaryEndGeometry: const AlignmentDirectional(-1, 1),
            primaryColors: const [
              Color(0xFF6A0050),
              Color(0xFF3D0030),
              Color(0xFF1A0030),
            ],
            secondaryColors: const [
              Color(0xFF4A0060),
              Color(0xFF2A0040),
              Color(0xFF6A0050),
            ],
            duration: const Duration(seconds: 5),
            child: Container(),
          ),

          // ── Overlay radial cálido ──────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.0,
                  colors: [
                    const Color(0xFFD71E49).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Partículas celebratorias ───────────────────────────────────
          Positioned.fill(
            child: ParticlesFly(
              height: size.height,
              width: size.width,
              connectDots: false,
              numberOfParticles: 35,
              speedOfParticles: 0.5,
              lineColor: EvaColors.vibrantPink.withOpacity(0.08),
              particleColor: Colors.white.withOpacity(0.35),
              awayRadius: 200,
              onTapAnimation: true,
              isRandSize: true,
              isRandomColor: false,
              randColorList: [
                Colors.white.withOpacity(0.35),
                EvaColors.vibrantPink.withOpacity(0.30),
                const Color(0xFFFFD700).withOpacity(0.35),
              ],
            ),
          ),

          // ── Contenido principal ────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo EVA STRONG ──────────────────────────────────
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'EVA',
                            style: GoogleFonts.greatVibes(
                              fontSize: 76,
                              fontWeight: FontWeight.w700,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFF69B4),
                                    Color(0xFFFFB3D9),
                                  ],
                                ).createShader(
                                    const Rect.fromLTWH(0, 0, 180, 70)),
                              shadows: const [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 8,
                                  offset: Offset(2, 2),
                                ),
                                Shadow(
                                  color: Color(0xFFFFD700),
                                  blurRadius: 20,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'STRONG',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 60,
                              fontWeight: FontWeight.w800,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFFFD6EC),
                                    Color(0xFFE8B4FF),
                                  ],
                                ).createShader(
                                    const Rect.fromLTWH(0, 0, 260, 70)),
                              letterSpacing: 4,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 6,
                                  offset: Offset(1, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Social proof pill (DESEO) ─────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: EvaColors.vibrantPink.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter:
                              ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFD700),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Más de 2,400 mujeres ya transformaron su cuerpo',
                                  style: GoogleFonts.raleway(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Corona giratoria (ATENCIÓN) ──────────────────────
                    AnimatedBuilder(
                      animation: _rotationCtrl,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _rotationCtrl.value * 2 * math.pi,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFFF8C00),
                              Color(0xFFFFD700),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.5),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: EvaColors.vibrantPink.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.black87,
                          size: 38,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Headline principal (ATENCIÓN) ─────────────────────
                    Text(
                      'Estás a un paso\nde tu transformación',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Desbloquea el plan diseñado para ti',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.75),
                        letterSpacing: 0.6,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Card de beneficios (INTERÉS) ──────────────────────
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6A0050).withOpacity(0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter:
                              ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 22),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.12),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _BenefitRow(
                                  opacity: _benefit1Opacity,
                                  slide: _benefit1Slide,
                                  text:
                                      'Rutinas ilimitadas adaptadas a tu cuerpo',
                                ),
                                const SizedBox(height: 14),
                                _BenefitRow(
                                  opacity: _benefit2Opacity,
                                  slide: _benefit2Slide,
                                  text:
                                      'Plan de dieta y recetas exclusivas EVA',
                                ),
                                const SizedBox(height: 14),
                                _BenefitRow(
                                  opacity: _benefit3Opacity,
                                  slide: _benefit3Slide,
                                  text:
                                      'Seguimiento de progreso semana a semana',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ── Botón CTA pulsante (ACCIÓN) ───────────────────────
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) {
                        return Transform.scale(
                          scale: _pulseAnim.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFD71E49),
                              Color(0xFFFF69B4),
                              Color(0xFFD71E49),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: EvaColors.vibrantPink.withOpacity(0.55),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: EvaColors.cosmicRed.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            splashColor: Colors.white.withOpacity(0.15),
                            onTap: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 18),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Quiero mi plan ahora',
                                    style: GoogleFonts.raleway(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Urgencia / FOMO ───────────────────────────────────
                    Text(
                      '✦  Oferta especial activa — solo por tiempo limitado  ✦',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        fontSize: 11,
                        color: const Color(0xFFFFD700).withOpacity(0.85),
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Quizás más tarde ──────────────────────────────────
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Quizás más tarde',
                        style: GoogleFonts.raleway(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fila de beneficio con animación ──────────────────────────────────────────
class _BenefitRow extends StatelessWidget {
  final Animation<double> opacity;
  final Animation<Offset> slide;
  final String text;

  const _BenefitRow({
    required this.opacity,
    required this.slide,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: opacity,
      builder: (_, child) {
        return FadeTransition(
          opacity: opacity,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.black87, size: 15),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla de acceso denegado para administradores
// ─────────────────────────────────────────────────────────────────────────────
class _AdminDeniedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD71E49), Color(0xFF800080)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.white.withOpacity(0.85),
                      size: 72,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Acceso Restringido',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Solo administradores pueden\nacceder a esta sección.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Volver',
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
