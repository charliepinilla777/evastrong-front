import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_service_v2.dart';
import 'secure_storage_service.dart';

/// Modelo de Rutina
class Routine {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final int duration;
  final String instructorName;
  final double rating;
  final int ratingCount;
  final int views;
  final String accessLevel;
  final List<String> tags;
  final DateTime createdAt;

  Routine({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.instructorName,
    required this.rating,
    required this.ratingCount,
    required this.views,
    required this.accessLevel,
    required this.tags,
    required this.createdAt,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'other',
      difficulty: json['difficulty'] ?? 'beginner',
      duration: json['duration'] ?? 0,
      instructorName: json['instructorName'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      views: json['views'] ?? 0,
      accessLevel: json['accessLevel'] ?? 'premium',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'difficulty': difficulty,
    'duration': duration,
    'instructorName': instructorName,
    'rating': rating,
    'ratingCount': ratingCount,
    'views': views,
    'accessLevel': accessLevel,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
  };
}

/// Servicio para gestionar rutinas
class RoutineService {
  // Usar configuración centralizada
  static String get _baseUrl => AppConfig.backendUrl;

  /// Obtener todas las rutinas con filtros
  static Future<Map<String, dynamic>> getRoutines({
    int page = 1,
    int limit = 10,
    String? category,
    String? difficulty,
    String? search,
  }) async {
    try {
      String url = '$_baseUrl/routines?page=$page&limit=$limit';

      if (category != null) url += '&category=$category';
      if (difficulty != null) url += '&difficulty=$difficulty';
      if (search != null) url += '&search=$search';

      final token = await SecureStorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw ApiException(
          message: 'Error al obtener rutinas',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener una rutina específica
  static Future<Routine> getRoutine(String routineId) async {
    try {
      final token = await SecureStorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('$_baseUrl/routines/$routineId'), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Routine.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        throw NotFoundError('Rutina no encontrada');
      } else {
        throw ApiException(
          message: 'Error al obtener rutina',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Valorar una rutina
  static Future<Map<String, dynamic>> rateRoutine({
    required String routineId,
    required int rating,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw ApiException(message: 'La valoración debe estar entre 1 y 5');
      }

      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/routines/$routineId/rate'),
            headers: headers,
            body: jsonEncode({'rating': rating}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          message: 'Error al valorar rutina',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener rutinas de un instructor
  static Future<List<Routine>> getInstructorRoutines(
    String instructorId,
  ) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/routines/instructor/$instructorId'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List routines = data['data'] ?? [];
        return routines.map((r) => Routine.fromJson(r)).toList();
      } else {
        throw ApiException(
          message: 'Error al obtener rutinas del instructor',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Crear nueva rutina (solo para instructores)
  static Future<Routine> createRoutine({
    required String title,
    required String description,
    required String category,
    required String difficulty,
    required int duration,
    required String accessLevel,
    List<String>? objectives,
    List<String>? targetMuscles,
    List<String>? equipment,
    List<Map<String, dynamic>>? exercises,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'duration': duration,
        'accessLevel': accessLevel,
        'objectives': objectives ?? [],
        'targetMuscles': targetMuscles ?? [],
        'equipment': equipment ?? [],
        'exercises': exercises ?? [],
      });

      final response = await http
          .post(Uri.parse('$_baseUrl/routines'), headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Routine.fromJson(data['data']);
      } else {
        throw ApiException(
          message: 'Error al crear rutina',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar rutina
  static Future<Routine> updateRoutine(
    String routineId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .put(
            Uri.parse('$_baseUrl/routines/$routineId'),
            headers: headers,
            body: jsonEncode(updates),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Routine.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        throw NotFoundError('Rutina no encontrada');
      } else {
        throw ApiException(
          message: 'Error al actualizar rutina',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Publicar rutina
  static Future<void> publishRoutine(String routineId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/routines/$routineId/publish'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Error al publicar rutina',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar rutina
  static Future<void> deleteRoutine(String routineId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final headers = {'Authorization': 'Bearer $token'};

      final response = await http
          .delete(Uri.parse('$_baseUrl/routines/$routineId'), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Error al eliminar rutina',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
