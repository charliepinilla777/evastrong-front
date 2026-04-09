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

/// Client-side Spanish→English description fallback for routines whose DB
/// record has not yet been migrated with descriptionEn.
const Map<String, String> _routineDescEn = {
  // seed-routines.js
  'Elimina la pancita rebelde con esta rutina diseñada específicamente para mujeres. Combina ejercicios de core, cardio y respiración para resultados visibles.':
      'Eliminate stubborn belly fat with this routine designed specifically for women. Combines core exercises, cardio, and breathing for visible results.',
  'Transforma tus glúteos con esta rutina intensiva. Resultados reales en 4 semanas. ¡Di adiós a la flacidez!':
      'Transform your glutes with this intensive routine. Real results in 4 weeks. Say goodbye to sagging!',
  'Rutina anti-celulitis que combina ejercicios de tonificación y activación circulatoria. Mejora la apariencia de tu piel desde la primera semana.':
      'Anti-cellulite routine combining toning and circulatory activation exercises. Improve the appearance of your skin from the very first week.',
  'Define tu cintura y crea esas curvas envidiables. Ejercicios enfocados en oblicuos y core lateral para una figura de reloj de arena.':
      'Define your waist and create enviable curves. Exercises focused on obliques and lateral core for an hourglass figure.',
  'Brazos delgados, firmes y definidos sin perder feminidad. Ejercicios específicos para eliminar la flacidez y tonificar sin agrandar.':
      'Slim, firm and defined arms without losing femininity. Specific exercises to eliminate sagging and tone without bulking up.',
  'HIIT intensivo diseñado para mujeres. Quema grasa en todo el cuerpo mientras tonificas. Perfecto para acelerar tu metabolismo.':
      'Intensive HIIT designed for women. Burn fat all over your body while toning. Perfect for boosting your metabolism.',
  'Gana flexibilidad, alarga músculos y mejora tu postura. Ideal para relajar después de entrenar o como rutina nocturna.':
      'Gain flexibility, lengthen muscles and improve your posture. Ideal for relaxing after training or as a night routine.',
  // seedRoutines.js
  'Rutina enfocada en glúteos para conseguir unas nalgas firmes y redondeadas. Combina ejercicios de fuerza y activación muscular progresiva sin necesidad de material.':
      'Glute-focused routine to achieve firm and rounded buttocks. Combines strength and progressive muscle activation with no equipment needed.',
  'Rutina de tonificación corporal diseñada para firmar y definir la piel. Combina ejercicios de fuerza con activación muscular de alta frecuencia para conseguir un cuerpo tonificado y firme.':
      'Body toning routine designed to firm and define your skin. Combines strength exercises with high-frequency muscle activation for a toned and firm body.',
  'Rutina específica para fortalecer y definir cuádriceps, isquiotibiales y pantorrillas. Ejercicios progresivos adaptados a principiantes que buscan piernas más fuertes y esbeltas.':
      'Specific routine to strengthen and define quads, hamstrings and calves. Progressive exercises adapted for beginners looking for stronger, slimmer legs.',
  'Rutina de alta intensidad diseñada para maximizar el gasto calórico y acelerar el metabolismo. Combina cardio funcional y ejercicios de fuerza en circuito para quemar grasa de forma eficiente.':
      'High-intensity routine designed to maximize calorie burn and speed up metabolism. Combines functional cardio and strength exercises in a circuit to burn fat efficiently.',
  'Rutina avanzada focalizada en el trabajo de core profundo y oblicuos para conseguir un abdomen plano y una cintura definida. Alta intensidad con ejercicios que demandan control y estabilidad.':
      'Advanced routine focused on deep core and oblique work to achieve a flat belly and defined waist. High intensity with exercises that demand control and stability.',
  // seedPremium.js
  'Rutina de alta intensidad por intervalos para quemar grasa en solo 30 min. Sin material, máximo resultado en poco tiempo.':
      'High-intensity interval routine to burn fat in just 30 min. No equipment needed, maximum results in minimal time.',
  'Secuencia de yoga suave diseñada para aliviar tensión en espalda, cuello y caderas. Perfecta para mujeres con trabajo sedentario o molestias posturales.':
      'Gentle yoga sequence designed to relieve tension in the back, neck and hips. Perfect for women with sedentary jobs or postural discomfort.',
  'Rutina completa de tonificación para definir y esculpir todo el cuerpo en 40 min. Combina fuerza funcional con ejercicios compuestos para máxima eficiencia.':
      'Complete toning routine to define and sculpt the entire body in 40 min. Combines functional strength with compound exercises for maximum efficiency.',
  // seedElite.js
  'Entrenamiento de alta intensidad metabólica para mujeres avanzadas que buscan máximo rendimiento, quema de grasa y definición total en 35 min.':
      'High-intensity metabolic training for advanced women seeking maximum performance, fat burn and total definition in 35 min.',
  'Sesión de pilates avanzado centrada en el trabajo profundo del core para conseguir un abdomen plano y cintura definida. Requiere concentración y control total.':
      'Advanced pilates session focused on deep core work to achieve a flat belly and defined waist. Requires full concentration and body control.',
  'Rutina funcional avanzada que trabaja todo el cuerpo con banda elástica y peso corporal. Diseñada para mujeres que buscan una transformación física completa y duradera.':
      'Advanced functional routine working the entire body with resistance band and bodyweight. Designed for women seeking a complete and lasting physical transformation.',
  // seedFicha1.js
  'Rutina sin equipo para tonificar glúteos y piernas en 25 min. Ideal para empezar con confianza y ver resultados rápidos.':
      'Equipment-free routine to tone glutes and legs in 25 min. Perfect to start with confidence and see quick results.',
  // seedFicha5.js
  'Rutina de 20 min para tonificar brazos, espalda y pecho solo con peso corporal, ideal para empezar a ganar fuerza sin materiales.':
      '20-min routine to tone arms, back and chest using only bodyweight — ideal for building strength with no equipment.',
  // seedFicha6.js
  '20 min de cardio de bajo impacto ideal para mujeres con sobrepeso u obesidad que quieren empezar sin daño articular.':
      '20 min of low-impact cardio ideal for women with excess weight who want to start exercising without joint strain.',
};

String _localizeDesc(String desc, String lang) {
  if (lang != 'en') return desc;
  return _routineDescEn[desc] ?? desc;
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
              : _localizeDesc(rawDesc, lang)
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
