import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/eva_colors.dart';

class VideoTutorialsScreen extends StatefulWidget {
  const VideoTutorialsScreen({super.key});

  @override
  State<VideoTutorialsScreen> createState() => _VideoTutorialsScreenState();
}

class _VideoTutorialsScreenState extends State<VideoTutorialsScreen> {
  // ── Tutorial data: stable keys for category/difficulty; bilingual title/description ──
  static const List<VideoTutorial> _tutorials = [
    VideoTutorial(
      id: '1',
      title: 'Principios Básicos del Entrenamiento',
      titleEn: 'Basic Training Principles',
      description: 'Aprende los fundamentos para empezar tu transformación',
      descriptionEn: 'Learn the fundamentals to start your transformation',
      duration: '15:30',
      thumbnail: '🏋️‍♀️',
      categoryKey: 'beginners',
      difficultyKey: 'easy',
      views: 15420,
      rating: 4.8,
      instructor: 'Carlos Fitness',
      isPremium: false,
    ),
    VideoTutorial(
      id: '2',
      title: 'Técnica Perfecta de Sentadillas',
      titleEn: 'Perfect Squat Technique',
      description: 'Domina la sentadilla con forma correcta y segura',
      descriptionEn: 'Master the squat with correct and safe form',
      duration: '12:45',
      thumbnail: '🦵',
      categoryKey: 'technique',
      difficultyKey: 'medium',
      views: 8934,
      rating: 4.9,
      instructor: 'Ana Pro',
      isPremium: false,
    ),
    VideoTutorial(
      id: '3',
      title: 'Rutina de Abdominales en Casa',
      titleEn: 'Home Abs Routine',
      description: 'Ejercicios efectivos sin equipment',
      descriptionEn: 'Effective exercises without equipment',
      duration: '20:15',
      thumbnail: '💪',
      categoryKey: 'routines',
      difficultyKey: 'medium',
      views: 23156,
      rating: 4.7,
      instructor: 'María Trainer',
      isPremium: false,
    ),
    VideoTutorial(
      id: '4',
      title: 'Nutrición para Ganar Masa Muscular',
      titleEn: 'Nutrition for Muscle Building',
      description: 'Guía completa de alimentación para hipertrofia',
      descriptionEn: 'Complete nutrition guide for hypertrophy',
      duration: '25:00',
      thumbnail: '🥗',
      categoryKey: 'nutrition',
      difficultyKey: 'advanced',
      views: 18743,
      rating: 4.9,
      instructor: 'Dr. Luis Nutriólogo',
      isPremium: true,
    ),
    VideoTutorial(
      id: '5',
      title: 'Estiramientos Post-Entrenamiento',
      titleEn: 'Post-Workout Stretching',
      description: 'Recuperación y flexibilidad óptima',
      descriptionEn: 'Optimal recovery and flexibility',
      duration: '18:20',
      thumbnail: '🧘‍♀️',
      categoryKey: 'recovery',
      difficultyKey: 'easy',
      views: 12456,
      rating: 4.6,
      instructor: 'Sofía Yoga',
      isPremium: false,
    ),
    VideoTutorial(
      id: '6',
      title: 'Cardio HIIT para Quemar Grasa',
      titleEn: 'HIIT Cardio to Burn Fat',
      description: 'Entrenamiento de alta intensidad',
      descriptionEn: 'High-intensity training',
      duration: '30:00',
      thumbnail: '🔥',
      categoryKey: 'cardio',
      difficultyKey: 'high',
      views: 31289,
      rating: 4.8,
      instructor: 'Carlos Fitness',
      isPremium: true,
    ),
  ];

  static const List<String> _categoryKeys = [
    'all',
    'beginners',
    'technique',
    'routines',
    'nutrition',
    'recovery',
    'cardio',
  ];

  String _selectedCategoryKey = 'all';

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final filtered = _selectedCategoryKey == 'all'
        ? _tutorials
        : _tutorials.where((t) => t.categoryKey == _selectedCategoryKey).toList();

    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: Text(s.videoTutorialsTitle),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(s),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(s),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Category chips ────────────────────────────────────────────────
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categoryKeys.length,
              itemBuilder: (context, index) {
                final key = _categoryKeys[index];
                final isSelected = key == _selectedCategoryKey;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(s.videoTutorialCategory(key)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategoryKey = key),
                    backgroundColor: isSelected ? EvaColors.vibrantPink : EvaColors.surfaceLight,
                    labelStyle: TextStyle(
                      color: isSelected ? EvaColors.textOnVibrant : EvaColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Tutorial list ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) =>
                  _buildVideoCard(filtered[index], s, isEn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoTutorial tutorial, AppStrings s, bool isEn) {
    final displayTitle = isEn ? tutorial.titleEn : tutorial.title;
    final displayDesc  = isEn ? tutorial.descriptionEn : tutorial.description;
    final displayDiff  = s.videoDifficulty(tutorial.difficultyKey);
    final displayCat   = s.videoTutorialCategory(tutorial.categoryKey);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _playVideo(tutorial, s, isEn),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail + badges
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: EvaColors.primaryGradient,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Text(tutorial.thumbnail, style: const TextStyle(fontSize: 60)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tutorial.duration,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (tutorial.isPremium)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: EvaColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(color: EvaColors.textOnVibrant, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(tutorial.difficultyKey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayDiff,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: () => _playVideo(tutorial, s, isEn),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: EvaColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EvaColors.textPrimary.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: EvaColors.surfaceLight,
                        child: Text('👨‍🏫', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tutorial.instructor,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: EvaColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${_formatViews(tutorial.views)} • $displayCat',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: EvaColors.textPrimary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            tutorial.rating.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: EvaColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String key) {
    switch (key) {
      case 'easy':     return Colors.green;
      case 'medium':   return Colors.orange;
      case 'high':     return Colors.red;
      case 'advanced': return Colors.purple;
      default:         return Colors.grey;
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000)    return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }

  void _playVideo(VideoTutorial tutorial, AppStrings s, bool isEn) {
    if (tutorial.isPremium) {
      _showPremiumDialog(tutorial, s, isEn);
    } else {
      final displayTitle = isEn ? tutorial.titleEn : tutorial.title;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.playingLabel(displayTitle)),
          backgroundColor: EvaColors.vibrantPink,
        ),
      );
    }
  }

  void _showPremiumDialog(VideoTutorial tutorial, AppStrings s, bool isEn) {
    final displayTitle = isEn ? tutorial.titleEn : tutorial.title;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.premiumContent),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(s.premiumExclusive, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(s.premiumBenefitsTitle),
            const SizedBox(height: 4),
            Text(s.premiumAllVideos),
            Text(s.premiumDownloads),
            Text(s.premiumNoAds),
            Text(s.premiumExclusiveContent),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile-setup');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: EvaColors.vibrantPink,
              foregroundColor: EvaColors.textOnVibrant,
            ),
            child: Text(s.getPremium),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(AppStrings s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.searchTutorials),
        content: TextField(
          decoration: InputDecoration(
            hintText: s.searchHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.search),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(AppStrings s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.filtersLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.difficultyFilter),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: Text(s.difficultyEasy),          onSelected: (_) {}),
                FilterChip(label: Text(s.difficultyMediumLevel),   onSelected: (_) {}),
                FilterChip(label: Text(s.difficultyHighLevel),     onSelected: (_) {}),
                FilterChip(label: Text(s.difficultyAdvancedLevel), onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),
            Text(s.durationFilter),
            const Wrap(
              spacing: 8,
              children: [
                FilterChip(label: Text('< 10 min'), onSelected: null),
                FilterChip(label: Text('10-20 min'), onSelected: null),
                FilterChip(label: Text('20-30 min'), onSelected: null),
                FilterChip(label: Text('> 30 min'), onSelected: null),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.applyFilter),
          ),
        ],
      ),
    );
  }
}

class VideoTutorial {
  final String id;
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String duration;
  final String thumbnail;
  final String categoryKey;
  final String difficultyKey;
  final int views;
  final double rating;
  final String instructor;
  final bool isPremium;

  const VideoTutorial({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.duration,
    required this.thumbnail,
    required this.categoryKey,
    required this.difficultyKey,
    required this.views,
    required this.rating,
    required this.instructor,
    required this.isPremium,
  });
}
