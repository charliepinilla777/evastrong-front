import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo degradado oscuro premium
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6A0050),
                  Color(0xFF3D0030),
                  Color(0xFF1A0030),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Contenido encima
          Column(
            children: [
              _buildHeader(),
              _buildPersonalizedSection(),
              _buildCategoryTabs(),
              Expanded(child: _buildContent()),
            ],
          ),
        ],
      ),
    );
  }

  // ── Header premium ─────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final isPremium = _userPlan == 'premium';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EvaColors.magentaDark,
            EvaColors.cosmicRed,
            EvaColors.mediumPink,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: EvaColors.cosmicRed.withOpacity(0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.of(context).dietTitle,
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              if (!isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: EvaColors.vitalityYellow.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: EvaColors.vitalityYellow.withOpacity(0.60),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Free',
                    style: GoogleFonts.raleway(
                      color: EvaColors.vitalityYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [EvaColors.vitalityYellow, EvaColors.motivationOrange],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: EvaColors.vitalityYellow,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: EvaColors.vitalityYellow.withOpacity(0.40),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '★ Premium',
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.of(context).dietSubtitle,
            style: GoogleFonts.raleway(
              color: Colors.white.withOpacity(0.80),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección "Para Ti" ─────────────────────────────────────────────────────

  Widget _buildPersonalizedSection() {
    // Cargando
    if (_recLoading) {
      return Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: EvaColors.vibrantPink,
            ),
          ),
        ),
      );
    }

    final rec = _recommendation;

    // Sin perfil configurado → botón de invitación glassmorphism
    if (rec == null || !rec.profileComplete) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
        ).then((_) => _loadRecommendations()),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EvaColors.cosmicRed.withOpacity(0.30),
                      EvaColors.wellnessPurple.withOpacity(0.30),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
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
                            style: GoogleFonts.raleway(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.of(context).configProfileForDiet,
                            style: GoogleFonts.raleway(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: EvaColors.vitalityYellow,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Con perfil → carrusel horizontal de recetas recomendadas
    if (rec.recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.transparent,
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
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  AppStrings.of(context).justForYou,
                  style: GoogleFonts.raleway(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.55),
                  ),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.20),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
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
                              style: GoogleFonts.raleway(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 10,
                                  color: EvaColors.motivationOrange,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${recipe.calories} kcal',
                                  style: GoogleFonts.raleway(
                                    fontSize: 10,
                                    color: EvaColors.motivationOrange,
                                  ),
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
                          color: Colors.black.withOpacity(0.50),
                          child: const Center(
                            child: Icon(Icons.lock, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Category Tabs ──────────────────────────────────────────────────────────

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.transparent,
      child: TabBar(
        controller: _categoryController,
        isScrollable: true,
        indicatorColor: EvaColors.vitalityYellow,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: GoogleFonts.raleway(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: GoogleFonts.raleway(
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        tabs: _categoryDefs
            .map((c) => Tab(
                  text:
                      '${c['emoji']} ${AppStrings.of(context).dietCategory(c['key']!)}',
                ))
            .toList(),
      ),
    );
  }

  // ── Skeleton Loader ────────────────────────────────────────────────────────

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
      itemBuilder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Content Area ───────────────────────────────────────────────────────────

  Widget _buildContent() {
    if (_isLoading) {
      return _buildSkeletonGrid();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white.withOpacity(0.70),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.70),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: EvaColors.cosmicRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                AppStrings.of(context).retry,
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w600,
                  color: EvaColors.cosmicRed,
                ),
              ),
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
            Icon(
              Icons.no_meals,
              color: Colors.white.withOpacity(0.70),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.of(context).noRecipesInCategory,
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.70),
              ),
            ),
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

  // ── Plan Banner ────────────────────────────────────────────────────────────

  Widget _buildPlanBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DietPlansScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    EvaColors.magentaDark,
                    EvaColors.cosmicRed,
                    EvaColors.wellnessPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: EvaColors.vitalityYellow.withOpacity(0.55),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: EvaColors.cosmicRed.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: EvaColors.vitalityYellow.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: EvaColors.vitalityYellow.withOpacity(0.70),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'PLAN SEMANAL',
                          style: GoogleFonts.raleway(
                            color: EvaColors.vitalityYellow,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('📅', style: TextStyle(fontSize: 26)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.of(context).weeklyPlanBanner,
                          style: GoogleFonts.cormorantGaramond(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          AppStrings.of(context).weeklyPlanSub,
                          style: GoogleFonts.raleway(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppStrings.of(context).seeArrow,
                      style: GoogleFonts.raleway(
                        color: EvaColors.cosmicRed,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Recipe Card ────────────────────────────────────────────────────────────

  Widget _buildRecipeCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () {
        if (recipe.isLocked) {
          _showLockedDialog(recipe.accessLevel);
        } else {
          _showRecipeDetail(recipe);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
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
                              style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 13,
                                  color: EvaColors.motivationOrange,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${recipe.calories} kcal',
                                  style: GoogleFonts.raleway(
                                    fontSize: 11,
                                    color: EvaColors.motivationOrange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 13,
                                  color: EvaColors.vibrantPink,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${recipe.totalTime} min',
                                  style: GoogleFonts.raleway(
                                    fontSize: 11,
                                    color: EvaColors.vibrantPink,
                                  ),
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
                        color: Colors.black.withOpacity(0.50),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: recipe.accessLevel == 'premium'
                                        ? [
                                            EvaColors.vitalityYellow,
                                            EvaColors.motivationOrange,
                                          ]
                                        : [
                                            EvaColors.strongBlue,
                                            EvaColors.darkBlue,
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  recipe.accessLevel == 'premium'
                                      ? 'Premium'
                                      : 'Basic',
                                  style: GoogleFonts.raleway(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
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
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: EvaColors.vitalityYellow,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: EvaColors.vitalityYellow.withOpacity(0.50),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        AppStrings.of(context).featured,
                        style: GoogleFonts.raleway(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Recipe Image ───────────────────────────────────────────────────────────

  Widget _buildRecipeImage(RecipeModel recipe) {
    if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: recipe.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                EvaColors.magentaDark.withOpacity(0.80),
                EvaColors.wellnessPurple.withOpacity(0.60),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: EvaColors.vibrantPink,
            ),
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
      'desayuno': {'icon': Icons.wb_sunny,      'color': EvaColors.vitalityYellow},
      'almuerzo': {'icon': Icons.lunch_dining,   'color': EvaColors.activeGreen},
      'cena':     {'icon': Icons.nights_stay,    'color': EvaColors.wellnessPurple},
      'merienda': {'icon': Icons.apple,          'color': EvaColors.motivationOrange},
      'snack':    {'icon': Icons.cookie,         'color': EvaColors.cosmicRed},
      'batido':   {'icon': Icons.blender,        'color': EvaColors.strongBlue},
      'bebida':   {'icon': Icons.local_drink,    'color': EvaColors.activeGreen},
    };
    final config = categoryConfig[category] ??
        {'icon': Icons.restaurant, 'color': EvaColors.vibrantPink};
    final color = config['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.30),
            const Color(0xFF6A0050),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          config['icon'] as IconData,
          size: 40,
          color: color.withOpacity(0.90),
        ),
      ),
    );
  }

  // ── Locked Dialog ──────────────────────────────────────────────────────────

  void _showLockedDialog(String accessLevel) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A0030),
                  Color(0xFF3D0030),
                  EvaColors.magentaDark,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: EvaColors.vitalityYellow.withOpacity(0.60),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: EvaColors.cosmicRed.withOpacity(0.50),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Corona premium
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EvaColors.vitalityYellow.withOpacity(0.18),
                    border: Border.all(
                      color: EvaColors.vitalityYellow.withOpacity(0.50),
                      width: 1.5,
                    ),
                  ),
                  child: const Text(
                    '👑',
                    style: TextStyle(fontSize: 36),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.of(context).lockedRecipe,
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  accessLevel == 'premium'
                      ? AppStrings.of(context).lockedPremiumMsg
                      : AppStrings.of(context).lockedBasicMsg,
                  style: GoogleFonts.raleway(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppStrings.of(context).close,
                          style: GoogleFonts.raleway(
                            color: Colors.white.withOpacity(0.70),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: EvaColors.cosmicRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppStrings.of(context).viewPlans,
                          style: GoogleFonts.raleway(
                            color: EvaColors.cosmicRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Recipe Detail ──────────────────────────────────────────────────────────

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
          decoration: BoxDecoration(
            color: const Color(0xFF1A0030),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: EvaColors.vitalityYellow.withOpacity(0.60),
                width: 1.5,
              ),
            ),
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
                    // Handle bar + nombre y categoría
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
                      Text(
                        recipe.description!,
                        style: GoogleFonts.raleway(
                          color: Colors.white.withOpacity(0.80),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Ingredientes
                    if (recipe.ingredients.isNotEmpty) ...[
                      _buildSectionTitle(AppStrings.of(context).ingredients),
                      const SizedBox(height: 8),
                      ...recipe.ingredients
                          .map((ing) => _buildIngredientRow(ing)),
                      const SizedBox(height: 20),
                    ],

                    // Pasos
                    if (recipe.steps.isNotEmpty) ...[
                      _buildSectionTitle(AppStrings.of(context).preparation),
                      const SizedBox(height: 8),
                      ...recipe.steps.asMap().entries.map(
                            (entry) =>
                                _buildStepRow(entry.key + 1, entry.value),
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
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.black.withOpacity(0.50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.30),
                  width: 1,
                ),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EvaColors.magentaDark,
            Color(0xFF3D0030),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 60,
          color: EvaColors.vibrantPink,
        ),
      ),
    );
  }

  Widget _buildDetailHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar dorado
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: EvaColors.vitalityYellow.withOpacity(0.70),
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
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Badge categoría glassmorphism
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.30),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _categoryLabel(recipe.category, context),
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (recipe.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: recipe.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.20),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.raleway(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.80),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTimesRow(BuildContext context) {
    return Row(
      children: [
        _buildTimeChip(
          Icons.content_cut,
          AppStrings.of(context).prepTime,
          recipe.prepTime,
        ),
        const SizedBox(width: 12),
        _buildTimeChip(
          Icons.local_fire_department,
          AppStrings.of(context).cookTime,
          recipe.cookTime,
        ),
        const SizedBox(width: 12),
        _buildTimeChip(
          Icons.timer,
          AppStrings.of(context).totalTime,
          recipe.totalTime,
        ),
      ],
    );
  }

  Widget _buildTimeChip(IconData icon, String label, int minutes) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: EvaColors.vibrantPink, size: 20),
                const SizedBox(height: 4),
                Text(
                  '$minutes min',
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.raleway(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(BuildContext context) {
    final s = AppStrings.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                EvaColors.activeGreen.withOpacity(0.18),
                EvaColors.darkGreen.withOpacity(0.22),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: EvaColors.activeGreen.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem('${recipe.calories}', s.calories, '🔥'),
              _buildNutritionItem(
                '${recipe.protein.toStringAsFixed(0)}g',
                s.protein,
                '💪',
              ),
              _buildNutritionItem(
                '${recipe.carbs.toStringAsFixed(0)}g',
                s.carbs,
                '🌾',
              ),
              _buildNutritionItem(
                '${recipe.fat.toStringAsFixed(0)}g',
                s.fat,
                '🥑',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 10,
            color: Colors.white.withOpacity(0.65),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.raleway(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: EvaColors.vitalityYellow,
      ),
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
          // Bullet point dorado
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: EvaColors.vitalityYellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$amount $unit'.trim(),
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.75),
                fontSize: 13,
              ),
            ),
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
          // Círculo dorado con número
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: EvaColors.vitalityYellow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.raleway(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                step,
                style: GoogleFonts.raleway(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
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
