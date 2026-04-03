import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late TabController _tabController;
  final GamificationService _gamificationService = GamificationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAndEvaluate();
  }

  Future<void> _loadAndEvaluate() async {
    // Cargar estado persistido primero (logros anteriores)
    await _gamificationService.loadUnlockedState();

    // Luego evaluar con historial real
    try {
      final history = await HistoryService.getHistory();
      final newlyUnlocked = await _gamificationService.evaluateFromHistory(
        history.records,
        history.stats,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Mostrar notificación si se desbloquearon nuevos logros
      if (newlyUnlocked.isNotEmpty) {
        _showNewAchievementsSnackBar(newlyUnlocked);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNewAchievementsSnackBar(List<Achievement> achievements) {
    final s = AppStrings.of(context);
    final isEn = context.read<LanguageProvider>().isEnglish;
    final names = achievements.map((a) => '${a.icon} ${a.localizedTitle(isEn)}').join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${s.newAchievement} $names'),
        backgroundColor: EvaColors.vibrantPink,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isEn = context.watch<LanguageProvider>().isEnglish;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: EvaColors.backgroundLight,
        appBar: AppBar(
          title: Text(s.achievementsTitle),
          backgroundColor: EvaColors.vibrantPink,
          foregroundColor: EvaColors.textOnVibrant,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: EvaColors.vibrantPink),
        ),
      );
    }

    final allAchievements = _gamificationService.getAllAchievements();
    final unlockedAchievements = _gamificationService.getUnlockedAchievements();
    final totalPoints = _gamificationService.getTotalPoints();
    final completionPercentage = _gamificationService.getCompletionPercentage();

    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: Text(s.achievementsTitle),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EvaColors.textOnVibrant,
          labelColor: EvaColors.textOnVibrant,
          unselectedLabelColor: EvaColors.textOnVibrant.withOpacity(0.7),
          tabs: [
            Tab(text: s.allAchievements, icon: const Icon(Icons.emoji_events)),
            Tab(text: s.unlocked, icon: const Icon(Icons.star)),
            Tab(text: s.progress, icon: const Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: EvaColors.primaryGradient),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(s.points, totalPoints.toString(), Icons.stars),
                    _buildStatCard(
                      s.achievementsTitle,
                      '${unlockedAchievements.length}/${allAchievements.length}',
                      Icons.emoji_events,
                    ),
                    _buildStatCard(
                      s.progress,
                      '${(completionPercentage * 100).round()}%',
                      Icons.trending_up,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barra de progreso
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: EvaColors.textOnVibrant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: completionPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: EvaColors.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllAchievementsTab(isEn: isEn),
                _buildUnlockedAchievementsTab(s: s, isEn: isEn),
                _buildProgressTab(s: s, isEn: isEn),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: EvaColors.textOnVibrant, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: EvaColors.textOnVibrant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: EvaColors.textOnVibrant.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildAllAchievementsTab({required bool isEn}) {
    final categories = _gamificationService.getLocalizedCategories(isEn: isEn);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryAchievements = _gamificationService
            .getAchievementsByLocalizedCategory(category, isEn: isEn);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categoryAchievements
                  .map((a) => _buildAchievementCard(a, isEn: isEn))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildUnlockedAchievementsTab({required AppStrings s, required bool isEn}) {
    final unlockedAchievements = _gamificationService.getUnlockedAchievements();

    if (unlockedAchievements.isEmpty) {
      return _buildEmptyState(
        s.noAchievementsYet,
        s.noAchievementsSub,
        Icons.emoji_events_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unlockedAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(unlockedAchievements[index], isEn: isEn);
      },
    );
  }

  Widget _buildProgressTab({required AppStrings s, required bool isEn}) {
    final categoryPoints = _gamificationService.getLocalizedPointsByCategory(isEn: isEn);
    final categories = categoryPoints.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final points = categoryPoints[category] ?? 0;
        final categoryAchievements = _gamificationService
            .getAchievementsByLocalizedCategory(category, isEn: isEn);
        final unlockedInCategory = categoryAchievements
            .where((a) => a.isUnlocked)
            .length;
        final totalInCategory = categoryAchievements.length;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EvaColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$points pts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: EvaColors.vibrantPink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: totalInCategory > 0
                            ? unlockedInCategory / totalInCategory
                            : 0,
                        backgroundColor: EvaColors.surfaceLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          EvaColors.vibrantPink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$unlockedInCategory/$totalInCategory',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: EvaColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement, {bool isEn = false}) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? EvaColors.primaryGradient
            : LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade400],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAchievementDetails(achievement, isEn: isEn),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(achievement.icon, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 4),
                Text(
                  achievement.localizedTitle(isEn),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked
                        ? EvaColors.textOnVibrant
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '+${achievement.points} pts',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isUnlocked
                        ? EvaColors.textOnVibrant.withOpacity(0.9)
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                  ),
                ),
                if (isUnlocked) Icon(Icons.star, color: Colors.amber, size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String description, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: EvaColors.textPrimary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: EvaColors.textPrimary.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: EvaColors.textPrimary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement, {bool isEn = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: achievement.isUnlocked
                      ? EvaColors.primaryGradient
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                achievement.localizedTitle(isEn),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: EvaColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.localizedDescription(isEn),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EvaColors.textPrimary.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '+${achievement.points}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: EvaColors.vibrantPink,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        AppStrings.of(context).points,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EvaColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        achievement.localizedCategory(isEn),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: EvaColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        AppStrings.of(context).category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EvaColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (achievement.isUnlocked && achievement.unlockedAt != null)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.of(context).unlockedOn(_formatDate(achievement.unlockedAt!)),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: EvaColors.textPrimary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.of(context).close,
              style: const TextStyle(color: EvaColors.vibrantPink),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
