import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'cache_service.dart';

/// Client-side Spanish→English name fallback for recipes whose DB record
/// has not yet been migrated with nameEn.
/// The backend already handles the swap server-side when nameEn is populated.
const Map<String, String> _recipeNameEn = {
  // seedRecipes.js
  'Avena proteica para glúteos':                         'High-Protein Glute Oatmeal',
  'Overnight oats banana y yogur':                       'Banana & Yogurt Overnight Oats',
  'Snack piel radiante (yogur, frutos rojos y cacao)':   'Radiant Skin Snack (Yogurt, Berries & Cacao)',
  'Batido antiinflamatorio piel radiante':               'Anti-Inflammatory Radiant Skin Smoothie',
  'Shot antiinflamatorio para ojeras y piel':            'Anti-Inflammatory Shot for Dark Circles & Skin',
  'Bowl de huevo, aguacate y espinaca':                  'Egg, Avocado & Spinach Bowl',
  'Sándwich de pollo antiinflamatorio':                  'Anti-Inflammatory Chicken Sandwich',
  'Tofu o pollo salteado alto en proteína':              'High-Protein Sautéed Tofu or Chicken',
  'Yogur griego con mantequilla de maní y frutos rojos': 'Greek Yogurt with Peanut Butter & Berries',
  'Tortilla proteica de huevo y espinaca':               'Protein Egg & Spinach Omelette',
  'Overnight oats para glúteos':                         'Glute-Building Overnight Oats',
  'Bowl de pollo, camote y brócoli':                     'Chicken, Sweet Potato & Broccoli Bowl',
  'Ensalada de lentejas para pierna fuerte':             'Lentil Salad for Strong Legs',
  'Ensalada power de salmón y quinoa':                   'Power Salmon & Quinoa Salad',
  'Bowl de garbanzos y verduras para piel y músculo':    'Chickpea & Veggie Bowl for Skin & Muscle',
  'Cena ligera de clara de huevo y verduras':            'Light Egg White & Veggie Dinner',
  'Pasta integral con carne magra':                      'Whole Grain Pasta with Lean Meat',
  'Banana con mantequilla de maní (pre entreno)':        'Banana with Peanut Butter (Pre-Workout)',
  'Yogur griego con fruta (pre entreno)':                'Greek Yogurt with Fruit (Pre-Workout)',
  'Tostada integral con huevo (pre entreno)':            'Whole Grain Toast with Egg (Pre-Workout)',
  'Arroz con atún rápido (post entreno)':                'Quick Rice with Tuna (Post-Workout)',
  'Wrap de pollo y aguacate (post entreno)':             'Chicken & Avocado Wrap (Post-Workout)',
  'Shake de proteína con avena (post entreno)':          'Protein Shake with Oats (Post-Workout)',
  'Omelette ligero de claras y vegetales':               'Light Egg White & Veggie Omelette',
  'Avena fit alta en proteína':                          'High-Protein Fit Oatmeal',
  'Ensalada ligera de pollo':                            'Light Chicken Salad',
  'Bowl vegetariano de judías pintas y arroz':           'Vegetarian Pinto Bean & Rice Bowl',
  'Tacos de lechuga con pavo':                           'Turkey Lettuce Tacos',
  'Ensalada de garbanzos rápida':                        'Quick Chickpea Salad',
  'Snack de zanahoria y hummus':                         'Carrot & Hummus Snack',
  'Yogur griego con semillas':                           'Greek Yogurt with Seeds',
  'Batido verde quema grasa':                            'Fat-Burning Green Smoothie',
  'Cena de salmón y quinoa para glúteos':                'Salmon & Quinoa Dinner for Glutes',
  // seedRecipesV2.js
  'Tostadas de aguacate y huevo':                        'Avocado & Egg Toast',
  'Huevos revueltos a la mexicana fit':                  'Fit Mexican Scrambled Eggs',
  'Quesadilla desayuno alta en proteína':                'High-Protein Breakfast Quesadilla',
  'Bowl de frutas cítricas y yogur':                     'Citrus Fruit & Yogurt Bowl',
  'Avena con cacao y frutos rojos':                      'Oatmeal with Cacao & Berries',
  'Ensalada de garbanzos mediterránea':                  'Mediterranean Chickpea Salad',
  'Ensalada de atún estilo español':                     'Spanish-Style Tuna Salad',
  'Bowl burrito ligero de pollo':                        'Light Chicken Burrito Bowl',
  'Pollo guisado fit con verduras':                      'Fit Chicken Stew with Veggies',
  'Cocido madrileño ligero alto en proteína':            'Light High-Protein Madrid Stew',
  'Tacos de pescado al horno':                           'Baked Fish Tacos',
  'Sopa de lentejas reconfortante':                      'Comforting Lentil Soup',
  'Crema de tomate y albahaca ligera':                   'Light Tomato & Basil Cream Soup',
  'Ensalada templada de quinoa y espinaca':              'Warm Quinoa & Spinach Salad',
  'Revuelto de claras con pavo':                         'Egg White Scramble with Turkey',
  'Caldo de pollo casero antiinflamatorio':              'Homemade Anti-Inflammatory Chicken Broth',
  'Pepino con limón y chile':                            'Cucumber with Lemon & Chili',
  'Palitos de verduras con hummus':                      'Veggie Sticks with Hummus',
  'Manzana con mantequilla de maní':                     'Apple with Peanut Butter',
  'Yogur con cacao y nueces':                            'Yogurt with Cacao & Walnuts',
  'Batido verde detox suave':                            'Gentle Detox Green Smoothie',
  'Batido de frutos rojos antioxidante':                 'Antioxidant Berry Smoothie',
  'Agua saborizada con frutas y menta':                  'Fruit & Mint Infused Water',
  'Café proteico sin azúcar':                            'Sugar-Free Protein Coffee',
  // seedRecipesV3.js
  'Pollo al horno con verduras arcoíris':                'Rainbow Roasted Chicken & Veggies',
  'Filete de pescado con ensalada de col':               'Fish Fillet with Coleslaw',
  'Pasta integral con atún y tomate':                    'Whole Grain Pasta with Tuna & Tomato',
  'Salteado de ternera magra con brócoli':               'Lean Beef & Broccoli Stir-Fry',
  'Ensalada de pollo, frijoles negros y aguacate':       'Chicken, Black Bean & Avocado Salad',
  'Ensalada de garbanzos con atún':                      'Chickpea & Tuna Salad',
  'Zoodles de calabacín con pollo':                      'Zucchini Zoodles with Chicken',
  'Ensalada de lentejas con pollo y manzana':            'Lentil Salad with Chicken & Apple',
  'Caldo de albóndigas ligero':                          'Light Meatball Broth',
  'Bowl veggie de tofu y quinoa':                        'Veggie Tofu & Quinoa Bowl',
  'Arepa integral con huevo y aguacate':                 'Whole Grain Arepa with Egg & Avocado',
  'Overnight oats de mango y chía':                      'Mango & Chia Overnight Oats',
  'Tostadas con ricotta y frutos rojos':                 'Toast with Ricotta & Berries',
  'Rollitos de jamón de pavo y queso':                   'Turkey Ham & Cheese Roll-Ups',
  'Mini bowl de fruta y yogur':                          'Mini Fruit & Yogurt Bowl',
  'Ensalada caprese ligera':                             'Light Caprese Salad',
  'Garbanzos tostados especiados':                       'Spiced Roasted Chickpeas',
  'Barritas caseras de avena y frutos secos':            'Homemade Oat & Nut Bars',
  'Latte dorado (golden milk)':                          'Golden Milk Latte',
  'Té frío de frutos rojos':                             'Iced Berry Tea',
  'Batido proteico de café frío':                        'Cold Brew Protein Smoothie',
  'Tortilla francesa de espinaca y queso light':         'Spinach & Light Cheese French Omelette',
  'Pechuga a la plancha con puré de coliflor':           'Grilled Chicken Breast with Cauliflower Mash',
};

class RecipeModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String category;
  final String accessLevel;
  final List<Map<String, dynamic>> ingredients;
  final List<String> steps;
  final Map<String, dynamic> nutrition;
  final int prepTime;
  final int cookTime;
  final List<String> tags;
  final bool isFeatured;
  final bool isLocked;

  RecipeModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.category,
    required this.accessLevel,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    required this.prepTime,
    required this.cookTime,
    required this.tags,
    this.isFeatured = false,
    this.isLocked = false,
  });

  int get totalTime => prepTime + cookTime;
  int get calories => (nutrition['calories'] ?? 0).toInt();
  double get protein => (nutrition['protein'] ?? 0).toDouble();
  double get carbs => (nutrition['carbs'] ?? 0).toDouble();
  double get fat => (nutrition['fat'] ?? 0).toDouble();

  factory RecipeModel.fromJson(Map<String, dynamic> json,
      {bool isLocked = false, String lang = 'es'}) {
    // Client-side name fallback when backend DB has no nameEn yet.
    // The backend already swaps json['name'] for nameEn when lang=en and nameEn
    // is populated, so this map is only used as a safety net.
    final rawName = (json['name'] as String?) ?? '';
    final name = (lang == 'en' && _recipeNameEn.containsKey(rawName))
        ? _recipeNameEn[rawName]!
        : rawName;

    return RecipeModel(
      id: json['_id']?.toString() ?? '',
      name: name,
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'] ?? 'desayuno',
      accessLevel: json['accessLevel'] ?? 'free',
      ingredients: isLocked
          ? []
          : List<Map<String, dynamic>>.from(json['ingredients'] ?? []),
      steps: isLocked
          ? []
          : List<String>.from(json['steps'] ?? []),
      nutrition: Map<String, dynamic>.from(json['nutrition'] ?? {}),
      prepTime: (json['prepTime'] ?? 0).toInt(),
      cookTime: (json['cookTime'] ?? 0).toInt(),
      tags: List<String>.from(json['tags'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
      isLocked: isLocked,
    );
  }
}

class DietService {
  String? jwtToken;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (jwtToken != null) {
      headers['Authorization'] = 'Bearer $jwtToken';
    }
    return headers;
  }

  /// Obtiene todas las recetas (accesibles + bloqueadas).
  /// Stale-while-revalidate: devuelve caché inmediatamente y refresca en bg.
  Future<Map<String, dynamic>> getRecipes({String? category, String lang = 'es'}) async {
    final cacheKey = 'recipes_${category ?? 'todos'}_$lang';

    final cached = await CacheService.get(cacheKey);
    if (cached != null) {
      if (cached.isStale) {
        _fetchAndCacheRecipes(cacheKey: cacheKey, category: category, lang: lang);
      }
      return _deserializeRecipes(cached.data as Map<String, dynamic>, lang: lang);
    }

    return _fetchAndCacheRecipes(cacheKey: cacheKey, category: category, lang: lang);
  }

  Future<Map<String, dynamic>> _fetchAndCacheRecipes({
    required String cacheKey,
    String? category,
    String lang = 'es',
  }) async {
    try {
      final params = <String, String>{'lang': lang};
      if (category != null && category != 'todos') params['category'] = category;
      String url = Uri.parse(AppConfig.recipesUrl).replace(queryParameters: params).toString();

      final response = await http
          .get(Uri.parse(url), headers: _headers)
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Guardamos el JSON crudo para poder deserializarlo después
        final rawPayload = data['data'] as Map<String, dynamic>? ?? {};
        await CacheService.set(cacheKey, rawPayload);
        return _deserializeRecipes(rawPayload, lang: lang);
      } else {
        throw Exception('Error al cargar recetas');
      }
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _deserializeRecipes(Map<String, dynamic> raw,
      {String lang = 'es'}) {
    final rawRecipes = raw['recipes'] as List? ?? [];
    final rawLocked = raw['lockedRecipes'] as List? ?? [];
    final userPlan = raw['userPlan'] ?? 'free';

    return {
      'recipes': rawRecipes
          .map((r) => RecipeModel.fromJson(
              Map<String, dynamic>.from(r as Map),
              isLocked: false,
              lang: lang))
          .toList(),
      'lockedRecipes': rawLocked
          .map((r) => RecipeModel.fromJson(
              Map<String, dynamic>.from(r as Map),
              isLocked: true,
              lang: lang))
          .toList(),
      'userPlan': userPlan,
    };
  }

  /// Obtiene el detalle de una receta por ID
  Future<RecipeModel> getRecipeById(String id, {String lang = 'es'}) async {
    try {
      final url = Uri.parse('${AppConfig.recipesUrl}/$id').replace(queryParameters: {'lang': lang});
      final response = await http
          .get(url, headers: _headers)
          .timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecipeModel.fromJson(data['data']);
      } else if (response.statusCode == 403) {
        throw Exception('Necesitas una suscripción para ver esta receta');
      } else {
        throw Exception('Receta no encontrada');
      }
    } catch (e) {
      rethrow;
    }
  }
}
