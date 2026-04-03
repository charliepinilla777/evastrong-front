import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_strings.dart';
import '../theme/eva_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  static Widget _buildDivider() {
    return Container(
      width: 140,
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
    );
  }

  static Widget _buildInfoRow({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: EvaColors.vibrantPink, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 15,
                  decoration: onTap != null
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: Colors.white54,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EVA',
                style: GoogleFonts.greatVibes(
                  fontSize: 84,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFD6EC)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
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
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Colors.white, Color(0xFFE8B4FF)],
                    ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
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
        const SizedBox(height: 8),
        _buildDivider(),
        const SizedBox(height: 10),
        Builder(builder: (context) => Text(
          AppStrings.of(context).followUsNetworks,
          style: GoogleFonts.raleway(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w400,
          ),
        )),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool useMontserrat = false}) {
    if (useMontserrat) {
      return Text(
        title,
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Text(
      title,
      style: GoogleFonts.cormorantGaramond(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> primaryColors,
    required List<Color> secondaryColors,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 76,
        child: Stack(
          children: [
            // Fondo con gradiente animado de la red social
            Positioned.fill(
              child: AnimateGradient(
                primaryColors: primaryColors,
                secondaryColors: secondaryColors,
                duration: const Duration(seconds: 3),
              ),
            ),
            // Borde sutil
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Ripple + contenido
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.white.withOpacity(0.15),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      // Ícono en círculo
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      // Texto
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: GoogleFonts.raleway(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: GoogleFonts.raleway(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 11,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Flecha
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    final s = AppStrings.of(context);
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(s.ourLocation, useMontserrat: true),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.location_on,
            text: 'Bogotá, Colombia',
            onTap: () => _launchURL(
              'https://maps.google.com/?q=Bogota,Colombia',
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2D1B3D),
                        Color(0xFF4A1942),
                        Color(0xFF6B2D5E),
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: _MapPatternPainter(),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: EvaColors.vibrantPink.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: EvaColors.vibrantPink.withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bogotá, Colombia',
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchURL(
                'https://maps.google.com/?q=Bogota,Colombia',
              ),
              icon: const Icon(Icons.map_outlined, size: 20),
              label: Text(
                s.openGoogleMaps,
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: EvaColors.vibrantPink.withOpacity(0.85),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppStrings.of(context).contactTitle,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimateGradient(
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Partículas — igual que home
                Positioned.fill(
                  child: ParticlesFly(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    connectDots: false,
                    numberOfParticles: 25,
                    speedOfParticles: 0.8,
                    lineColor: EvaColors.vibrantPink.withOpacity(0.2),
                    particleColor: Colors.white.withOpacity(0.7),
                    awayRadius: 180,
                    onTapAnimation: true,
                    isRandSize: true,
                    isRandomColor: false,
                    randColorList: [
                      EvaColors.vibrantPink.withOpacity(0.5),
                      Colors.white.withOpacity(0.7),
                      EvaColors.cosmicRed.withOpacity(0.4),
                    ],
                  ),
                ),

                // Contenido
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildLogo(),
                        const SizedBox(height: 36),

                        // ── Redes sociales ──────────────────────────────
                        _buildGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(AppStrings.of(context).followUsOn),
                              const SizedBox(height: 20),

                              // Instagram
                              _buildSocialButton(
                                icon: Icons.camera_alt_rounded,
                                label: 'Instagram',
                                subtitle: AppStrings.of(context).instagramSubtitle,
                                primaryColors: const [
                                  Color(0xFF833AB4),
                                  Color(0xFFE1306C),
                                ],
                                secondaryColors: const [
                                  Color(0xFFE1306C),
                                  Color(0xFFF77737),
                                ],
                                onTap: () => _launchURL(
                                    'https://instagram.com/evastrong'),
                              ),
                              const SizedBox(height: 12),

                              // Facebook
                              _buildSocialButton(
                                icon: Icons.facebook,
                                label: 'Facebook',
                                subtitle: AppStrings.of(context).facebookSubtitle,
                                primaryColors: const [
                                  Color(0xFF1877F2),
                                  Color(0xFF0D6EFD),
                                ],
                                secondaryColors: const [
                                  Color(0xFF0C5FCD),
                                  Color(0xFF1877F2),
                                ],
                                onTap: () => _launchURL(
                                    'https://facebook.com/evastrong'),
                              ),
                              const SizedBox(height: 12),

                              // Pinterest
                              _buildSocialButton(
                                icon: Icons.push_pin_rounded,
                                label: 'Pinterest',
                                subtitle: AppStrings.of(context).pinterestSubtitle,
                                primaryColors: const [
                                  Color(0xFFE60023),
                                  Color(0xFFAD081B),
                                ],
                                secondaryColors: const [
                                  Color(0xFFAD081B),
                                  Color(0xFF8B0000),
                                ],
                                onTap: () => _launchURL(
                                    'https://pinterest.com/evastrong'),
                              ),
                              const SizedBox(height: 12),

                              // Gmail / Email
                              _buildSocialButton(
                                icon: Icons.mail_rounded,
                                label: AppStrings.of(context).emailLabel,
                                subtitle: AppStrings.of(context).emailSubtitle,
                                primaryColors: const [
                                  EvaColors.cosmicRed,
                                  EvaColors.vibrantPink,
                                ],
                                secondaryColors: const [
                                  EvaColors.vibrantPink,
                                  EvaColors.wellnessPurple,
                                ],
                                onTap: () => _launchURL(
                                    'mailto:soporte@evastrong.app'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Información de contacto ─────────────────────
                        _buildGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(
                                AppStrings.of(context).contactInfo,
                                useMontserrat: true,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.email,
                                text: 'soporte@evastrong.app',
                                onTap: () => _launchURL(
                                    'mailto:soporte@evastrong.app'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Ubicación ───────────────────────────────────
                        _buildLocationCard(context),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Patrón decorativo que simula calles de mapa
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final mainPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      mainPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      mainPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
