import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/plan_service.dart';
import '../services/diet_service.dart';
import '../theme/eva_colors.dart';

class DietPlansScreen extends StatefulWidget {
  final String? jwtToken;
  const DietPlansScreen({super.key, this.jwtToken});

  @override
  State<DietPlansScreen> createState() => _DietPlansScreenState();
}

class _DietPlansScreenState extends State<DietPlansScreen> {
  final PlanService _planService = PlanService();
  List<PlanModel> _plans = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _planService.jwtToken = widget.jwtToken;
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final plans = await _planService.getPlans(lang: Localizations.localeOf(context).languageCode);
      setState(() { _plans = plans; _isLoading = false; });
    } catch (e) {
      setState(() { _error = AppStrings.of(context).planErrorMsg; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.calendar_month, color: Colors.white, size: 26),
              const SizedBox(width: 8),
              Text(
                AppStrings.of(context).weeklyPlan,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.of(context).weeklyPlanScreenSubtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: EvaColors.vibrantPink));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: EvaColors.vibrantPink),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(AppStrings.of(context).retry, style: const TextStyle(color: Colors.white)),
              onPressed: _loadPlans,
            ),
          ],
        ),
      );
    }

    if (_plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            Text(AppStrings.of(context).plansOnTheWay, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(AppStrings.of(context).checkBackSoon, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      );
    }

    // Intro banner
    return RefreshIndicator(
      color: EvaColors.vibrantPink,
      onRefresh: _loadPlans,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildIntroBanner(),
          const SizedBox(height: 16),
          ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
          // Placeholder para días pendientes
          ..._buildPendingDays(),
        ],
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EvaColors.vibrantPink.withOpacity(0.1),
            EvaColors.wellnessPurple.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EvaColors.vibrantPink.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: EvaColors.vibrantPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tips_and_updates, color: EvaColors.vibrantPink, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.of(context).planHowToUseTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  AppStrings.of(context).planHowToUseDesc,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(PlanModel plan) {
    final themeData = _getThemeData(plan.theme);
    final accessibleMeals = plan.meals.where((m) => !m.isLocked).length;
    final totalMeals = plan.meals.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _PlanDetailScreen(plan: plan),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del card con gradiente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (themeData['color'] as Color).withOpacity(0.15),
                    (themeData['color'] as Color).withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // Día badge
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: themeData['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.of(context).dayBadge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        Text('${plan.dayNumber}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(themeData['emoji'] as String, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              themeData['label'] as String,
                              style: TextStyle(color: themeData['color'] as Color, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            // Footer del card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  _buildInfoChip(Icons.local_fire_department, '${plan.caloriesMin}–${plan.caloriesMax} kcal', EvaColors.motivationOrange),
                  const SizedBox(width: 10),
                  _buildInfoChip(Icons.restaurant, AppStrings.of(context).mealsCount(accessibleMeals, totalMeals), EvaColors.activeGreen),
                  const Spacer(),
                  if (plan.meals.any((m) => m.isLocked))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: EvaColors.vibrantPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock, size: 11, color: EvaColors.vibrantPink),
                          SizedBox(width: 3),
                          Text('Basic/Premium', style: TextStyle(fontSize: 10, color: EvaColors.vibrantPink, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }

  List<Widget> _buildPendingDays() {
    final existingDays = _plans.map((p) => p.dayNumber).toSet();
    final pending = List.generate(7, (i) => i + 1).where((d) => !existingDays.contains(d)).toList();
    if (pending.isEmpty) return [];

    return [
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(AppStrings.of(context).comingSoon, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
      ),
      ...pending.map((day) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$day', style: TextStyle(color: Colors.grey[400], fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.of(context).dayLabel(day), style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                Text(_getPendingLabel(day), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.lock_clock, color: Colors.grey, size: 18),
          ],
        ),
      )),
    ];
  }

  String _getPendingLabel(int day) =>
      AppStrings.of(context).pendingDayLabel(day);

  Map<String, dynamic> _getThemeData(String theme) {
    const themeEmoji = {
      'perdida_peso':    '🔥',
      'gluteos_piernas': '🍑',
      'piel_radiante':   '✨',
      'saciedad':        '🥦',
      'gluteos_heavy':   '💪',
      'bienestar':       '🌸',
      'equilibrado':     '⚖️',
    };
    const themeColor = {
      'perdida_peso':    EvaColors.cosmicRed,
      'gluteos_piernas': EvaColors.motivationOrange,
      'piel_radiante':   EvaColors.wellnessPurple,
      'saciedad':        EvaColors.activeGreen,
      'gluteos_heavy':   EvaColors.strongBlue,
      'bienestar':       EvaColors.vibrantPink,
      'equilibrado':     EvaColors.vitalityYellow,
    };
    return {
      'emoji': themeEmoji[theme] ?? '📅',
      'label': AppStrings.of(context).planThemeLabel(theme),
      'color': themeColor[theme] ?? EvaColors.vibrantPink,
    };
  }
}

// ========== PLAN DETAIL SCREEN ==========

class _PlanDetailScreen extends StatelessWidget {
  final PlanModel plan;
  const _PlanDetailScreen({required this.plan});

  static const Map<String, String> _mealIcons = {
    'desayuno': '🌅',
    'snack_manana': '🍎',
    'almuerzo': '🥗',
    'snack_tarde': '🥜',
    'cena': '🌙',
    'post_entreno': '💪',
  };

  @override
  Widget build(BuildContext context) {
    final themeData = _getThemeData(plan.theme, context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // AppBar con gradiente
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: themeData['color'] as Color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeData['color'] as Color,
                      (themeData['color'] as Color).withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${themeData['emoji']} ${plan.name}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (plan.description != null) ...[
                        const SizedBox(height: 4),
                        Text(plan.description!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Nutrition summary
          SliverToBoxAdapter(child: _buildNutritionSummary(context, themeData)),

          // Meals list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildMealCard(context, plan.meals[index]),
                childCount: plan.meals.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(BuildContext context, Map<String, dynamic> themeData) {
    final s = AppStrings.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('🔥', '${plan.caloriesMin}–${plan.caloriesMax}', s.kCalTotal),
          _divider(),
          _summaryItem('🍽️', '${plan.meals.length}', s.mealsLabel),
          _divider(),
          _summaryItem('⚡', plan.meals.where((m) => m.optional).isNotEmpty ? s.yes : s.no, s.postWorkout),
        ],
      ),
    );
  }

  Widget _summaryItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey[200]);
  }

  Widget _buildMealCard(BuildContext context, PlanMeal meal) {
    final recipe = meal.recipe;
    return GestureDetector(
      onTap: () {
        if (meal.isLocked) {
          _showLockDialog(context, recipe.accessLevel);
        } else {
          _showRecipeDetail(context, recipe);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Imagen de la receta
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (c, u, e) => _imagePlaceholder(meal.mealType),
                          )
                        : _imagePlaceholder(meal.mealType),
                    if (meal.isLocked)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(child: Icon(Icons.lock, color: Colors.white, size: 22)),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _mealIcons[meal.mealType] ?? '🍽️',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          meal.optional ? '${meal.label} (${AppStrings.of(context).optionalLabel})' : meal.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: meal.optional ? EvaColors.motivationOrange : EvaColors.vibrantPink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: meal.isLocked ? Colors.grey : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (!meal.isLocked) ...[
                          const Icon(Icons.local_fire_department, size: 12, color: EvaColors.motivationOrange),
                          const SizedBox(width: 2),
                          Text('${recipe.calories} kcal', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                          const SizedBox(width: 8),
                          const Icon(Icons.timer, size: 12, color: EvaColors.vibrantPink),
                          const SizedBox(width: 2),
                          Text('${recipe.totalTime} min', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: recipe.accessLevel == 'premium'
                                  ? EvaColors.motivationOrange.withOpacity(0.1)
                                  : EvaColors.strongBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              recipe.accessLevel == 'premium' ? '⭐ Premium' : '🔵 Basic',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: recipe.accessLevel == 'premium' ? EvaColors.motivationOrange : EvaColors.strongBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (meal.note != null) ...[
                      const SizedBox(height: 4),
                      Text(meal.note!, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
            ),
            if (!meal.isLocked)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(String mealType) {
    final Map<String, Map<String, dynamic>> config = {
      'desayuno': {'icon': Icons.wb_sunny, 'color': EvaColors.vitalityYellow},
      'snack_manana': {'icon': Icons.apple, 'color': EvaColors.motivationOrange},
      'almuerzo': {'icon': Icons.lunch_dining, 'color': EvaColors.activeGreen},
      'snack_tarde': {'icon': Icons.cookie, 'color': EvaColors.cosmicRed},
      'cena': {'icon': Icons.nights_stay, 'color': EvaColors.wellnessPurple},
      'post_entreno': {'icon': Icons.fitness_center, 'color': EvaColors.strongBlue},
    };
    final c = config[mealType] ?? {'icon': Icons.restaurant, 'color': EvaColors.vibrantPink};
    return Container(
      color: (c['color'] as Color).withOpacity(0.15),
      child: Center(child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 30)),
    );
  }

  void _showLockDialog(BuildContext context, String accessLevel) {
    final s = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock, color: EvaColors.vibrantPink),
            const SizedBox(width: 8),
            Text(s.lockedMeal),
          ],
        ),
        content: Text(
          accessLevel == 'premium'
              ? s.mealLockedPremiumMsg
              : s.mealLockedBasicMsg,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.close)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: EvaColors.vibrantPink),
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.viewPlans, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetail(BuildContext context, RecipeModel recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipeDetailSheet(recipe: recipe),
    );
  }

  Map<String, dynamic> _getThemeData(String theme, [BuildContext? ctx]) {
    const themeEmoji = {
      'perdida_peso':    '🔥',
      'gluteos_piernas': '🍑',
      'piel_radiante':   '✨',
      'saciedad':        '🥦',
      'gluteos_heavy':   '💪',
      'bienestar':       '🌸',
      'equilibrado':     '⚖️',
    };
    const themeColor = {
      'perdida_peso':    EvaColors.cosmicRed,
      'gluteos_piernas': EvaColors.motivationOrange,
      'piel_radiante':   EvaColors.wellnessPurple,
      'saciedad':        EvaColors.activeGreen,
      'gluteos_heavy':   EvaColors.strongBlue,
      'bienestar':       EvaColors.vibrantPink,
      'equilibrado':     EvaColors.vitalityYellow,
    };
    final label = ctx != null
        ? AppStrings.of(ctx).planThemeLabel(theme)
        : theme;
    return {
      'emoji': themeEmoji[theme] ?? '📅',
      'label': label,
      'color': themeColor[theme] ?? EvaColors.vibrantPink,
    };
  }
}

// ========== RECIPE DETAIL SHEET (copiado de diet_screen para independencia) ==========

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
              SliverToBoxAdapter(
                child: Stack(
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
                                errorWidget: (c, u, e) => _placeholder(),
                              )
                            : _placeholder(),
                      ),
                    ),
                    Positioned(
                      top: 12, right: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 12),
                    Text(recipe.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _nutritionRow(context),
                    const SizedBox(height: 16),
                    if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                      _sectionTitle(AppStrings.of(context).description),
                      const SizedBox(height: 8),
                      Text(recipe.description!, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      const SizedBox(height: 20),
                    ],
                    if (recipe.ingredients.isNotEmpty) ...[
                      _sectionTitle(AppStrings.of(context).ingredients),
                      const SizedBox(height: 8),
                      ...recipe.ingredients.map((ing) => _ingredientRow(ing)),
                      const SizedBox(height: 20),
                    ],
                    if (recipe.steps.isNotEmpty) ...[
                      _sectionTitle(AppStrings.of(context).preparation),
                      const SizedBox(height: 8),
                      ...recipe.steps.asMap().entries.map((e) => _stepRow(e.key + 1, e.value)),
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

  Widget _placeholder() => Container(
    color: EvaColors.vibrantPink.withOpacity(0.15),
    child: const Center(child: Icon(Icons.restaurant_menu, size: 60, color: EvaColors.vibrantPink)),
  );

  Widget _sectionTitle(String t) => Text(t,
    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: EvaColors.vibrantPink));

  Widget _nutritionRow(BuildContext context) {
    final s = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EvaColors.activeGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EvaColors.activeGreen.withOpacity(0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _nutItem('${recipe.calories}',                    s.calories, '🔥'),
        _nutItem('${recipe.protein.toStringAsFixed(0)}g', s.protein,  '💪'),
        _nutItem('${recipe.carbs.toStringAsFixed(0)}g',   s.carbs,    '🌾'),
        _nutItem('${recipe.fat.toStringAsFixed(0)}g',     s.fat,      '🥑'),
      ]),
    );
  }

  Widget _nutItem(String val, String lbl, String emoji) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(height: 2),
    Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    Text(lbl, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
  ]);

  Widget _ingredientRow(Map<String, dynamic> ing) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Container(width: 6, height: 6, decoration: const BoxDecoration(color: EvaColors.vibrantPink, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Text('${ing['amount'] ?? ''} ${ing['unit'] ?? ''}'.trim(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(width: 6),
      Expanded(child: Text(ing['name'] ?? '', style: TextStyle(color: Colors.grey[700], fontSize: 13))),
    ]),
  );

  Widget _stepRow(int n, String step) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: EvaColors.vibrantPink, shape: BoxShape.circle),
        child: Center(child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(step, style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.5)),
      )),
    ]),
  );
}
