import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import '../services/secure_storage_service.dart';
import 'diet_service.dart';

class DietRecommendationResult {
  final bool profileComplete;
  final String? dietLabel;
  final String? dietIcon;
  final List<RecipeModel> recommendations;

  const DietRecommendationResult({
    required this.profileComplete,
    this.dietLabel,
    this.dietIcon,
    required this.recommendations,
  });
}

class DietRecommendationService {
  /// Devuelve recetas recomendadas según el perfil físico del usuario.
  /// Si el perfil no está completo, [profileComplete] será false y
  /// [recommendations] estará vacío.
  static Future<DietRecommendationResult> getPersonalized() async {
    final token = await SecureStorageService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http
        .get(
          Uri.parse('${AppConfig.dietRecommendationsUrl}/personalized'),
          headers: headers,
        )
        .timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
      final profileComplete = data['profileComplete'] as bool? ?? false;

      if (!profileComplete) {
        return const DietRecommendationResult(
          profileComplete: false,
          recommendations: [],
        );
      }

      final rawList = data['recommendations'] as List? ?? [];
      return DietRecommendationResult(
        profileComplete: true,
        dietLabel: data['dietLabel'] as String?,
        dietIcon: data['dietIcon'] as String?,
        recommendations:
            rawList.map((r) => RecipeModel.fromJson(r as Map<String, dynamic>)).toList(),
      );
    } else {
      throw Exception('Error ${response.statusCode} al obtener recomendaciones');
    }
  }
}
