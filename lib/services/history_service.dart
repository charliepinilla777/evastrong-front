import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'secure_storage_service.dart';

class WorkoutRecord {
  final String id;
  final String routineName;
  final String category;
  final int durationMinutes;
  final int caloriesEstimated;
  final DateTime completedAt;

  WorkoutRecord({
    required this.id,
    required this.routineName,
    required this.category,
    required this.durationMinutes,
    required this.caloriesEstimated,
    required this.completedAt,
  });

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      id: json['_id'] ?? '',
      routineName: json['routineName'] ?? '',
      category: json['category'] ?? 'general',
      durationMinutes: (json['durationMinutes'] ?? 0).toInt(),
      caloriesEstimated: (json['caloriesEstimated'] ?? 0).toInt(),
      completedAt: DateTime.parse(
          json['completedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class WorkoutStats {
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCalories;

  WorkoutStats({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCalories,
  });

  factory WorkoutStats.fromJson(Map<String, dynamic> json) {
    return WorkoutStats(
      totalWorkouts: (json['totalWorkouts'] ?? 0).toInt(),
      totalMinutes: (json['totalMinutes'] ?? 0).toInt(),
      totalCalories: (json['totalCalories'] ?? 0).toInt(),
    );
  }
}

class HistoryService {
  static String get _base => AppConfig.backendUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Guarda un entrenamiento completado en el historial.
  static Future<void> saveCompleted({
    required String routineName,
    required int durationMinutes,
    String? routineId,
    String category = 'general',
  }) async {
    final calories = (durationMinutes * 8).round();
    final res = await http
        .post(
          Uri.parse('$_base/routines/history'),
          headers: await _headers(),
          body: jsonEncode({
            'routineName': routineName,
            'routineId': routineId,
            'category': category,
            'durationMinutes': durationMinutes,
            'caloriesEstimated': calories,
          }),
        )
        .timeout(AppConfig.apiTimeout);

    if (res.statusCode != 201) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Error al guardar historial');
    }
  }

  /// Obtiene el historial de entrenamientos con estadísticas.
  static Future<({List<WorkoutRecord> records, WorkoutStats stats})>
      getHistory({int limit = 30}) async {
    final res = await http
        .get(
          Uri.parse('$_base/routines/history?limit=$limit'),
          headers: await _headers(),
        )
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      final records = (body['data']['records'] as List)
          .map((r) => WorkoutRecord.fromJson(r))
          .toList();
      final stats = WorkoutStats.fromJson(body['data']['stats']);
      return (records: records, stats: stats);
    }
    throw Exception(body['message'] ?? 'Error al cargar historial');
  }
}
