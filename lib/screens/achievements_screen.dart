import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../theme/eva_colors.dart';
import '../services/gamification_service.dart';
import '../services/history_service.dart';
import '../l10n/app_strings.dart';
import '../providers/language_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  final GamificationService _gamificationService = GamificationService();
  bool _isLoading = true;
  int _selectedTab = 0; // 0=Todos, 1=Desbloqueados, 2=Progreso

  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerFade;
  late Animation<double> _ringProgress;

  static const List<String> _motivationalQuotes = [
    'Cada entrenamiento te acerca más a la mejor versión de ti.',
    'No pares cuando estés cansada. Para cuando hayas terminado.',
    'Tu cuerpo puede. Es tu mente la que debes convencer.',
    'El progreso, no la perfección, es la meta.',
    'Cada logro comienza con la decisión de intentarlo.',
  ];

  late String _currentQuote;

  // ── Level system ────────────────────────────────────────────────────────
  static _LevelInfo _getLevelInfo(int points) {
    if (points >= 1000) return _LevelInfo(5, 'Leyenda', '👑', 1000, 9999);
    if (points >= 500)  return _LevelInfo(4, 'Campeona', '🏆', 500, 1000);
    if (points >= 250)  return _LevelInfo(3, 'Guerrera', '🔥', 250, 500);
    if (points >= 100)  return _LevelInfo(2, 'Activa', '⚡', 100, 250);
    return                    _LevelInfo(1, 'Iniciada', '🌱', 0, 100);
  }

  @override
  void initState() {
    super.initState();
    _currentQuote = _motivationalQuotes[
        math.Random().nextInt(_motivationalQuotes.length)];

    _headerController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
    _listController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));

    _headerFade = CurvedAnimation(
        parent: _headerController, curve: Curves.easeOut);
    _ringProgress = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeInOut));

    _loadAndEvaluate();
  }

  Future<void> _loadAndEvaluate() async {
    await _gamificationService.loadUnlockedState();
    try {
      final history = await HistoryService.getHistory();
      final newlyUnlocked = await _gamificationService.evaluateFromHistory(
        history.records, history.stats);
      if (!mounted) return;
      setState(() => _isLoading = false);
      _headerController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      _listController.forward();
      if (newlyUnlocked.isNotEmpty) _showNewAchievementsBar(newlyUnlocked);
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        _headerController.forward();
        _listController.forward();
      }
    }
  }

  void _showNewAchievementsBar(List<Achievement> achievements) {
    final isEn = context.read<LanguageProvider>().isEnglish;
    final names = achievements
        .map((a) => '${a.icon} ${a.localizedTitle(isEn)}')
        .join(' · ');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.of(context).achievementUnlocked(names),
          style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: EvaColors.wellnessPurple,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  // ─────────────────────────────── BUILD ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEn = context.watch<LanguageProvider>().isEnglish;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a0533),
        body: const Center(
          child: CircularProgressIndicator(color: EvaColors.vibrantPink),
        ),
      );
    }

    final all = _gamificationService.getAllAchievements();
    final unlocked = _gamificationService.getUnlockedAchievements();
    final totalPoints = _gamificationService.getTotalPoints();
    final completionPct = _gamificationService.getCompletionPercentage();
    final level = _getLevelInfo(totalPoints);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                FadeTransition(
                  opacity: _headerFade,
                  child: _buildHeroHeader(
                    totalPoints: totalPoints,
                    completionPct: completionPct,
                    unlocked: unlocked.length,
                    total: all.length,
                    level: level,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTabPills(),
                const SizedBox(height: 16),
                Expanded(child: _buildTabContent(isEn: isEn)),
                _buildMotivationalFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a0533),
            Color(0xFF2D0A4E),
            Color(0xFF0D0D1A),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    final s = AppStrings.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                s.achievementsTitle,
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Text('EVA',
            style: GoogleFonts.cormorantGaramond(
              color: EvaColors.vibrantPink, fontSize: 16,
              fontWeight: FontWeight.w700, letterSpacing: 4,
            )),
        ],
      ),
    );
  }

  // ── Hero header ─────────────────────────────────────────────────────────

  Widget _buildHeroHeader({
    required int totalPoints,
    required double completionPct,
    required int unlocked,
    required int total,
    required _LevelInfo level,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            // Circular progress ring
            SizedBox(
              width: 100, height: 100,
              child: AnimatedBuilder(
                animation: _ringProgress,
                builder: (_, __) => CustomPaint(
                  painter: _RingPainter(
                    progress: completionPct * _ringProgress.value,
                    trackColor: Colors.white.withOpacity(0.1),
                    ringColors: const [EvaColors.vibrantPink, EvaColors.wellnessPurple],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(level.emoji,
                            style: const TextStyle(fontSize: 28)),
                        Text(
                          '${(completionPct * 100).round()}%',
                          style: GoogleFonts.cormorantGaramond(
                            color: Colors.white, fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        EvaColors.vibrantPink, EvaColors.wellnessPurple,
                      ]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Nivel ${level.level} · ${level.name}',
                      style: GoogleFonts.raleway(
                        color: Colors.white, fontSize: 11,
                        fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$totalPoints XP',
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white, fontSize: 32,
                      fontWeight: FontWeight.w700, letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '$unlocked de $total logros',
                    style: GoogleFonts.raleway(
                      color: Colors.white54, fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // XP to next level
                  if (level.level < 5) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (totalPoints - level.minPts) /
                            (level.maxPts - level.minPts),
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            EvaColors.vibrantPink),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${level.maxPts - totalPoints} XP para Nivel ${level.level + 1}',
                      style: GoogleFonts.raleway(
                        color: Colors.white30, fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ] else
                    Text(AppStrings.of(context).maxLevelReached,
                      style: GoogleFonts.raleway(
                        color: EvaColors.vibrantPink, fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab pills ────────────────────────────────────────────────────────────

  Widget _buildTabPills() {
    final s = AppStrings.of(context);
    final tabs = [s.allAchievements, s.unlocked, s.progress];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final active = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: active
                        ? const LinearGradient(colors: [
                            EvaColors.vibrantPink,
                            EvaColors.wellnessPurple,
                          ])
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active
                        ? [BoxShadow(
                            color: EvaColors.vibrantPink.withOpacity(0.3),
                            blurRadius: 8, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      color: active ? Colors.white : Colors.white38,
                      fontSize: 12,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Tab content ──────────────────────────────────────────────────────────

  Widget _buildTabContent({required bool isEn}) {
    switch (_selectedTab) {
      case 0:
        return _buildAllTab(isEn: isEn);
      case 1:
        return _buildUnlockedTab(isEn: isEn);
      case 2:
        return _buildProgressTab(isEn: isEn);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Tab: Todos ───────────────────────────────────────────────────────────

  Widget _buildAllTab({required bool isEn}) {
    final categories = _gamificationService.getLocalizedCategories(isEn: isEn);
    final allItems = <_ListItem>[];
    for (final cat in categories) {
      allItems.add(_ListItem.category(cat));
      final achvs = _gamificationService
          .getAchievementsByLocalizedCategory(cat, isEn: isEn);
      for (final a in achvs) allItems.add(_ListItem.achievement(a));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        if (item.isCategory) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
            child: Text(
              item.category!,
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white60, fontSize: 16,
                fontWeight: FontWeight.w600, letterSpacing: 1.5,
              ),
            ),
          );
        }
        return _buildAnimatedCard(
          index: index,
          child: _buildAchievementRow(item.achievement!, isEn: isEn),
        );
      },
    );
  }

  // ── Tab: Desbloqueados ───────────────────────────────────────────────────

  Widget _buildUnlockedTab({required bool isEn}) {
    final unlocked = _gamificationService.getUnlockedAchievements();
    if (unlocked.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: unlocked.length,
      itemBuilder: (context, index) => _buildAnimatedCard(
        index: index,
        child: _buildAchievementRow(unlocked[index], isEn: isEn),
      ),
    );
  }

  // ── Tab: Progreso ────────────────────────────────────────────────────────

  Widget _buildProgressTab({required bool isEn}) {
    final categoryPoints =
        _gamificationService.getLocalizedPointsByCategory(isEn: isEn);
    final categories = categoryPoints.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final pts = categoryPoints[cat] ?? 0;
        final catAchvs = _gamificationService
            .getAchievementsByLocalizedCategory(cat, isEn: isEn);
        final unlockedCount = catAchvs.where((a) => a.isUnlocked).length;
        final total = catAchvs.length;
        final pct = total > 0 ? unlockedCount / total : 0.0;

        return _buildAnimatedCard(
          index: index,
          child: _buildProgressCard(
            category: cat,
            points: pts,
            unlocked: unlockedCount,
            total: total,
            pct: pct,
          ),
        );
      },
    );
  }

  // ── Animated card wrapper ────────────────────────────────────────────────

  Widget _buildAnimatedCard({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, _) {
        final delay = (index * 0.06).clamp(0.0, 0.8);
        final interval = Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic);
        final t = interval.transform(_listController.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  // ── Achievement row card ─────────────────────────────────────────────────

  Widget _buildAchievementRow(Achievement a, {required bool isEn}) {
    final unlocked = a.isUnlocked;
    return GestureDetector(
      onTap: () => _showDetailSheet(a, isEn: isEn),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: unlocked
              ? LinearGradient(colors: [
                  EvaColors.vibrantPink.withOpacity(0.15),
                  EvaColors.wellnessPurple.withOpacity(0.10),
                ])
              : null,
          color: unlocked ? null : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked
                ? EvaColors.vibrantPink.withOpacity(0.35)
                : Colors.white.withOpacity(0.07),
            width: unlocked ? 1.5 : 1,
          ),
          boxShadow: unlocked
              ? [BoxShadow(
                  color: EvaColors.vibrantPink.withOpacity(0.12),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: unlocked
                    ? const LinearGradient(colors: [
                        EvaColors.vibrantPink, EvaColors.wellnessPurple,
                      ])
                    : null,
                color: unlocked ? null : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: unlocked
                    ? Text(a.icon,
                        style: const TextStyle(fontSize: 26))
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(a.icon,
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white.withOpacity(0.2))),
                          const Icon(Icons.lock_outline,
                              color: Colors.white24, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.localizedTitle(isEn),
                    style: GoogleFonts.raleway(
                      color: unlocked ? Colors.white : Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    a.localizedDescription(isEn),
                    style: GoogleFonts.raleway(
                      color: unlocked ? Colors.white54 : Colors.white24,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Points badge
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? EvaColors.vibrantPink.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${a.points}',
                    style: GoogleFonts.cormorantGaramond(
                      color: unlocked
                          ? EvaColors.vibrantPink
                          : Colors.white24,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'XP',
                  style: GoogleFonts.raleway(
                    color: unlocked ? Colors.white38 : Colors.white12,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Progress card ────────────────────────────────────────────────────────

  Widget _buildProgressCard({
    required String category,
    required int points,
    required int unlocked,
    required int total,
    required double pct,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category,
                style: GoogleFonts.raleway(
                  color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w700,
                )),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: EvaColors.vibrantPink.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$points XP',
                  style: GoogleFonts.cormorantGaramond(
                    color: EvaColors.vibrantPink, fontSize: 14,
                    fontWeight: FontWeight.w700,
                  )),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        EvaColors.vibrantPink),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$unlocked/$total',
                style: GoogleFonts.raleway(
                  color: Colors.white38, fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 42)),
            ),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.of(context).trophiesWaiting,
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white, fontSize: 22,
              fontWeight: FontWeight.w700,
            )),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppStrings.of(context).completeToUnlockMsg,
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(
                color: Colors.white38, fontSize: 14, height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Motivational footer ──────────────────────────────────────────────────

  Widget _buildMotivationalFooter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EvaColors.vibrantPink.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentQuote,
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white60, fontSize: 14,
                fontStyle: FontStyle.italic, height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail bottom sheet ──────────────────────────────────────────────────

  void _showDetailSheet(Achievement a, {required bool isEn}) {
    final unlocked = a.isUnlocked;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D0A4E), Color(0xFF1a0533)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Big icon
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: unlocked
                    ? const LinearGradient(colors: [
                        EvaColors.vibrantPink, EvaColors.wellnessPurple,
                      ])
                    : null,
                color: unlocked ? null : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(26),
                boxShadow: unlocked
                    ? [BoxShadow(
                        color: EvaColors.vibrantPink.withOpacity(0.4),
                        blurRadius: 24, spreadRadius: 4)]
                    : null,
              ),
              child: Center(
                child: Text(a.icon,
                    style: const TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              a.localizedTitle(isEn),
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white, fontSize: 26,
                fontWeight: FontWeight.w700, letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              a.localizedDescription(isEn),
              style: GoogleFonts.raleway(
                color: Colors.white60, fontSize: 14, height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _detailStat('+${a.points}', 'XP', Icons.bolt_rounded),
                Container(width: 1, height: 40,
                    color: Colors.white.withOpacity(0.1)),
                _detailStat(a.localizedCategory(isEn), 'Categoría',
                    Icons.category_outlined),
                if (unlocked && a.unlockedAt != null) ...[
                  Container(width: 1, height: 40,
                      color: Colors.white.withOpacity(0.1)),
                  _detailStat(
                    '${a.unlockedAt!.day}/${a.unlockedAt!.month}/${a.unlockedAt!.year}',
                    'Obtenido',
                    Icons.calendar_today_outlined,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 28),
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: unlocked
                    ? const LinearGradient(colors: [
                        EvaColors.vibrantPink, EvaColors.wellnessPurple,
                      ])
                    : null,
                color: unlocked ? null : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: unlocked
                    ? null
                    : Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    unlocked ? Icons.star_rounded : Icons.lock_outline,
                    color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    unlocked ? '¡Logro desbloqueado!' : 'Aún no desbloqueado',
                    style: GoogleFonts.raleway(
                      color: Colors.white, fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: EvaColors.vibrantPink, size: 18),
        const SizedBox(height: 6),
        Text(value,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white, fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(label,
          style: GoogleFonts.raleway(
            color: Colors.white38, fontSize: 10,
            fontWeight: FontWeight.w500, letterSpacing: 0.5,
          )),
      ],
    );
  }
}

// ─────────────────── Ring painter ────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final List<Color> ringColors;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.ringColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 7.0;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc with gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress;
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: ringColors,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (progress > 0) {
      canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress;
}

// ─────────────────── Helper classes ──────────────────────────────────────────

class _LevelInfo {
  final int level;
  final String name;
  final String emoji;
  final int minPts;
  final int maxPts;
  const _LevelInfo(this.level, this.name, this.emoji, this.minPts, this.maxPts);
}

class _ListItem {
  final String? category;
  final Achievement? achievement;

  _ListItem.category(this.category) : achievement = null;
  _ListItem.achievement(this.achievement) : category = null;

  bool get isCategory => category != null;
}
