import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';

class VideoTutorialsScreen extends StatefulWidget {
  const VideoTutorialsScreen({super.key});

  @override
  State<VideoTutorialsScreen> createState() => _VideoTutorialsScreenState();
}

class _VideoTutorialsScreenState extends State<VideoTutorialsScreen> {
  final List<VideoTutorial> _tutorials = [
    VideoTutorial(
      id: '1',
      title: 'Principios Básicos del Entrenamiento',
      description: 'Aprende los fundamentos para empezar tu transformación',
      duration: '15:30',
      thumbnail: '🏋️‍♀️',
      category: 'Principiantes',
      difficulty: 'Fácil',
      views: 15420,
      rating: 4.8,
      instructor: 'Carlos Fitness',
      isPremium: false,
    ),
    VideoTutorial(
      id: '2',
      title: 'Técnica Perfecta de Sentadillas',
      description: 'Domina la sentadilla con forma correcta y segura',
      duration: '12:45',
      thumbnail: '🦵',
      category: 'Técnica',
      difficulty: 'Media',
      views: 8934,
      rating: 4.9,
      instructor: 'Ana Pro',
      isPremium: false,
    ),
    VideoTutorial(
      id: '3',
      title: 'Rutina de Abdominales en Casa',
      description: 'Ejercicios efectivos sin equipment',
      duration: '20:15',
      thumbnail: '💪',
      category: 'Rutinas',
      difficulty: 'Media',
      views: 23156,
      rating: 4.7,
      instructor: 'María Trainer',
      isPremium: false,
    ),
    VideoTutorial(
      id: '4',
      title: 'Nutrition para Ganar Masa Muscular',
      description: 'Guía completa de alimentación para hipertrofia',
      duration: '25:00',
      thumbnail: '🥗',
      category: 'Nutrición',
      difficulty: 'Avanzado',
      views: 18743,
      rating: 4.9,
      instructor: 'Dr. Luis Nutriólogo',
      isPremium: true,
    ),
    VideoTutorial(
      id: '5',
      title: 'Estiramientos Post-Entrenamiento',
      description: 'Recuperación y flexibilidad óptima',
      duration: '18:20',
      thumbnail: '🧘‍♀️',
      category: 'Recuperación',
      difficulty: 'Fácil',
      views: 12456,
      rating: 4.6,
      instructor: 'Sofía Yoga',
      isPremium: false,
    ),
    VideoTutorial(
      id: '6',
      title: 'Cardio HIIT para Quemar Grasa',
      description: 'Entrenamiento de alta intensidad',
      duration: '30:00',
      thumbnail: '🔥',
      category: 'Cardio',
      difficulty: 'Alta',
      views: 31289,
      rating: 4.8,
      instructor: 'Carlos Fitness',
      isPremium: true,
    ),
  ];

  String _selectedCategory = 'Todos';
  final List<String> _categories = [
    'Todos',
    'Principiantes',
    'Técnica',
    'Rutinas',
    'Nutrición',
    'Recuperación',
    'Cardio',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTutorials = _selectedCategory == 'Todos'
        ? _tutorials
        : _tutorials.where((t) => t.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: EvaColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Video Tutoriales'),
        backgroundColor: EvaColors.vibrantPink,
        foregroundColor: EvaColors.textOnVibrant,
        elevation: 8,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Categorías
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: isSelected
                        ? EvaColors.vibrantPink
                        : EvaColors.surfaceLight,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? EvaColors.textOnVibrant
                          : EvaColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de videos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTutorials.length,
              itemBuilder: (context, index) {
                final tutorial = filteredTutorials[index];
                return _buildVideoCard(tutorial);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoTutorial tutorial) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _playVideo(tutorial),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: EvaColors.primaryGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tutorial.thumbnail,
                      style: const TextStyle(fontSize: 60),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tutorial.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (tutorial.isPremium)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: EvaColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: EvaColors.textOnVibrant,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(tutorial.difficulty),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tutorial.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
                      onPressed: () => _playVideo(tutorial),
                    ),
                  ),
                ),
              ],
            ),

            // Información
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutorial.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: EvaColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tutorial.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EvaColors.textPrimary.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: EvaColors.surfaceLight,
                        child: Text(
                          '👨‍🏫',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tutorial.instructor,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: EvaColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${_formatViews(tutorial.views)} • ${tutorial.category}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: EvaColors.textPrimary.withOpacity(
                                      0.6,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            tutorial.rating.toString(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Fácil':
        return Colors.green;
      case 'Media':
        return Colors.orange;
      case 'Alta':
        return Colors.red;
      case 'Avanzado':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    } else {
      return views.toString();
    }
  }

  void _playVideo(VideoTutorial tutorial) {
    if (tutorial.isPremium) {
      _showPremiumDialog(tutorial);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reproduciendo: ${tutorial.title}'),
          backgroundColor: EvaColors.vibrantPink,
        ),
      );
    }
  }

  void _showPremiumDialog(VideoTutorial tutorial) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contenido Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tutorial.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: EvaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Este contenido es exclusivo para miembros Premium.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text('Beneficios Premium:'),
            const SizedBox(height: 4),
            const Text('• Acceso a todos los videos'),
            const Text('• Descargas sin límite'),
            const Text('• Sin anuncios'),
            const Text('• Contenido exclusivo'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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
            child: const Text('Hacerse Premium'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Tutoriales'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Escribe para buscar...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dificultad'),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('Fácil'), onSelected: (_) {}),
                FilterChip(label: const Text('Media'), onSelected: (_) {}),
                FilterChip(label: const Text('Alta'), onSelected: (_) {}),
                FilterChip(label: const Text('Avanzado'), onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Duración'),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('< 10 min'), onSelected: (_) {}),
                FilterChip(label: const Text('10-20 min'), onSelected: (_) {}),
                FilterChip(label: const Text('20-30 min'), onSelected: (_) {}),
                FilterChip(label: const Text('> 30 min'), onSelected: (_) {}),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

class VideoTutorial {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String thumbnail;
  final String category;
  final String difficulty;
  final int views;
  final double rating;
  final String instructor;
  final bool isPremium;

  VideoTutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.thumbnail,
    required this.category,
    required this.difficulty,
    required this.views,
    required this.rating,
    required this.instructor,
    required this.isPremium,
  });
}
