import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_service_v2.dart';
import 'cache_service.dart';
import 'secure_storage_service.dart';

/// Entrada de subtítulo sincronizada con el video
class SubtitleEntry {
  final Duration start;
  final Duration end;
  final String text;

  SubtitleEntry({
    required this.start,
    required this.end,
    required this.text,
  });

  factory SubtitleEntry.fromJson(Map<String, dynamic> json) {
    return SubtitleEntry(
      start: Duration(seconds: (json['start'] ?? 0).toInt()),
      end: Duration(seconds: (json['end'] ?? 0).toInt()),
      text: json['text'] ?? '',
    );
  }
}

/// Client-side Spanish→English title fallback for routines whose DB record
/// has not yet been migrated with titleEn.
const Map<String, String> _routineTitleEn = {
  // Seed-script routines
  '🔥 Vientre Plano en 21 Días':                   '🔥 Flat Belly in 21 Days',
  '🍑 Glúteos de Acero - Levanta y Tonifica':      '🍑 Steel Glutes - Lift & Tone',
  '✨ Adiós Celulitis - Piel Firme y Suave':        '✨ Bye Cellulite - Firm & Smooth Skin',
  '👙 Cintura de Sirena - Curvas Perfectas':        '👙 Mermaid Waist - Perfect Curves',
  '💪 Brazos de Modelo - Tonifica sin Volumen':     '💪 Model Arms - Tone Without Bulk',
  '🔥 Quema Grasa Total - 500 Calorías en 30 Min': '🔥 Total Fat Burn - 500 Calories in 30 Min',
  '🧘‍♀️ Flexibilidad Total - Cuerpo de Bailarina':  '🧘‍♀️ Full Flexibility - Dancer\'s Body',
  // seedRoutines.js — remaining
  'Eliminar la Flacidez':     'Eliminate Sagging',
  // seedElite.js
  'HIIT Metabólico Elite':          'Elite Metabolic HIIT',
  'Pilates Abdomen y Cintura':      'Pilates Abs & Waist',
  'Transformación Corporal 360°':   'Full Body Transformation 360°',
  // seedPremium.js
  'HIIT Express Quema Grasa':       'HIIT Express Fat Burn',
  'Yoga Restaurativo para Espalda': 'Restorative Back Yoga',
  'Full Body Escultura':            'Full Body Sculpt',
  // seedFichas
  'Glúteos Fáciles en Casa':        'Easy Home Glutes',
  'Tren Superior Suave sin Equipo': 'Gentle Upper Body No Equipment',
  'Cardio Suave Plus para Empezar': 'Gentle Cardio Plus for Beginners',
  // Admin-created routines
  'Levanta Cola':             'Lift & Tone Glutes',
  'Cintura Marcada':          'Defined Waist',
  'Pérdida de Peso':          'Weight Loss',
  'Tonificación de Piernas':  'Leg Toning',
  'Vientre Plano':            'Flat Belly',
  'Glúteos Perfectos':        'Perfect Glutes',
  'Brazos Tonificados':       'Toned Arms',
  'Espalda Fuerte':           'Strong Back',
  'Cardio Quema Grasa':       'Fat-Burning Cardio',
  'Flexibilidad y Movilidad': 'Flexibility & Mobility',
  'Fortalecimiento Total':    'Full-Body Strengthening',
  'Yoga para Principiantes':  'Yoga for Beginners',
  'HIIT Intenso':             'Intense HIIT',
  'Pilates Clásico':          'Classic Pilates',
  'Cuerpo Completo':          'Full Body',
  'Rutina Funcional':         'Functional Routine',
  'Abdomen Definido':         'Defined Abs',
  'Piernas y Glúteos':        'Legs & Glutes',
  'Tonificación General':     'General Toning',
  'Cardio Intenso':           'Intense Cardio',
  'Inicio Fit 15 min':        'Fit Start 15 min',
  'Inicio Fit 10 min':        'Fit Start 10 min',
};

String _localizeTitle(String title, String lang) {
  if (lang != 'en') return title;
  return _routineTitleEn[title] ?? title;
}

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
  final String? videoUrl;
  final List<SubtitleEntry> subtitles;

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
    this.videoUrl,
    this.subtitles = const [],
  });

  factory Routine.fromJson(Map<String, dynamic> json, {String lang = 'es'}) {
    final rawTitle = json['title'] as String? ?? '';
    final rawDesc  = json['description'] as String? ?? '';
    return Routine(
      id: json['_id'] ?? '',
      // Use server-provided titleEn if present, else try client-side map
      title: lang == 'en'
          ? (json['titleEn'] as String? ?? '').isNotEmpty
              ? json['titleEn'] as String
              : _localizeTitle(rawTitle, lang)
          : rawTitle,
      description: lang == 'en'
          ? (json['descriptionEn'] as String? ?? '').isNotEmpty
              ? json['descriptionEn'] as String
              : rawDesc
          : rawDesc,
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
      videoUrl: json['video']?['url'] as String?,
      subtitles: (json['subtitles'] as List? ?? [])
          .map((s) => SubtitleEntry.fromJson(s as Map<String, dynamic>))
          .toList(),
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

  /// Obtener todas las rutinas con filtros (stale-while-revalidate)
  static Future<Map<String, dynamic>> getRoutines({
    int page = 1,
    int limit = 10,
    String? category,
    String? difficulty,
    String? search,
    String lang = 'es',
  }) async {
    final cacheKey =
        'routines_p${page}_l${limit}_c${category ?? ''}_d${difficulty ?? ''}_s${search ?? ''}_${lang}';

    // Stale-while-revalidate: devuelve caché y refresca en background si stale
    final cached = await CacheService.get(cacheKey);
    if (cached != null) {
      if (cached.isStale) {
        // Refresca en background sin bloquear
        _fetchAndCacheRoutines(
          cacheKey: cacheKey,
          page: page,
          limit: limit,
          category: category,
          difficulty: difficulty,
          search: search,
          lang: lang,
        );
      }
      return Map<String, dynamic>.from(cached.data as Map);
    }

    // Sin caché: fetch normal (blocking)
    return _fetchAndCacheRoutines(
      cacheKey: cacheKey,
      page: page,
      limit: limit,
      category: category,
      difficulty: difficulty,
      search: search,
      lang: lang,
    );
  }

  static Future<Map<String, dynamic>> _fetchAndCacheRoutines({
    required String cacheKey,
    required int page,
    required int limit,
    String? category,
    String? difficulty,
    String? search,
    String lang = 'es',
  }) async {
    try {
      String url = '$_baseUrl/routines?page=$page&limit=$limit&lang=$lang';
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
          .timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await CacheService.set(cacheKey, data);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener una rutina específica
  static Future<Routine> getRoutine(String routineId, {String lang = 'es'}) async {
    try {
      final token = await SecureStorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('$_baseUrl/routines/$routineId?lang=$lang'), headers: headers)
          .timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
      final data = jsonDecode(response.body);
      return Routine.fromJson(data['data'], lang: lang);
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
          .timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
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
          .timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
      final data = jsonDecode(response.body);
      final List routines = data['data'] ?? [];
      return routines.map((r) => Routine.fromJson(r)).toList();
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
          .timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
      final data = jsonDecode(response.body);
      return Routine.fromJson(data['data']);
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
          .timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
      final data = jsonDecode(response.body);
      return Routine.fromJson(data['data']);
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
          .timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
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
          .timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
    } catch (e) {
      rethrow;
    }
  }
}
