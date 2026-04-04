import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_gradient/animate_gradient.dart';
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
                  colors: [Color(0xFFFF69B4), Color(0xFF800080)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == false) {
          return requireAdmin
              ? _AdminDeniedScreen()
              : _SubscriptionGateScreen();
        }

        return child;
      },
    );
  }

  Future<bool> _checkAccess() async {
    if (requireAdmin) return await AccessControlService.isAdmin();
    if (requireSubscription) return await AccessControlService.hasValidSubscription();
    return true;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pantalla de acceso restringido por suscripción
// ─────────────────────────────────────────────────────────────────────────────
class _SubscriptionGateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo degradado animado — igual que la pantalla principal
          AnimateGradient(
            primaryBeginGeometry: const AlignmentDirectional(0, 1),
            primaryEndGeometry: const AlignmentDirectional(0, 2),
            secondaryBeginGeometry: const AlignmentDirectional(2, 0),
            secondaryEndGeometry: const AlignmentDirectional(0, -0.8),
            textDirectionForGeometry: TextDirection.rtl,
            primaryColors: const [
              Color(0xFFFF69B4),
              Color(0xFFE91E63),
              Color(0xFFFFFFFF),
            ],
            secondaryColors: const [
              Color(0xFFFFFFFF),
              Color(0xFF9C27B0),
              Color(0xFF800080),
            ],
            child: Container(),
          ),

          // Contenido centrado
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
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
                              fontSize: 80,
                              fontWeight: FontWeight.w700,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [Colors.white, Color(0xFFFFD6EC)],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 180, 70),
                                ),
                              shadows: [
                                Shadow(
                                  color: Colors.white.withOpacity(0.6),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'STRONG',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 64,
                              fontWeight: FontWeight.w800,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [Colors.white, Color(0xFFE8B4FF)],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 260, 70),
                                ),
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Línea decorativa ─────────────────────────────────
                    Container(
                      width: 120,
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.8),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Candado elegante ─────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Frase principal ──────────────────────────────────
                    Text(
                      'Para seguir disfrutando\nde Eva Strong',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Subtítulo ────────────────────────────────────────
                    Text(
                      'suscríbete a uno de nuestros planes',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.88),
                        letterSpacing: 0.8,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── Botón Suscribirse ────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.35),
                                Colors.white.withOpacity(0.15),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: EvaColors.vibrantPink.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 18,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.diamond_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Ver Planes',
                                      style: GoogleFonts.cormorantGaramond(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Volver ───────────────────────────────────────────
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Volver',
                        style: GoogleFonts.raleway(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 14,
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
                        side: BorderSide(color: Colors.white.withOpacity(0.5)),
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
