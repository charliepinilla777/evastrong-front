import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';
import '../services/gamification_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final GamificationService _gamificationService = GamificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allAchievements = _gamificationService.getAllAchievements();
    final unlockedAchievements = _gamificationService.getUnlockedAchievements();
    final totalPoints = _gamificationService.getTotalPoints();
    final completionPercentage = _gamificationService.getCompletionPercentage();

    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Logros'),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: EvaColors.textOnVibrant,
          labelColor: EvaColors.textOnVibrant,
          unselectedLabelColor: EvaColors.textOnVibrant.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Todos', icon: Icon(Icons.emoji_events)),
            Tab(text: 'Desbloqueados', icon: Icon(Icons.star)),
            Tab(text: 'Progreso', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header con estadísticas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: EvaColors.primaryGradient),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Puntos',
                      totalPoints.toString(),
                      Icons.stars,
                    ),
                    _buildStatCard(
                      'Logros',
                      '${unlockedAchievements.length}/${allAchievements.length}',
                      Icons.emoji_events,
                    ),
                    _buildStatCard(
                      'Progreso',
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
                _buildAllAchievementsTab(),
                _buildUnlockedAchievementsTab(),
                _buildProgressTab(),
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

  Widget _buildAllAchievementsTab() {
    final categories = _gamificationService.getCategories();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryAchievements = _gamificationService
            .getAchievementsByCategory(category);

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
                  .map((achievement) => _buildAchievementCard(achievement))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildUnlockedAchievementsTab() {
    final unlockedAchievements = _gamificationService.getUnlockedAchievements();

    if (unlockedAchievements.isEmpty) {
      return _buildEmptyState(
        '¡Aún no tienes logros desbloqueados!',
        'Completa rutinas y alcanza tus metas para empezar a ganar logros.',
        Icons.emoji_events_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: unlockedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = unlockedAchievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildProgressTab() {
    final categoryPoints = _gamificationService.getPointsByCategory();
    final categories = categoryPoints.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final points = categoryPoints[category] ?? 0;
        final categoryAchievements = _gamificationService
            .getAchievementsByCategory(category);
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

  Widget _buildAchievementCard(Achievement achievement) {
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
          onTap: () => _showAchievementDetails(achievement),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(achievement.icon, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 4),
                Text(
                  achievement.title,
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

  void _showAchievementDetails(Achievement achievement) {
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
                achievement.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: EvaColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
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
                        'Puntos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: EvaColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        achievement.category,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: EvaColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Categoría',
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
                      'Desbloqueado el ${_formatDate(achievement.unlockedAt!)}',
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
              'Cerrar',
              style: TextStyle(color: EvaColors.vibrantPink),
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
