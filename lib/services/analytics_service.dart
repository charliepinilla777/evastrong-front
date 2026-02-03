import 'dart:async';
import 'package:flutter/material.dart';

/// Servicio para analíticas avanzadas de la aplicación
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Datos de usuario
  UserAnalyticsData _userData = UserAnalyticsData.empty();

  // Datos de sesión
  final List<SessionData> _sessions = [];

  // Eventos personalizados
  final List<CustomEvent> _events = [];

  /// Registrar evento personalizado
  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    final event = CustomEvent(
      name: eventName,
      timestamp: DateTime.now(),
      parameters: parameters ?? {},
    );

    _events.add(event);
    _saveEventToStorage(event);

    debugPrint('Analytics: Event tracked - $eventName');
  }

  /// Registrar vista de pantalla
  void trackScreenView(String screenName, {Duration? duration}) {
    trackEvent(
      'screen_view',
      parameters: {
        'screen_name': screenName,
        'duration_seconds': duration?.inSeconds ?? 0,
      },
    );
  }

  /// Registrar inicio de sesión
  void trackLogin(String method) {
    trackEvent(
      'login',
      parameters: {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Registro de rutina completada
  void trackRoutineCompleted(
    String routineId,
    String routineName,
    Duration duration,
  ) {
    trackEvent(
      'routine_completed',
      parameters: {
        'routine_id': routineId,
        'routine_name': routineName,
        'duration_seconds': duration.inSeconds,
        'completion_date': DateTime.now().toIso8601String(),
      },
    );

    _updateUserData(
      routinesCompleted: _userData.routinesCompleted + 1,
      totalWorkoutTime: _userData.totalWorkoutTime + duration.inSeconds,
    );
  }

  /// Registro de logro desbloqueado
  void trackAchievementUnlocked(String achievementId, String achievementName) {
    trackEvent(
      'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'unlock_date': DateTime.now().toIso8601String(),
      },
    );

    _updateUserData(achievementsUnlocked: _userData.achievementsUnlocked + 1);
  }

  /// Registro de interacción en comunidad
  void trackCommunityInteraction(String type, {String? targetId}) {
    trackEvent(
      'community_interaction',
      parameters: {
        'interaction_type': type,
        'target_id': targetId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Iniciar sesión de analítica
  void startSession() {
    final session = SessionData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );

    _sessions.add(session);
    debugPrint('Analytics: Session started - ${session.id}');
  }

  /// Finalizar sesión de analítica
  void endSession() {
    if (_sessions.isEmpty) return;

    final currentSession = _sessions.last;
    currentSession.endTime = DateTime.now();
    currentSession.duration = currentSession.endTime!.difference(
      currentSession.startTime,
    );

    _updateUserData(
      totalSessions: _userData.totalSessions + 1,
      totalSessionTime:
          _userData.totalSessionTime + currentSession.duration!.inSeconds,
    );

    debugPrint(
      'Analytics: Session ended - ${currentSession.id} (${currentSession.duration?.inSeconds}s)',
    );
  }

  /// Obtener datos analíticos del usuario
  UserAnalyticsData getUserData() {
    return _userData;
  }

  /// Obtener estadísticas de sesiones
  SessionStats getSessionStats() {
    if (_sessions.isEmpty) {
      return SessionStats.empty();
    }

    final totalSessions = _sessions.length;
    final totalDuration = _sessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + (session.duration ?? Duration.zero),
    );

    final averageDuration = totalSessions > 0
        ? Duration(seconds: totalDuration.inSeconds ~/ totalSessions)
        : Duration.zero;

    final longestSession = _sessions.reduce(
      (a, b) =>
          (a.duration ?? Duration.zero).inSeconds >
              (b.duration ?? Duration.zero).inSeconds
          ? a
          : b,
    );

    return SessionStats(
      totalSessions: totalSessions,
      totalDuration: totalDuration,
      averageDuration: averageDuration,
      longestSession: longestSession,
    );
  }

  /// Obtener eventos más frecuentes
  List<EventFrequency> getMostFrequentEvents({int limit = 10}) {
    final Map<String, int> eventCounts = {};

    for (final event in _events) {
      eventCounts[event.name] = (eventCounts[event.name] ?? 0) + 1;
    }

    final sortedEvents = eventCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEvents
        .take(limit)
        .map(
          (entry) => EventFrequency(eventName: entry.key, count: entry.value),
        )
        .toList();
  }

  /// Obtener análisis de uso de características
  FeatureUsage getFeatureUsage() {
    final Map<String, int> featureCounts = {};

    for (final session in _sessions) {
      // Analizar eventos de la sesión para determinar características usadas
      final sessionEvents = _events
          .where(
            (event) =>
                event.timestamp.isAfter(session.startTime) &&
                (session.endTime == null ||
                    event.timestamp.isBefore(session.endTime!)),
          )
          .toList();

      for (final event in sessionEvents) {
        if (event.name == 'screen_view') {
          final screenName = event.parameters['screen_name'] as String? ?? '';

          if (screenName.contains('routine')) {
            featureCounts['Routines'] = (featureCounts['Routines'] ?? 0) + 1;
          } else if (screenName.contains('community')) {
            featureCounts['Community'] = (featureCounts['Community'] ?? 0) + 1;
          } else if (screenName.contains('achievement')) {
            featureCounts['Achievements'] =
                (featureCounts['Achievements'] ?? 0) + 1;
          } else if (screenName.contains('tutorial')) {
            featureCounts['Tutorials'] = (featureCounts['Tutorials'] ?? 0) + 1;
          } else if (screenName.contains('wearable')) {
            featureCounts['Wearables'] = (featureCounts['Wearables'] ?? 0) + 1;
          }
        }
      }
    }

    final totalInteractions = featureCounts.values.fold(
      0,
      (sum, count) => sum + count,
    );

    return FeatureUsage(
      routines: featureCounts['Routines'] ?? 0,
      community: featureCounts['Community'] ?? 0,
      achievements: featureCounts['Achievements'] ?? 0,
      tutorials: featureCounts['Tutorials'] ?? 0,
      wearables: featureCounts['Wearables'] ?? 0,
      totalInteractions: totalInteractions,
    );
  }

  /// Generar reporte de analíticas
  AnalyticsReport generateReport() {
    final sessionStats = getSessionStats();
    final featureUsage = getFeatureUsage();
    final frequentEvents = getMostFrequentEvents();

    return AnalyticsReport(
      userData: _userData,
      sessionStats: sessionStats,
      featureUsage: featureUsage,
      frequentEvents: frequentEvents,
      generatedAt: DateTime.now(),
    );
  }

  /// Exportar datos a JSON
  Map<String, dynamic> exportToJson() {
    return {
      'user_data': _userData.toJson(),
      'sessions': _sessions.map((s) => s.toJson()).toList(),
      'events': _events.map((e) => e.toJson()).toList(),
      'report': generateReport().toJson(),
    };
  }

  /// Actualizar datos de usuario
  void _updateUserData({
    int? totalSessions,
    int? routinesCompleted,
    int? achievementsUnlocked,
    int? totalSessionTime,
    int? totalWorkoutTime,
  }) {
    _userData = _userData.copyWith(
      totalSessions: totalSessions,
      routinesCompleted: routinesCompleted,
      achievementsUnlocked: achievementsUnlocked,
      totalSessionTime: totalSessionTime,
      totalWorkoutTime: totalWorkoutTime,
      lastActiveDate: DateTime.now(),
    );

    _saveUserDataToStorage();
  }

  /// Guardar evento en almacenamiento local
  Future<void> _saveEventToStorage(CustomEvent event) async {
    // Implementar guardado en SharedPreferences o base de datos local
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// Guardar datos de usuario en almacenamiento
  Future<void> _saveUserDataToStorage() async {
    // Implementar guardado en SharedPreferences o base de datos local
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// Limpiar datos analíticos
  void clearAnalyticsData() {
    _userData = UserAnalyticsData.empty();
    _sessions.clear();
    _events.clear();

    debugPrint('Analytics: All data cleared');
  }
}

/// Datos analíticos del usuario
class UserAnalyticsData {
  final int totalSessions;
  final int routinesCompleted;
  final int achievementsUnlocked;
  final int totalSessionTime; // en segundos
  final int totalWorkoutTime; // en segundos
  final DateTime? lastActiveDate;
  final DateTime createdAt;

  UserAnalyticsData({
    required this.totalSessions,
    required this.routinesCompleted,
    required this.achievementsUnlocked,
    required this.totalSessionTime,
    required this.totalWorkoutTime,
    this.lastActiveDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserAnalyticsData.empty() {
    return UserAnalyticsData(
      totalSessions: 0,
      routinesCompleted: 0,
      achievementsUnlocked: 0,
      totalSessionTime: 0,
      totalWorkoutTime: 0,
      createdAt: DateTime.now(),
    );
  }

  UserAnalyticsData copyWith({
    int? totalSessions,
    int? routinesCompleted,
    int? achievementsUnlocked,
    int? totalSessionTime,
    int? totalWorkoutTime,
    DateTime? lastActiveDate,
  }) {
    return UserAnalyticsData(
      totalSessions: totalSessions ?? this.totalSessions,
      routinesCompleted: routinesCompleted ?? this.routinesCompleted,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      totalSessionTime: totalSessionTime ?? this.totalSessionTime,
      totalWorkoutTime: totalWorkoutTime ?? this.totalWorkoutTime,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt,
    );
  }

  /// Calcular nivel de engagement
  double get engagementScore {
    final sessionScore = (totalSessions / 30.0).clamp(0.0, 1.0); // Sesiones/mes
    final routineScore = (routinesCompleted / 20.0).clamp(
      0.0,
      1.0,
    ); // Rutinas/mes
    final achievementScore = (achievementsUnlocked / 10.0).clamp(
      0.0,
      1.0,
    ); // Logros/mes

    return ((sessionScore + routineScore + achievementScore) / 3.0) * 100;
  }

  /// Calcular días activos
  int get activeDays {
    if (lastActiveDate == null) return 0;
    return DateTime.now().difference(createdAt).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'routines_completed': routinesCompleted,
      'achievements_unlocked': achievementsUnlocked,
      'total_session_time': totalSessionTime,
      'total_workout_time': totalWorkoutTime,
      'last_active_date': lastActiveDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'engagement_score': engagementScore,
      'active_days': activeDays,
    };
  }
}

/// Datos de sesión
class SessionData {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  Duration? duration;

  SessionData({
    required this.id,
    required this.startTime,
    this.endTime,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_seconds': duration?.inSeconds,
    };
  }
}

/// Evento personalizado
class CustomEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic> parameters;

  CustomEvent({
    required this.name,
    required this.timestamp,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'parameters': parameters,
    };
  }
}

/// Estadísticas de sesiones
class SessionStats {
  final int totalSessions;
  final Duration totalDuration;
  final Duration averageDuration;
  final SessionData longestSession;

  SessionStats({
    required this.totalSessions,
    required this.totalDuration,
    required this.averageDuration,
    required this.longestSession,
  });

  factory SessionStats.empty() {
    return SessionStats(
      totalSessions: 0,
      totalDuration: Duration.zero,
      averageDuration: Duration.zero,
      longestSession: SessionData(id: 'empty', startTime: DateTime.now()),
    );
  }
}

/// Frecuencia de eventos
class EventFrequency {
  final String eventName;
  final int count;

  EventFrequency({required this.eventName, required this.count});
}

/// Uso de características
class FeatureUsage {
  final int routines;
  final int community;
  final int achievements;
  final int tutorials;
  final int wearables;
  final int totalInteractions;

  FeatureUsage({
    required this.routines,
    required this.community,
    required this.achievements,
    required this.tutorials,
    required this.wearables,
    required this.totalInteractions,
  });
}

/// Reporte completo de analíticas
class AnalyticsReport {
  final UserAnalyticsData userData;
  final SessionStats sessionStats;
  final FeatureUsage featureUsage;
  final List<EventFrequency> frequentEvents;
  final DateTime generatedAt;

  AnalyticsReport({
    required this.userData,
    required this.sessionStats,
    required this.featureUsage,
    required this.frequentEvents,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_data': userData.toJson(),
      'session_stats': {
        'total_sessions': sessionStats.totalSessions,
        'total_duration_seconds': sessionStats.totalDuration.inSeconds,
        'average_duration_seconds': sessionStats.averageDuration.inSeconds,
        'longest_session': sessionStats.longestSession.toJson(),
      },
      'feature_usage': {
        'routines': featureUsage.routines,
        'community': featureUsage.community,
        'achievements': featureUsage.achievements,
        'tutorials': featureUsage.tutorials,
        'wearables': featureUsage.wearables,
        'total_interactions': featureUsage.totalInteractions,
      },
      'frequent_events': frequentEvents
          .map((e) => {'event_name': e.eventName, 'count': e.count})
          .toList(),
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
