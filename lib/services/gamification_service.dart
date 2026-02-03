
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final String category;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? points,
    String? category,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final List<Achievement> _achievements = [
    // Rutinas
    Achievement(
      id: 'first_routine',
      title: 'Primer Paso',
      description: 'Completa tu primera rutina',
      icon: '🎯',
      points: 10,
      category: 'Rutinas',
    ),
    Achievement(
      id: 'week_streak',
      title: 'Semana Fuerte',
      description: 'Completa rutinas 7 días seguidos',
      icon: '🔥',
      points: 50,
      category: 'Rutinas',
    ),
    Achievement(
      id: 'month_streak',
      title: 'Mes Legendario',
      description: 'Completa rutinas 30 días seguidos',
      icon: '👑',
      points: 200,
      category: 'Rutinas',
    ),
    Achievement(
      id: 'routine_master',
      title: 'Maestro de Rutinas',
      description: 'Completa 100 rutinas',
      icon: '💪',
      points: 150,
      category: 'Rutinas',
    ),

    // Progresos
    Achievement(
      id: 'first_progress',
      title: 'En Camino',
      description: 'Registra tu primer progreso',
      icon: '📈',
      points: 15,
      category: 'Progreso',
    ),
    Achievement(
      id: 'weight_goal',
      title: 'Meta de Peso',
      description: 'Alcanza tu objetivo de peso',
      icon: '⚖️',
      points: 100,
      category: 'Progreso',
    ),
    Achievement(
      id: 'measurement_milestone',
      title: 'Hitos de Medidas',
      description: 'Toma medidas 10 veces',
      icon: '📏',
      points: 30,
      category: 'Progreso',
    ),

    // Comunidad
    Achievement(
      id: 'social_butterfly',
      title: 'Mariposa Social',
      description: 'Comparte tu primer progreso',
      icon: '🦋',
      points: 20,
      category: 'Comunidad',
    ),
    Achievement(
      id: 'motivator',
      title: 'Motivador',
      description: 'Da 50 likes a otros usuarios',
      icon: '❤️',
      points: 40,
      category: 'Comunidad',
    ),
    Achievement(
      id: 'community_leader',
      title: 'Líder Comunitario',
      description: 'Obtén 100 seguidores',
      icon: '🌟',
      points: 80,
      category: 'Comunidad',
    ),

    // Especiales
    Achievement(
      id: 'early_bird',
      title: 'Madrugador',
      description: 'Completa 5 rutinas antes de las 6am',
      icon: '🌅',
      points: 35,
      category: 'Especial',
    ),
    Achievement(
      id: 'night_owl',
      title: 'Búho Nocturno',
      description: 'Completa 5 rutinas después de las 10pm',
      icon: '🦉',
      points: 35,
      category: 'Especial',
    ),
    Achievement(
      id: 'perfect_week',
      title: 'Semana Perfecta',
      description: 'Completa todas las rutinas programadas en una semana',
      icon: '✨',
      points: 75,
      category: 'Especial',
    ),
    Achievement(
      id: 'consistency_king',
      title: 'Rey de la Constancia',
      description: 'Mantén una racha de 90 días',
      icon: '🏆',
      points: 500,
      category: 'Especial',
    ),
  ];

  List<Achievement> getAllAchievements() {
    return List.from(_achievements);
  }

  List<Achievement> getAchievementsByCategory(String category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getLockedAchievements() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }

  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  int getTotalPoints() {
    return _achievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, achievement) => sum + achievement.points);
  }

  int getAchievementCount() {
    return _achievements.where((a) => a.isUnlocked).length;
  }

  double getCompletionPercentage() {
    return getAchievementCount() / _achievements.length;
  }

  Future<bool> unlockAchievement(String id) async {
    final achievement = getAchievementById(id);
    if (achievement == null || achievement.isUnlocked) {
      return false;
    }

    // Simular desbloqueo
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index != -1) {
      _achievements[index] = achievement.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      return true;
    }

    return false;
  }

  Map<String, int> getPointsByCategory() {
    final Map<String, int> categoryPoints = {};

    for (final achievement in _achievements) {
      if (achievement.isUnlocked) {
        categoryPoints[achievement.category] =
            (categoryPoints[achievement.category] ?? 0) + achievement.points;
      }
    }

    return categoryPoints;
  }

  List<String> getCategories() {
    return _achievements.map((a) => a.category).toSet().toList()..sort();
  }

  // Métodos para verificar logros automáticamente
  Future<void> checkRoutineAchievements({
    required int routinesCompleted,
    required int currentStreak,
  }) async {
    // Primera rutina
    if (routinesCompleted >= 1) {
      await unlockAchievement('first_routine');
    }

    // Maestro de rutinas
    if (routinesCompleted >= 100) {
      await unlockAchievement('routine_master');
    }

    // Racha de semana
    if (currentStreak >= 7) {
      await unlockAchievement('week_streak');
    }

    // Racha de mes
    if (currentStreak >= 30) {
      await unlockAchievement('month_streak');
    }

    // Rey de la constancia
    if (currentStreak >= 90) {
      await unlockAchievement('consistency_king');
    }
  }

  Future<void> checkProgressAchievements({
    required int progressEntries,
    required bool weightGoalReached,
  }) async {
    // Primer progreso
    if (progressEntries >= 1) {
      await unlockAchievement('first_progress');
    }

    // Meta de peso
    if (weightGoalReached) {
      await unlockAchievement('weight_goal');
    }

    // Hitos de medidas
    if (progressEntries >= 10) {
      await unlockAchievement('measurement_milestone');
    }
  }

  Future<void> checkCommunityAchievements({
    required int sharesCount,
    required int likesGiven,
    required int followersCount,
  }) async {
    // Mariposa social
    if (sharesCount >= 1) {
      await unlockAchievement('social_butterfly');
    }

    // Motivador
    if (likesGiven >= 50) {
      await unlockAchievement('motivator');
    }

    // Líder comunitario
    if (followersCount >= 100) {
      await unlockAchievement('community_leader');
    }
  }

  Future<void> checkSpecialAchievements({
    required int earlyMorningRoutines,
    required int lateNightRoutines,
    required bool perfectWeek,
  }) async {
    // Madrugador
    if (earlyMorningRoutines >= 5) {
      await unlockAchievement('early_bird');
    }

    // Búho nocturno
    if (lateNightRoutines >= 5) {
      await unlockAchievement('night_owl');
    }

    // Semana perfecta
    if (perfectWeek) {
      await unlockAchievement('perfect_week');
    }
  }
}
