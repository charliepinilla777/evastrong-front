import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'cache_service.dart';
import 'diet_service.dart';

class PlanMeal {
  final String mealType;
  final String label;
  final RecipeModel recipe;
  final bool optional;
  final String? note;
  final bool isLocked;

  PlanMeal({
    required this.mealType,
    required this.label,
    required this.recipe,
    required this.optional,
    this.note,
    required this.isLocked,
  });

  factory PlanMeal.fromJson(Map<String, dynamic> json) {
    final recipeJson = json['recipe'] as Map<String, dynamic>? ?? {};
    final isLocked = json['isLocked'] as bool? ?? false;
    return PlanMeal(
      mealType: json['mealType'] ?? '',
      label: json['label'] ?? '',
      recipe: RecipeModel.fromJson(recipeJson, isLocked: isLocked),
      optional: json['optional'] ?? false,
      note: json['note'],
      isLocked: isLocked,
    );
  }
}

class PlanModel {
  final String id;
  final String name;
  final int dayNumber;
  final String theme;
  final String? description;
  final String accessLevel;
  final List<PlanMeal> meals;
  final int caloriesMin;
  final int caloriesMax;
  final String userPlan;

  PlanModel({
    required this.id,
    required this.name,
    required this.dayNumber,
    required this.theme,
    this.description,
    required this.accessLevel,
    required this.meals,
    required this.caloriesMin,
    required this.caloriesMax,
    required this.userPlan,
  });

  int get totalCalories {
    return meals
        .where((m) => !m.optional)
        .fold(0, (sum, m) => sum + m.recipe.calories);
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final mealsJson = json['meals'] as List? ?? [];
    final nutrition = json['nutrition'] as Map<String, dynamic>? ?? {};
    return PlanModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      dayNumber: (json['dayNumber'] ?? 1).toInt(),
      theme: json['theme'] ?? '',
      description: json['description'],
      accessLevel: json['accessLevel'] ?? 'free',
      meals: mealsJson
          .where((m) => m['recipe'] != null)
          .map((m) => PlanMeal.fromJson(m))
          .toList(),
      caloriesMin: (nutrition['caloriesMin'] ?? 0).toInt(),
      caloriesMax: (nutrition['caloriesMax'] ?? 0).toInt(),
      userPlan: json['userPlan'] ?? 'free',
    );
  }
}

class PlanService {
  String? jwtToken;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (jwtToken != null) {
      headers['Authorization'] = 'Bearer $jwtToken';
    }
    return headers;
  }

  Future<List<PlanModel>> getPlans({String lang = 'es'}) async {
    final cacheKey = 'diet_plans_$lang';

    final cached = await CacheService.get(cacheKey);
    if (cached != null) {
      if (cached.isStale) {
        _fetchAndCachePlans(cacheKey, lang: lang);
      }
      final list = (cached.data as List? ?? []);
      return list
          .map((p) => PlanModel.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
    }

    return _fetchAndCachePlans(cacheKey, lang: lang);
  }

  Future<List<PlanModel>> _fetchAndCachePlans(String cacheKey, {String lang = 'es'}) async {
    final url = '${AppConfig.plansUrl}?lang=$lang';
    final response = await http
        .get(Uri.parse(url), headers: _headers)
        .timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data'] as List? ?? [];
      await CacheService.set(cacheKey, list);
      return list.map((p) => PlanModel.fromJson(p)).toList();
    }
    throw Exception('Error al cargar planes');
  }

  Future<PlanModel> getPlanById(String id) async {
    final response = await http
        .get(Uri.parse('${AppConfig.plansUrl}/$id'), headers: _headers)
        .timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PlanModel.fromJson(data['data']);
    }
    throw Exception('Plan no encontrado');
  }
}
