import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'secure_storage_service.dart';

/// Modelo de Perfil de Usuario
class UserProfile {
  final String ageRange;
  final String constitution;
  final String fitnessLevel;
  final bool kneeSensitive;
  final String pathologies;
  final int dailyTime;

  UserProfile({
    required this.ageRange,
    required this.constitution,
    required this.fitnessLevel,
    required this.kneeSensitive,
    required this.pathologies,
    required this.dailyTime,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      ageRange: json['ageRange'] ?? '',
      constitution: json['constitution'] ?? '',
      fitnessLevel: json['fitnessLevel'] ?? '',
      kneeSensitive: json['kneeSensitive'] ?? false,
      pathologies: json['pathologies'] ?? 'ninguna',
      dailyTime: json['dailyTime'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() => {
    'ageRange': ageRange,
    'constitution': constitution,
    'fitnessLevel': fitnessLevel,
    'kneeSensitive': kneeSensitive,
    'pathologies': pathologies,
    'dailyTime': dailyTime,
  };
}

/// Modelo de Ejercicio
class Exercise {
  final String exerciseId;
  final String name;
  final String shortDescription;
  final String type;
  final String zone;
  final int? timeSeconds;
  final int sets;
  final String? repetitions;
  final int restSeconds;
  final bool kneeFriendly;
  final int order;
  final String? videoUrl;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.shortDescription,
    required this.type,
    required this.zone,
    this.timeSeconds,
    this.sets = 1,
    this.repetitions,
    required this.restSeconds,
    required this.kneeFriendly,
    required this.order,
    this.videoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'] ?? '',
      name: json['name'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      type: json['type'] ?? '',
      zone: json['zone'] ?? '',
      timeSeconds: json['timeSeconds'],
      sets: (json['sets'] as num?)?.toInt() ?? 1,
      repetitions: json['repetitions'],
      restSeconds: json['restSeconds'] ?? 20,
      kneeFriendly: json['kneeFriendly'] ?? true,
      order: json['order'] ?? 0,
      videoUrl: json['video']?['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'name': name,
    'shortDescription': shortDescription,
    'type': type,
    'zone': zone,
    if (timeSeconds != null) 'timeSeconds': timeSeconds,
    'sets': sets,
    if (repetitions != null) 'repetitions': repetitions,
    'restSeconds': restSeconds,
    'kneeFriendly': kneeFriendly,
    'order': order,
    if (videoUrl != null) 'video': {'url': videoUrl},
  };
}

/// Modelo de Bloque de Rutina
class RoutineBlock {
  final List<Exercise> exercises;

  RoutineBlock({required this.exercises});

  factory RoutineBlock.fromJson(List<dynamic> json) {
    return RoutineBlock(
      exercises: json.map((e) => Exercise.fromJson(e)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() => 
      exercises.map((e) => e.toJson()).toList();
}

/// Modelo de Rutina Personalizada
class PersonalizedRoutine {
  final String name;
  final String description;
  final int duration;
  final int mainCycles;
  final RoutineBlock calentamiento;
  final RoutineBlock principal;
  final RoutineBlock enfriamiento;
  final UserProfile userProfile;

  PersonalizedRoutine({
    required this.name,
    required this.description,
    required this.duration,
    required this.mainCycles,
    required this.calentamiento,
    required this.principal,
    required this.enfriamiento,
    required this.userProfile,
  });

  factory PersonalizedRoutine.fromJson(Map<String, dynamic> json) {
    return PersonalizedRoutine(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      mainCycles: json['mainCycles'] ?? 2,
      calentamiento: RoutineBlock.fromJson(json['blocks']['calentamiento'] ?? []),
      principal: RoutineBlock.fromJson(json['blocks']['principal'] ?? []),
      enfriamiento: RoutineBlock.fromJson(json['blocks']['enfriamiento'] ?? []),
      userProfile: UserProfile.fromJson(json['userProfile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'duration': duration,
    'mainCycles': mainCycles,
    'blocks': {
      'calentamiento': calentamiento.toJson(),
      'principal': principal.toJson(),
      'enfriamiento': enfriamiento.toJson(),
    },
    'userProfile': userProfile.toJson(),
  };
}

/// Modelo de Plantilla de Rutina
class RoutineTemplate {
  final String templateId;
  final String name;
  final String description;
  final String category;
  final String intensity;
  final List<String> tags;
  final int baseDurationMinutes;
  final List<int> adjustableDurations;

  RoutineTemplate({
    required this.templateId,
    required this.name,
    required this.description,
    required this.category,
    required this.intensity,
    required this.tags,
    required this.baseDurationMinutes,
    required this.adjustableDurations,
  });

  factory RoutineTemplate.fromJson(Map<String, dynamic> json) {
    return RoutineTemplate(
      templateId: json['templateId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'funcional',
      intensity: json['intensity'] ?? 'moderada',
      tags: List<String>.from(json['tags'] ?? []),
      baseDurationMinutes: json['baseDurationMinutes'] ?? 15,
      adjustableDurations: List<int>.from(json['adjustableDurations'] ?? [10, 15, 20]),
    );
  }

  Map<String, dynamic> toJson() => {
    'templateId': templateId,
    'name': name,
    'description': description,
    'category': category,
    'intensity': intensity,
    'tags': tags,
    'baseDurationMinutes': baseDurationMinutes,
    'adjustableDurations': adjustableDurations,
  };
}

/// Servicio de Recomendaciones de Rutinas
class RoutineRecommendationService {
  static String get _baseUrl => AppConfig.backendUrl;

  /// Obtener rutina personalizada según perfil del usuario
  static Future<Map<String, dynamic>> getPersonalizedRoutine({String lang = 'es'}) async {
    try {
      final token = await SecureStorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final url = Uri.parse('$_baseUrl/routine-recommendations/personalized')
          .replace(queryParameters: {'lang': lang});
      final response = await http
          .get(url, headers: headers)
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Error al obtener rutina personalizada: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener todas las plantillas disponibles
  static Future<Map<String, dynamic>> getTemplates({
    int page = 1,
    int limit = 10,
    String? ageRange,
    String? level,
    bool? kneeSensitive,
    String? category,
    String? intensity,
    String lang = 'es',
  }) async {
    try {
      final params = <String, String>{
        'page': '$page', 'limit': '$limit', 'lang': lang,
        if (ageRange != null) 'ageRange': ageRange,
        if (level != null) 'level': level,
        if (kneeSensitive != null) 'kneeSensitive': '$kneeSensitive',
        if (category != null) 'category': category,
        if (intensity != null) 'intensity': intensity,
      };
      final String url = Uri.parse('$_baseUrl/routine-recommendations/templates')
          .replace(queryParameters: params).toString();

      final token = await SecureStorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Error al obtener plantillas: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener detalles de una plantilla específica
  static Future<Map<String, dynamic>> getTemplate(String templateId) async {
    try {
      final token = await SecureStorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('$_baseUrl/routine-recommendations/templates/$templateId'), headers: headers)
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Plantilla no encontrada');
      } else {
        throw Exception('Error al obtener plantilla: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Generar rutina personalizada desde una plantilla
  static Future<Map<String, dynamic>> generateRoutineFromTemplate({
    required String templateId,
    int? customTime,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'templateId': templateId,
        if (customTime != null) 'customTime': customTime,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/routine-recommendations/generate'),
            headers: headers,
            body: body,
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Error al generar rutina: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener perfil de fitness del usuario
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('$_baseUrl/routine-recommendations/profile'), headers: headers)
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Error al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar perfil de fitness del usuario
  static Future<Map<String, dynamic>> updateUserProfile({
    required String ageRange,
    required String constitution,
    required String fitnessLevel,
    required bool kneeSensitive,
    required String pathologies,
    int? dailyTime,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw Exception('Usuario no autenticado');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'ageRange': ageRange,
        'constitution': constitution,
        'fitnessLevel': fitnessLevel,
        'kneeSensitive': kneeSensitive,
        'pathologies': pathologies,
        if (dailyTime != null) 'dailyTime': dailyTime,
      });

      final response = await http
          .put(
            Uri.parse('$_baseUrl/routine-recommendations/profile'),
            headers: headers,
            body: body,
          )
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Error al actualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
