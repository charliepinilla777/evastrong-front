import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_service.dart';

class Achievement {
  final String id;
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String icon;
  final int points;
  final String category;
  final String categoryEn;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.category,
    String? titleEn,
    String? descriptionEn,
    String? categoryEn,
    this.isUnlocked = false,
    this.unlockedAt,
  })  : titleEn = titleEn ?? title,
        descriptionEn = descriptionEn ?? description,
        categoryEn = categoryEn ?? category;

  String localizedTitle(bool isEn) => isEn ? titleEn : title;
  String localizedDescription(bool isEn) => isEn ? descriptionEn : description;
  String localizedCategory(bool isEn) => isEn ? categoryEn : category;

  Achievement copyWith({
    String? id,
    String? title,
    String? titleEn,
    String? description,
    String? descriptionEn,
    String? icon,
    int? points,
    String? category,
    String? categoryEn,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      category: category ?? this.category,
      categoryEn: categoryEn ?? this.categoryEn,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  static const _prefsKey = 'eva_unlocked_achievements';

  final List<Achievement> _achievements = [
    // Rutinas
    Achievement(
      id: 'first_routine',
      title: 'Primer Paso',          titleEn: 'First Step',
      description: 'Completa tu primera rutina',
      descriptionEn: 'Complete your first workout',
      icon: '🎯', points: 10,
      category: 'Rutinas',           categoryEn: 'Workouts',
    ),
    Achievement(
      id: 'week_streak',
      title: 'Semana Fuerte',        titleEn: 'Strong Week',
      description: 'Completa rutinas 7 días seguidos',
      descriptionEn: 'Complete workouts 7 days in a row',
      icon: '🔥', points: 50,
      category: 'Rutinas',           categoryEn: 'Workouts',
    ),
    Achievement(
      id: 'month_streak',
      title: 'Mes Legendario',       titleEn: 'Legendary Month',
      description: 'Completa rutinas 30 días seguidos',
      descriptionEn: 'Complete workouts 30 days in a row',
      icon: '👑', points: 200,
      category: 'Rutinas',           categoryEn: 'Workouts',
    ),
    Achievement(
      id: 'routine_master',
      title: 'Maestro de Rutinas',   titleEn: 'Workout Master',
      description: 'Completa 100 rutinas',
      descriptionEn: 'Complete 100 workouts',
      icon: '💪', points: 150,
      category: 'Rutinas',           categoryEn: 'Workouts',
    ),

    // Progresos
    Achievement(
      id: 'first_progress',
      title: 'En Camino',            titleEn: 'On Your Way',
      description: 'Registra tu primer progreso',
      descriptionEn: 'Log your first progress',
      icon: '📈', points: 15,
      category: 'Progreso',          categoryEn: 'Progress',
    ),
    Achievement(
      id: 'weight_goal',
      title: 'Meta de Peso',         titleEn: 'Weight Goal',
      description: 'Alcanza tu objetivo de peso',
      descriptionEn: 'Reach your weight goal',
      icon: '⚖️', points: 100,
      category: 'Progreso',          categoryEn: 'Progress',
    ),
    Achievement(
      id: 'measurement_milestone',
      title: 'Hitos de Medidas',     titleEn: 'Measurement Milestone',
      description: 'Toma medidas 10 veces',
      descriptionEn: 'Record measurements 10 times',
      icon: '📏', points: 30,
      category: 'Progreso',          categoryEn: 'Progress',
    ),

    // Comunidad
    Achievement(
      id: 'social_butterfly',
      title: 'Mariposa Social',      titleEn: 'Social Butterfly',
      description: 'Comparte tu primer progreso',
      descriptionEn: 'Share your first progress',
      icon: '🦋', points: 20,
      category: 'Comunidad',         categoryEn: 'Community',
    ),
    Achievement(
      id: 'motivator',
      title: 'Motivador',            titleEn: 'Motivator',
      description: 'Da 50 likes a otros usuarios',
      descriptionEn: 'Give 50 likes to other users',
      icon: '❤️', points: 40,
      category: 'Comunidad',         categoryEn: 'Community',
    ),
    Achievement(
      id: 'community_leader',
      title: 'Líder Comunitario',    titleEn: 'Community Leader',
      description: 'Obtén 100 seguidores',
      descriptionEn: 'Get 100 followers',
      icon: '🌟', points: 80,
      category: 'Comunidad',         categoryEn: 'Community',
    ),

    // Especiales
    Achievement(
      id: 'early_bird',
      title: 'Madrugadora',          titleEn: 'Early Bird',
      description: 'Completa 5 rutinas antes de las 6am',
      descriptionEn: 'Complete 5 workouts before 6am',
      icon: '🌅', points: 35,
      category: 'Especial',          categoryEn: 'Special',
    ),
    Achievement(
      id: 'night_owl',
      title: 'Búho Nocturno',        titleEn: 'Night Owl',
      description: 'Completa 5 rutinas después de las 10pm',
      descriptionEn: 'Complete 5 workouts after 10pm',
      icon: '🦉', points: 35,
      category: 'Especial',          categoryEn: 'Special',
    ),
    Achievement(
      id: 'perfect_week',
      title: 'Semana Perfecta',      titleEn: 'Perfect Week',
      description: 'Completa rutinas los 7 días de una semana',
      descriptionEn: 'Complete workouts all 7 days of a week',
      icon: '✨', points: 75,
      category: 'Especial',          categoryEn: 'Special',
    ),
    Achievement(
      id: 'consistency_king',
      title: 'Reina de la Constancia', titleEn: 'Queen of Consistency',
      description: 'Mantén una racha de 90 días',
      descriptionEn: 'Maintain a 90-day streak',
      icon: '🏆', points: 500,
      category: 'Especial',          categoryEn: 'Special',
    ),
  ];

  // ── Persistencia ────────────────────────────────────────────────────────────

  /// Carga el estado desbloqueado guardado en disco.
  Future<void> loadUnlockedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;

      final Map<String, dynamic> saved = jsonDecode(raw);
      for (int i = 0; i < _achievements.length; i++) {
        final data = saved[_achievements[i].id];
        if (data != null && data['unlocked'] == true) {
          _achievements[i] = _achievements[i].copyWith(
            isUnlocked: true,
            unlockedAt: data['unlockedAt'] != null
                ? DateTime.tryParse(data['unlockedAt'])
                : null,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _saveUnlockedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toSave = {};
      for (final a in _achievements) {
        if (a.isUnlocked) {
          toSave[a.id] = {
            'unlocked': true,
            'unlockedAt': a.unlockedAt?.toIso8601String(),
          };
        }
      }
      await prefs.setString(_prefsKey, jsonEncode(toSave));
    } catch (_) {}
  }

  // ── Evaluación automática desde historial real ───────────────────────────────

  /// Evalúa y desbloquea logros basándose en el historial real de la usuaria.
  Future<List<Achievement>> evaluateFromHistory(
    List<WorkoutRecord> records,
    WorkoutStats stats,
  ) async {
    final streak = _calculateStreak(records);
    final newly = <Achievement>[];

    // ── Rutinas ──
    if (stats.totalWorkouts >= 1) {
      if (await unlockAchievement('first_routine')) {
        newly.add(getAchievementById('first_routine')!);
      }
    }
    if (stats.totalWorkouts >= 100) {
      if (await unlockAchievement('routine_master')) {
        newly.add(getAchievementById('routine_master')!);
      }
    }
    if (streak >= 7) {
      if (await unlockAchievement('week_streak')) {
        newly.add(getAchievementById('week_streak')!);
      }
    }
    if (streak >= 30) {
      if (await unlockAchievement('month_streak')) {
        newly.add(getAchievementById('month_streak')!);
      }
    }
    if (streak >= 90) {
      if (await unlockAchievement('consistency_king')) {
        newly.add(getAchievementById('consistency_king')!);
      }
    }

    // ── Especiales ──
    final earlyCount =
        records.where((r) => r.completedAt.hour < 6).length;
    if (earlyCount >= 5) {
      if (await unlockAchievement('early_bird')) {
        newly.add(getAchievementById('early_bird')!);
      }
    }

    final lateCount =
        records.where((r) => r.completedAt.hour >= 22).length;
    if (lateCount >= 5) {
      if (await unlockAchievement('night_owl')) {
        newly.add(getAchievementById('night_owl')!);
      }
    }

    if (_hasPerfectWeek(records)) {
      if (await unlockAchievement('perfect_week')) {
        newly.add(getAchievementById('perfect_week')!);
      }
    }

    return newly;
  }

  int _calculateStreak(List<WorkoutRecord> records) {
    if (records.isEmpty) return 0;
    final today = DateTime.now();
    final trainedDays = records
        .map((r) => DateTime(
            r.completedAt.year, r.completedAt.month, r.completedAt.day))
        .toSet();

    int streak = 0;
    DateTime day = DateTime(today.year, today.month, today.day);
    while (trainedDays.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool _hasPerfectWeek(List<WorkoutRecord> records) {
    // Busca alguna semana (lun-dom) donde haya registros los 7 días
    final trainedDays = records
        .map((r) => DateTime(
            r.completedAt.year, r.completedAt.month, r.completedAt.day))
        .toSet();

    // Verificar las últimas 8 semanas
    final now = DateTime.now();
    for (int w = 0; w < 8; w++) {
      final monday = now.subtract(Duration(days: now.weekday - 1 + w * 7));
      final weekStart = DateTime(monday.year, monday.month, monday.day);
      bool allDays = true;
      for (int d = 0; d < 7; d++) {
        if (!trainedDays.contains(weekStart.add(Duration(days: d)))) {
          allDays = false;
          break;
        }
      }
      if (allDays) return true;
    }
    return false;
  }

  // ── API pública ──────────────────────────────────────────────────────────────

  List<Achievement> getAllAchievements() => List.from(_achievements);

  /// Returns achievements for the given ES category name.
  List<Achievement> getAchievementsByCategory(String category) =>
      _achievements.where((a) => a.category == category).toList();

  /// Returns localized categories (unique, sorted).
  List<String> getLocalizedCategories({bool isEn = false}) => _achievements
      .map((a) => isEn ? a.categoryEn : a.category)
      .toSet()
      .toList()..sort();

  /// Returns achievements filtered by the localized category name.
  List<Achievement> getAchievementsByLocalizedCategory(
    String localizedCategory, {
    bool isEn = false,
  }) =>
      _achievements.where((a) {
        return isEn
            ? a.categoryEn == localizedCategory
            : a.category == localizedCategory;
      }).toList();

  /// Returns points grouped by localized category name.
  Map<String, int> getLocalizedPointsByCategory({bool isEn = false}) {
    final Map<String, int> result = {};
    for (final a in _achievements) {
      if (a.isUnlocked) {
        final key = isEn ? a.categoryEn : a.category;
        result[key] = (result[key] ?? 0) + a.points;
      }
    }
    return result;
  }

  List<Achievement> getUnlockedAchievements() =>
      _achievements.where((a) => a.isUnlocked).toList();

  List<Achievement> getLockedAchievements() =>
      _achievements.where((a) => !a.isUnlocked).toList();

  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  int getTotalPoints() => _achievements
      .where((a) => a.isUnlocked)
      .fold(0, (sum, a) => sum + a.points);

  int getAchievementCount() =>
      _achievements.where((a) => a.isUnlocked).length;

  double getCompletionPercentage() =>
      getAchievementCount() / _achievements.length;

  Future<bool> unlockAchievement(String id) async {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index == -1 || _achievements[index].isUnlocked) return false;

    _achievements[index] = _achievements[index].copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );
    await _saveUnlockedState();
    return true;
  }

  Map<String, int> getPointsByCategory() {
    final Map<String, int> result = {};
    for (final a in _achievements) {
      if (a.isUnlocked) {
        result[a.category] = (result[a.category] ?? 0) + a.points;
      }
    }
    return result;
  }

  List<String> getCategories() =>
      _achievements.map((a) => a.category).toSet().toList()..sort();

  // Mantener métodos legacy para compatibilidad
  Future<void> checkRoutineAchievements({
    required int routinesCompleted,
    required int currentStreak,
  }) async {
    if (routinesCompleted >= 1) await unlockAchievement('first_routine');
    if (routinesCompleted >= 100) await unlockAchievement('routine_master');
    if (currentStreak >= 7) await unlockAchievement('week_streak');
    if (currentStreak >= 30) await unlockAchievement('month_streak');
    if (currentStreak >= 90) await unlockAchievement('consistency_king');
  }

  Future<void> checkProgressAchievements({
    required int progressEntries,
    required bool weightGoalReached,
  }) async {
    if (progressEntries >= 1) await unlockAchievement('first_progress');
    if (weightGoalReached) await unlockAchievement('weight_goal');
    if (progressEntries >= 10) await unlockAchievement('measurement_milestone');
  }

  Future<void> checkCommunityAchievements({
    required int sharesCount,
    required int likesGiven,
    required int followersCount,
  }) async {
    if (sharesCount >= 1) await unlockAchievement('social_butterfly');
    if (likesGiven >= 50) await unlockAchievement('motivator');
    if (followersCount >= 100) await unlockAchievement('community_leader');
  }

  Future<void> checkSpecialAchievements({
    required int earlyMorningRoutines,
    required int lateNightRoutines,
    required bool perfectWeek,
  }) async {
    if (earlyMorningRoutines >= 5) await unlockAchievement('early_bird');
    if (lateNightRoutines >= 5) await unlockAchievement('night_owl');
    if (perfectWeek) await unlockAchievement('perfect_week');
  }
}
