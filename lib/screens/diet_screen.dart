import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/diet_service.dart';
import '../services/diet_recommendation_service.dart';
import '../theme/eva_colors.dart';
import 'diet_plans_screen.dart';
import 'profile_setup_screen.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen>
    with SingleTickerProviderStateMixin {
  late TabController _categoryController;
  final DietService _dietService = DietService();

  // Keys and emojis stay fixed; labels are computed from AppStrings in build
  static const List<Map<String, String>> _categoryDefs = [
    {'key': 'todos',    'emoji': '🍽️'},
    {'key': 'desayuno', 'emoji': '🌅'},
    {'key': 'almuerzo', 'emoji': '🥗'},
    {'key': 'cena',     'emoji': '🌙'},
    {'key': 'merienda', 'emoji': '🍎'},
    {'key': 'snack',    'emoji': '🥜'},
    {'key': 'batido',   'emoji': '🥤'},
    {'key': 'bebida',   'emoji': '🍹'},
  ];

  List<RecipeModel> _recipes = [];
  List<RecipeModel> _lockedRecipes = [];
  String _userPlan = 'free';
  bool _isLoading = true;
  String? _error;
  int _selectedCategory = 0;

  // ── Recomendaciones personalizadas ────────────────────────────────────────
  DietRecommendationResult? _recommendation;
  bool _recLoading = true;

  @override
  void initState() {
    super.initState();
    _categoryController = TabController(length: _categoryDefs.length, vsync: this);
    _categoryController.addListener(() {
      if (!_categoryController.indexIsChanging) {
        setState(() => _selectedCategory = _categoryController.index);
        _loadRecipes();
      }
    });
    _loadRecipes();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    if (!mounted) return;
    setState(() => _recLoading = true);
    try {
      final result = await DietRecommendationService.getPersonalized();
      if (!mounted) return;
      setState(() {
        _recommendation = result;
        _recLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _recLoading = false);
    }
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cat = _categoryDefs[_selectedCategory]['key'];
      final lang = Localizations.localeOf(context).languageCode;
      final result = await _dietService.getRecipes(
        category: cat == 'todos' ? null : cat,
        lang: lang,
      );
      if (!mounted) return;
      setState(() {
        _recipes = result['recipes'] as List<RecipeModel>;
        _lockedRecipes = result['lockedRecipes'] as List<RecipeModel>;
        _userPlan = result['userPlan'] as String;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppStrings.of(context).dietErrorMsg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildPersonalizedSection(),
          _buildCategoryTabs(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // ── Sección "Para Ti" ─────────────────────────────────────────────────────

  Widget _buildPersonalizedSection() {
    // Cargando
    if (_recLoading) {
      return Container(
        color: Colors.grey[50],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: EvaColors.vibrantPink),
          ),
        ),
      );
    }

    final rec = _recommendation;

    // Sin perfil configurado → botón de invitación
    if (rec == null || !rec.profileComplete) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        ).then((_) => _loadRecommendations()),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                EvaColors.vibrantPink.withOpacity(0.12),
                EvaColors.wellnessPurple.withOpacity(0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: EvaColors.vibrantPink.withOpacity(0.35), width: 1),
          ),
          child: Row(
            children: [
              const Text('🥗', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.of(context).recipesForYou,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: EvaColors.vibrantPink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.of(context).configProfileForDiet,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: EvaColors.vibrantPink),
            ],
          ),
        ),
      );
    }

    // Con perfil → carrusel horizontal de recetas recomendadas
    if (rec.recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Text(
                  rec.dietIcon ?? '🥗',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  rec.dietLabel ?? 'Para Ti',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: EvaColors.vibrantPink,
                  ),
                ),
                const Spacer(),
                Text(
                  AppStrings.of(context).justForYou,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: rec.recommendations.length,
              itemBuilder: (context, i) =>
                  _buildRecommendedCard(rec.recommendations[i]),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () => recipe.isLocked
          ? _showLockedDialog(recipe.accessLevel)
          : _showRecipeDetail(recipe),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: SizedBox(
                    height: 80,
                    width: double.infinity,
                    child: _buildRecipeImage(recipe),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 10, color: EvaColors.motivationOrange),
                          const SizedBox(width: 2),
                          Text(
                            '${recipe.calories} kcal',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (recipe.isLocked)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: Icon(Icons.lock, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: EvaColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                AppStrings.of(context).dietTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_userPlan == 'free')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: EvaColors.vitalityYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Free',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (_userPlan == 'premium')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: EvaColors.motivationOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '★ Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.of(context).dietSubtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _categoryController,
        isScrollable: true,
        indicatorColor: EvaColors.vibrantPink,
        labelColor: EvaColors.vibrantPink,
        unselectedLabelColor: Colors.grey[600],
        labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: _categoryDefs
            .map((c) => Tab(text: '${c['emoji']} ${AppStrings.of(context).dietCategory(c['key']!)}'))
            .toList(),
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 12, width: 100, color: Colors.grey[300]),
                  const SizedBox(height: 6),
                  Container(
                      height: 10, width: 60, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildSkeletonGrid();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: EvaColors.vibrantPink),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(AppStrings.of(context).retry,
                  style: const TextStyle(color: Colors.white)),
              onPressed: _loadRecipes,
            ),
          ],
        ),
      );
    }

    final all = [..._recipes, ..._lockedRecipes];

    if (all.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_meals, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            Text(AppStrings.of(context).noRecipesInCategory,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: EvaColors.vibrantPink,
      onRefresh: _loadRecipes,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildPlanBanner()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildRecipeCard(all[index]),
                childCount: all.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DietPlansScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              EvaColors.wellnessPurple.withOpacity(0.85),
              EvaColors.vibrantPink.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: EvaColors.vibrantPink.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('📅', style: TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.of(context).weeklyPlanBanner,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppStrings.of(context).weeklyPlanSub,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(AppStrings.of(context).seeArrow, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () {
        if (recipe.isLocked) {
          _showLockedDialog(recipe.accessLevel);
        } else {
          _showRecipeDetail(recipe);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: _buildRecipeImage(recipe),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department,
                                size: 13, color: EvaColors.motivationOrange),
                            const SizedBox(width: 2),
                            Text(
                              '${recipe.calories} kcal',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.timer,
                                size: 13, color: EvaColors.vibrantPink),
                            const SizedBox(width: 2),
                            Text(
                              '${recipe.totalTime} min',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Overlay de lock para recetas bloqueadas
            if (recipe.isLocked)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.black.withOpacity(0.45),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock,
                              color: Colors.white, size: 32),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: recipe.accessLevel == 'premium'
                                  ? EvaColors.motivationOrange
                                  : EvaColors.strongBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              recipe.accessLevel == 'premium'
                                  ? 'Premium'
                                  : 'Basic',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Badge featured
            if (recipe.isFeatured && !recipe.isLocked)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: EvaColors.vibrantPink,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppStrings.of(context).featured,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(RecipeModel recipe) {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
                strokeWidth: 2, color: EvaColors.vibrantPink),
          ),
        ),
        errorWidget: (context, url, error) =>
            _buildImagePlaceholder(recipe.category),
      );
    }
    return _buildImagePlaceholder(recipe.category);
  }

  Widget _buildImagePlaceholder(String category) {
    final Map<String, Map<String, dynamic>> categoryConfig = {
      'desayuno': {'icon': Icons.wb_sunny, 'color': EvaColors.vitalityYellow},
      'almuerzo': {'icon': Icons.lunch_dining, 'color': EvaColors.activeGreen},
      'cena': {'icon': Icons.nights_stay, 'color': EvaColors.wellnessPurple},
      'merienda': {'icon': Icons.apple, 'color': EvaColors.motivationOrange},
      'snack': {'icon': Icons.cookie, 'color': EvaColors.cosmicRed},
      'batido': {'icon': Icons.blender, 'color': EvaColors.strongBlue},
      'bebida': {'icon': Icons.local_drink, 'color': EvaColors.activeGreen},
    };
    final config = categoryConfig[category] ??
        {'icon': Icons.restaurant, 'color': EvaColors.vibrantPink};

    return Container(
      color: (config['color'] as Color).withOpacity(0.15),
      child: Center(
        child: Icon(config['icon'] as IconData,
            size: 40, color: config['color'] as Color),
      ),
    );
  }

  void _showLockedDialog(String accessLevel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: EvaColors.vibrantPink),
            const SizedBox(width: 8),
            Text(AppStrings.of(context).lockedRecipe),
          ],
        ),
        content: Text(
          accessLevel == 'premium'
              ? AppStrings.of(context).lockedPremiumMsg
              : AppStrings.of(context).lockedBasicMsg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.of(context).close),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: EvaColors.vibrantPink),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppStrings.of(context).viewPlans,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetail(RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipeDetailSheet(recipe: recipe),
    );
  }
}

// ========== DETAIL BOTTOM SHEET ==========

class _RecipeDetailSheet extends StatelessWidget {
  final RecipeModel recipe;

  const _RecipeDetailSheet({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // Imagen header
              SliverToBoxAdapter(child: _buildDetailImage(context)),

              // Contenido
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Nombre y categoría
                    _buildDetailHeader(context),
                    const SizedBox(height: 16),

                    // Tiempos
                    _buildTimesRow(context),
                    const SizedBox(height: 16),

                    // Info nutricional
                    _buildNutritionRow(context),
                    const SizedBox(height: 20),

                    // Descripción
                    if (recipe.description != null &&
                        recipe.description!.isNotEmpty) ...[
                      _buildSectionTitle(AppStrings.of(context).description),
                      const SizedBox(height: 8),
                      Text(recipe.description!,
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 14)),
                      const SizedBox(height: 20),
                    ],

                    // Ingredientes
                    if (recipe.ingredients.isNotEmpty) ...[
                      _buildSectionTitle(AppStrings.of(context).ingredients),
                      const SizedBox(height: 8),
                      ...recipe.ingredients.map((ing) => _buildIngredientRow(ing)),
                      const SizedBox(height: 20),
                    ],

                    // Pasos
                    if (recipe.steps.isNotEmpty) ...[
                      _buildSectionTitle(AppStrings.of(context).preparation),
                      const SizedBox(height: 8),
                      ...recipe.steps.asMap().entries.map(
                            (entry) => _buildStepRow(entry.key + 1, entry.value),
                          ),
                    ],

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: recipe.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (c, u, e) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: EvaColors.vibrantPink.withOpacity(0.15),
      child: const Center(
        child: Icon(Icons.restaurant_menu,
            size: 60, color: EvaColors.vibrantPink),
      ),
    );
  }

  Widget _buildDetailHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                recipe.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: EvaColors.vibrantPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: EvaColors.vibrantPink.withOpacity(0.4)),
              ),
              child: Text(
                _categoryLabel(recipe.category, context),
                style: const TextStyle(
                    color: EvaColors.vibrantPink,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        if (recipe.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: recipe.tags
                .map((tag) => Chip(
                      label: Text(tag,
                          style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.grey[100],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTimesRow(BuildContext context) {
    return Row(
      children: [
        _buildTimeChip(Icons.content_cut, AppStrings.of(context).prepTime, recipe.prepTime),
        const SizedBox(width: 12),
        _buildTimeChip(Icons.local_fire_department, AppStrings.of(context).cookTime, recipe.cookTime),
        const SizedBox(width: 12),
        _buildTimeChip(Icons.timer, AppStrings.of(context).totalTime, recipe.totalTime),
      ],
    );
  }

  Widget _buildTimeChip(IconData icon, String label, int minutes) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: EvaColors.vibrantPink.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: EvaColors.vibrantPink, size: 20),
            const SizedBox(height: 4),
            Text('$minutes min',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EvaColors.activeGreen.withOpacity(0.1),
            EvaColors.activeGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EvaColors.activeGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutritionItem('${recipe.calories}', s.calories, '🔥'),
          _buildNutritionItem('${recipe.protein.toStringAsFixed(0)}g', s.protein, '💪'),
          _buildNutritionItem('${recipe.carbs.toStringAsFixed(0)}g', s.carbs, '🌾'),
          _buildNutritionItem('${recipe.fat.toStringAsFixed(0)}g', s.fat, '🥑'),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: EvaColors.vibrantPink),
    );
  }

  Widget _buildIngredientRow(Map<String, dynamic> ingredient) {
    final amount = ingredient['amount'] ?? '';
    final unit = ingredient['unit'] ?? '';
    final name = ingredient['name'] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: EvaColors.vibrantPink,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text('$amount $unit'.trim(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(name,
                style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int number, String step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: EvaColors.vibrantPink,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(step,
                  style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String cat, BuildContext context) {
    const emojis = {
      'desayuno': '🌅',
      'almuerzo': '🥗',
      'cena': '🌙',
      'merienda': '🍎',
      'snack': '🥜',
      'batido': '🥤',
      'bebida': '🍹',
    };
    final emoji = emojis[cat] ?? '';
    return '$emoji ${AppStrings.of(context).dietCategoryLabel(cat)}';
  }
}
