import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/language_provider.dart';
import '../theme/eva_colors.dart';
import '../l10n/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final langProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF6A0050),
                Color(0xFFD71E49),
                Color(0xFFAD1457),
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              s.settingsTitle,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2.5,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fondo oscuro premium
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6A0050),
                    Color(0xFF3D0030),
                    Color(0xFF1A0030),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Overlay decorativo sutil
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.5, -0.3),
                  radius: 1.2,
                  colors: [
                    const Color(0xFFD71E49).withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                // ── Label de sección ──────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFD700), Color(0xFFFF69B4)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s.languageSection.toUpperCase(),
                      style: GoogleFonts.raleway(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFD700),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Card glassmorphism de idiomas ─────────────────────────
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6A0050).withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
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
                            _LanguageOption(
                              flag: '🇪🇸',
                              label: s.langSpanish,
                              code: 'es',
                              isSelected: !langProvider.isEnglish,
                              isFirst: true,
                              isLast: false,
                            ),
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                            _LanguageOption(
                              flag: '🇬🇧',
                              label: s.langEnglish,
                              code: 'en',
                              isSelected: langProvider.isEnglish,
                              isFirst: false,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Subtítulo informativo ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    s.languageSubtitle,
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.45),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final String code;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.code,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        splashColor: EvaColors.vibrantPink.withOpacity(0.15),
        highlightColor: EvaColors.vibrantPink.withOpacity(0.06),
        onTap: () {
          context.read<LanguageProvider>().setLocale(Locale(code));
        },
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EvaColors.vibrantPink.withOpacity(0.12),
                      EvaColors.wellnessPurple.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: isFirst ? const Radius.circular(20) : Radius.zero,
                    bottom: isLast ? const Radius.circular(20) : Radius.zero,
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.65),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black87, size: 15),
                )
              else
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
