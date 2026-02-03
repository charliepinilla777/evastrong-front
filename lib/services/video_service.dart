import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'api_service_v2.dart';
import 'secure_storage_service.dart';

/// Modelo de Video
class VideoModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String? exerciseName;
  final String uploadedByName;
  final int views;
  final int likes;
  final double averageRating;
  final int ratingCount;
  final String accessLevel;
  final String visibility;
  final List<String> tags;
  final List<String> muscleGroups;
  final List<String> equipment;
  final int videoDuration;
  final DateTime createdAt;
  final String? videoUrl;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    this.exerciseName,
    required this.uploadedByName,
    required this.views,
    required this.likes,
    required this.averageRating,
    required this.ratingCount,
    required this.accessLevel,
    required this.visibility,
    required this.tags,
    required this.muscleGroups,
    required this.equipment,
    required this.videoDuration,
    required this.createdAt,
    this.videoUrl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'exercise',
      difficulty: json['difficulty'] ?? 'intermediate',
      exerciseName: json['exerciseName'],
      uploadedByName: json['uploadedByName'] ?? '',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      averageRating: (json['ratings']?['average'] ?? 0).toDouble(),
      ratingCount: json['ratings']?['count'] ?? 0,
      accessLevel: json['accessLevel'] ?? 'premium',
      visibility: json['visibility'] ?? 'public',
      tags: List<String>.from(json['tags'] ?? []),
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      equipment: List<String>.from(json['equipment'] ?? []),
      videoDuration: json['video']?['duration'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      videoUrl: json['video']?['cloudUrl'] ?? json['video']?['url'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'difficulty': difficulty,
    'exerciseName': exerciseName,
    'uploadedByName': uploadedByName,
    'views': views,
    'likes': likes,
    'averageRating': averageRating,
    'ratingCount': ratingCount,
    'accessLevel': accessLevel,
    'visibility': visibility,
    'tags': tags,
    'muscleGroups': muscleGroups,
    'equipment': equipment,
    'videoDuration': videoDuration,
    'createdAt': createdAt.toIso8601String(),
    'videoUrl': videoUrl,
  };
}

/// Servicio para gestionar videos
class VideoService {
  // Usar configuración centralizada
  static String get _baseUrl => AppConfig.backendUrl;

  /// Obtener todos los videos con filtros
  static Future<Map<String, dynamic>> getVideos({
    int page = 1,
    int limit = 10,
    String? category,
    String? difficulty,
    String? exerciseName,
    String? search,
  }) async {
    try {
      String url = '$_baseUrl/videos?page=$page&limit=$limit';

      if (category != null) url += '&category=$category';
      if (difficulty != null) url += '&difficulty=$difficulty';
      if (exerciseName != null) url += '&exerciseName=$exerciseName';
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
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          message: 'Error al obtener videos',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener un video específico
  static Future<VideoModel> getVideo(String videoId) async {
    try {
      final token = await SecureStorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('$_baseUrl/videos/$videoId'), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoModel.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        throw NotFoundError('Video no encontrado');
      } else {
        throw ApiException(
          message: 'Error al obtener video',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Subir video
  static Future<VideoModel> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    required String category,
    required String difficulty,
    String? exerciseName,
    List<String>? muscleGroups,
    List<String>? equipment,
    String? accessLevel,
    List<String>? tags,
    required Function(int, int) onProgress,
  }) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final uri = Uri.parse('$_baseUrl/videos/upload');
      final request = http.MultipartRequest('POST', uri);

      // Agregar headers
      request.headers['Authorization'] = 'Bearer $token';

      // Agregar campos de texto
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['difficulty'] = difficulty;
      if (exerciseName != null) request.fields['exerciseName'] = exerciseName;
      if (accessLevel != null) request.fields['accessLevel'] = accessLevel;

      if (muscleGroups != null) {
        request.fields['muscleGroups'] = jsonEncode(muscleGroups);
      }
      if (equipment != null) {
        request.fields['equipment'] = jsonEncode(equipment);
      }
      if (tags != null) {
        request.fields['tags'] = jsonEncode(tags);
      }

      // Agregar archivo
      final videoStream = http.ByteStream(videoFile.openRead());
      final videoLength = await videoFile.length();

      final multipartFile = http.MultipartFile(
        'video',
        videoStream,
        videoLength,
        filename: videoFile.path.split('/').last,
      );

      request.files.add(multipartFile);

      // Enviar con progress
      final streamResponse = await request.send().timeout(
        const Duration(minutes: 30),
        onTimeout: () {
          throw NetworkException(message: 'Timeout al subir video');
        },
      );

      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return VideoModel.fromJson(data['data']);
      } else {
        throw ApiException(
          message: 'Error al subir video',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Valorar video
  static Future<Map<String, dynamic>> rateVideo({
    required String videoId,
    required int rating,
    String? comment,
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
            Uri.parse('$_baseUrl/videos/$videoId/rate'),
            headers: headers,
            body: jsonEncode({
              'rating': rating,
              if (comment != null) 'comment': comment,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw ApiException(
          message: 'Error al valorar video',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener videos de un usuario
  static Future<List<VideoModel>> getUserVideos(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/videos/uploader/$userId'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List videos = data['data'] ?? [];
        return videos.map((v) => VideoModel.fromJson(v)).toList();
      } else {
        throw ApiException(
          message: 'Error al obtener videos del usuario',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar información del video
  static Future<VideoModel> updateVideo(
    String videoId,
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
            Uri.parse('$_baseUrl/videos/$videoId'),
            headers: headers,
            body: jsonEncode(updates),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VideoModel.fromJson(data['data']);
      } else {
        throw ApiException(
          message: 'Error al actualizar video',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Publicar video
  static Future<void> publishVideo(String videoId) async {
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
            Uri.parse('$_baseUrl/videos/$videoId/publish'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Error al publicar video',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar video
  static Future<void> deleteVideo(String videoId) async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final headers = {'Authorization': 'Bearer $token'};

      final response = await http
          .delete(Uri.parse('$_baseUrl/videos/$videoId'), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Error al eliminar video',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener URL para stream de video
  static String getVideoStreamUrl(String videoId) {
    return '$_baseUrl/videos/$videoId/stream';
  }
}
