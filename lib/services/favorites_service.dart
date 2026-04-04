import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'secure_storage_service.dart';
import 'routine_service.dart';

class FavoritesService {
  static String get _base => AppConfig.backendUrl;

  static Future<Map<String, String>> _headers() async {
    final token = await SecureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Alterna favorito de una rutina. Devuelve el nuevo estado [isFavorite].
  static Future<bool> toggleFavorite(String routineId) async {
    final res = await http
        .post(
          Uri.parse('$_base/routines/$routineId/favorite'),
          headers: await _headers(),
        )
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return body['data']['isFavorite'] as bool;
    }
    throw Exception(body['message'] ?? 'Error al actualizar favorito');
  }

  /// Obtiene la lista de rutinas favoritas del usuario.
  static Future<List<Routine>> getFavorites({String lang = 'es'}) async {
    final res = await http
        .get(
          Uri.parse('$_base/routines/favorites?lang=$lang'),
          headers: await _headers(),
        )
        .timeout(AppConfig.apiTimeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      final List data = body['data']['routines'] ?? [];
      return data.map((r) => Routine.fromJson(r, lang: lang)).toList();
    }
    throw Exception(body['message'] ?? 'Error al cargar favoritos');
  }
}
