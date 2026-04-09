import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/language_provider.dart';
import '../services/routine_recommendation_service.dart';
import '../services/user_profile_service.dart' hide UserProfile;
import '../services/routine_service.dart';
import '../services/trial_service.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/eva_colors.dart';
import 'profile_setup_screen.dart';
import 'payments_screen.dart';
import 'routine_execution_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  _RoutinesScreenState createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _loadingRoutines = true;
  bool _loadingPersonalized = true;
  bool _loadingTemplates = true;
  PersonalizedRoutine? _personalizedRoutine;
  List<RoutineTemplate> _templates = [];
  List<Routine> _backendRoutines = [];
  List<Routine> _favoriteRoutines = [];
  Set<String> _favoriteIds = {};
  List<WorkoutRecord> _historyRecords = [];
  WorkoutStats? _historyStats;
  TrialStatus? _trialStatus;

  // Búsqueda y filtros del tab "Todas"
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterCategory = 'todas';
  String _filterDifficulty = 'todas';

  // Cache de listas filtradas — se actualiza solo cuando cambian los datos/filtros
  List<Routine> _filteredRoutinesCache = [];
  List<String> _availableCategoriesCache = ['todas'];
  List<String> _availableDifficultiesCache = ['todas'];
  String _selectedAgeRange = '18-35';
  String _selectedLevel = 'principiante';
  bool? _selectedKneeSensitive;
  String _selectedCategory = 'funcional';
  final UserProfileService _userProfileService = UserProfileService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _userProfileService.initializeProfile();
    _loadData();
  }

  // Solo reconstruye cuando el índice cambia (no durante la animación)
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Recalcula las listas cacheadas cuando cambian rutinas o filtros
  void _updateFilterCache() {
    final cats = _backendRoutines.map((r) => r.category.toLowerCase()).toSet().toList()..sort();
    _availableCategoriesCache = ['todas', ...cats];

    final diffs = _backendRoutines.map((r) => r.difficulty.toLowerCase()).toSet().toList()..sort();
    _availableDifficultiesCache = ['todas', ...diffs];

    _filteredRoutinesCache = _backendRoutines.where((r) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q));
      final matchesCat = _filterCategory == 'todas' ||
          r.category.toLowerCase() == _filterCategory;
      final matchesDiff = _filterDifficulty == 'todas' ||
          r.difficulty.toLowerCase() == _filterDifficulty;
      return matchesSearch && matchesCat && matchesDiff;
    }).toList();
  }

  // Envuelve cualquier Future<T> y devuelve T? (null si falla)
  Future<T?> _safeCall<T>(Future<T> f) async {
    try {
      return await f;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loadingRoutines = true;
      _loadingPersonalized = true;
      _loadingTemplates = true;
    });
    try {
      // Aplicar perfil local al estado de filtros antes de las llamadas
      final userProfile = _userProfileService.currentUser;
      if (userProfile != null) {
        _selectedLevel = userProfile.fitnessLevel;
        _selectedKneeSensitive = userProfile.kneeSensitive;
        if (userProfile.age <= 35) {
          _selectedAgeRange = '18-35';
        } else if (userProfile.age <= 55) {
          _selectedAgeRange = '36-55';
        } else {
          _selectedAgeRange = '55+';
        }
      }

      // Lanzar las 6 llamadas EN PARALELO con tipos correctamente nullables
      final _currentLang = Localizations.localeOf(context).languageCode;
      final results = await Future.wait([
        _safeCall(TrialService.getTrialStatus()),
        _safeCall(RoutineService.getRoutines(page: 1, limit: 20, lang: _currentLang)),
        _safeCall(HistoryService.getHistory()),
        _safeCall(FavoritesService.getFavorites(lang: _currentLang)),
        _safeCall(RoutineRecommendationService.getPersonalizedRoutine(lang: _currentLang)),
        _safeCall(RoutineRecommendationService.getTemplates(
          ageRange: _selectedAgeRange,
          level: _selectedLevel,
          kneeSensitive: _selectedKneeSensitive,
          category: _selectedCategory,
          lang: _currentLang,
        )),
      ]);

      if (!mounted) return;
      setState(() {
        // Trial
        if (results[0] != null) _trialStatus = results[0] as TrialStatus;

        // Rutinas
        final routinesResponse = results[1] as Map<String, dynamic>?;
        if (routinesResponse != null && routinesResponse['success'] == true) {
          final List routinesJson = routinesResponse['data']['routines'] ?? [];
          _backendRoutines =
              routinesJson.map((r) => Routine.fromJson(r, lang: _currentLang)).toList();
        }
        _loadingRoutines = false;
        _updateFilterCache();

        // Historial
        if (results[2] != null) {
          final history = results[2]
              as ({List<WorkoutRecord> records, WorkoutStats stats});
          _historyRecords = history.records;
          _historyStats = history.stats;
        }

        // Favoritos
        final favs = results[3] as List<Routine>? ?? <Routine>[];
        _favoriteRoutines = favs;
        _favoriteIds = favs.map((r) => r.id).toSet();

        // Rutina personalizada
        final personalizedResponse = results[4] as Map<String, dynamic>?;
        if (personalizedResponse != null &&
            personalizedResponse['success'] == true) {
          _personalizedRoutine = PersonalizedRoutine.fromJson(
            personalizedResponse['data']['routine'],
          );
        }
        _loadingPersonalized = false;

        // Plantillas
        final templatesResponse = results[5] as Map<String, dynamic>?;
        if (templatesResponse != null &&
            templatesResponse['success'] == true) {
          _templates = (templatesResponse['data'] as List)
              .map((t) => RoutineTemplate.fromJson(t))
              .toList();
        }
        _loadingTemplates = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingRoutines = false;
          _loadingPersonalized = false;
          _loadingTemplates = false;
        });
        final msg = e.toString();
        if (!msg.contains('401') &&
            !msg.contains('No autorizado') &&
            !msg.contains('Token')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppStrings.of(context).errorLoadingData}: $e'),
              backgroundColor: EvaColors.cosmicRed,
            ),
          );
        }
      }
    }
  }

  void _startRoutine(BuildContext context, PersonalizedRoutine routine) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Fondo con gradiente animado — aislado con RepaintBoundary
              RepaintBoundary(
                child: SizedBox(
                  height: 420,
                  child: AnimateGradient(
                    primaryColors: const [
                      Color(0xFFFF69B4),
                      Color(0xFFE91E63),
                      Color(0xFF800080),
                    ],
                    secondaryColors: const [
                      Color(0xFF800080),
                      Color(0xFFE91E63),
                      Color(0xFFFF69B4),
                    ],
                    duration: const Duration(seconds: 4),
                  ),
                ),
              ),
              // Overlay oscuro sutil
              Container(
                height: 420,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
              // Contenido
              SizedBox(
                height: 420,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ícono
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.self_improvement_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      // Mensaje motivacional
                      Text(
                        AppStrings.of(context).readyMsg,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.7,
                          letterSpacing: 0.2,
                        ),
                      ),
                      // Botones
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RoutineExecutionScreen(routine: routine),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_circle_filled, size: 22),
                              label: Text(
                                AppStrings.of(ctx).iAmReady,
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: EvaColors.cosmicRed,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              AppStrings.of(ctx).notNow,
                              style: GoogleFonts.raleway(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
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
        ),
      ),
    );
  }

  Future<void> _loadTemplates() async {
    if (!mounted) return;
    setState(() => _loadingTemplates = true);
    try {
      final response = await RoutineRecommendationService.getTemplates(
        ageRange: _selectedAgeRange,
        level: _selectedLevel,
        kneeSensitive: _selectedKneeSensitive,
        category: _selectedCategory,
        lang: Localizations.localeOf(context).languageCode,
      );
      if (!mounted) return;
      setState(() {
        if (response['success'] == true) {
          _templates = (response['data'] as List)
              .map((t) => RoutineTemplate.fromJson(t))
              .toList();
        }
        _loadingTemplates = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loadingTemplates = false);
    }
  }

  Future<void> _toggleFavorite(Routine routine) async {
    // Actualización optimista: cambia el estado local inmediatamente
    final wasInFavorites = _favoriteIds.contains(routine.id);
    setState(() {
      if (wasInFavorites) {
        _favoriteIds.remove(routine.id);
        _favoriteRoutines.removeWhere((r) => r.id == routine.id);
      } else {
        _favoriteIds.add(routine.id);
        _favoriteRoutines.add(routine);
      }
    });

    try {
      await FavoritesService.toggleFavorite(routine.id);
    } catch (e) {
      // Revertir si falló
      setState(() {
        if (wasInFavorites) {
          _favoriteIds.add(routine.id);
          _favoriteRoutines.add(routine);
        } else {
          _favoriteIds.remove(routine.id);
          _favoriteRoutines.removeWhere((r) => r.id == routine.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar favoritos: $e'),
          backgroundColor: EvaColors.cosmicRed,
        ),
      );
    }
  }

  Future<void> _refreshPersonalizedRoutine() async {
    try {
      final response =
          await RoutineRecommendationService.getPersonalizedRoutine(lang: Localizations.localeOf(context).languageCode);
      if (response['success']) {
        setState(() {
          _personalizedRoutine = PersonalizedRoutine.fromJson(
            response['data']['routine'],
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).routineUpdated),
            backgroundColor: EvaColors.activeGreen,
          ),
        );
      }
    } catch (e) {
      // Ignorar errores de autenticación (usuario no logueado)
      final msg = e.toString();
      if (!msg.contains('401') && !msg.contains('No autorizado') && !msg.contains('Token')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar: $e'),
              backgroundColor: EvaColors.cosmicRed,
            ),
          );
        }
      }
    }
  }

  // ─────────────────────────────── BUILD ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: EvaColors.primaryGradient),
        ),
        title: Text(
          AppStrings.of(context).myRoutines,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.raleway(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.raleway(fontWeight: FontWeight.w400, fontSize: 12),
          tabs: [
            Tab(text: AppStrings.of(context).tabForYou,    icon: const Icon(Icons.person, size: 18)),
            Tab(text: AppStrings.of(context).tabAll,       icon: const Icon(Icons.library_books, size: 18)),
            Tab(text: AppStrings.of(context).tabFavorites, icon: const Icon(Icons.favorite, size: 18)),
            Tab(text: AppStrings.of(context).tabHistory,   icon: const Icon(Icons.history, size: 18)),
            Tab(text: AppStrings.of(context).tabExplore,   icon: const Icon(Icons.explore, size: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSetupScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo animado — aislado con RepaintBoundary para no invalidar el árbol
          RepaintBoundary(
            child: AnimateGradient(
              primaryBeginGeometry: const AlignmentDirectional(0, 1),
              primaryEndGeometry: const AlignmentDirectional(0, 2),
              secondaryBeginGeometry: const AlignmentDirectional(2, 0),
              secondaryEndGeometry: const AlignmentDirectional(0, -0.8),
              textDirectionForGeometry: TextDirection.rtl,
              primaryColors: const [
                Color(0xFFFF69B4),
                Color(0xFFE91E63),
                Color(0xFFFFFFFF),
              ],
              secondaryColors: const [
                Color(0xFFFFFFFF),
                Color(0xFF9C27B0),
                Color(0xFF800080),
              ],
              child: Container(),
            ),
          ),
          // Contenido
          SafeArea(
            child: Column(
              children: [
                if (_trialStatus != null &&
                    TrialService.shouldShowSubscriptionBanner(_trialStatus!))
                  _buildTrialBanner(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalizedTab(),
                      _buildBackendRoutinesTab(),
                      _buildFavoritesTab(),
                      _buildHistoryTab(),
                      _buildExploreTab(),
                    ],
                  ),
                ),
              ],
                  ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _refreshPersonalizedRoutine,
              backgroundColor: EvaColors.cosmicRed,
              tooltip: AppStrings.of(context).updateRoutine,
              child: const Icon(Icons.refresh, color: Colors.white),
            )
          : null,
    );
  }

  // ──────────────────────── TAB: PARA TI ───────────────────────────────────

  Widget _buildPersonalizedTab() {
    if (_loadingPersonalized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_personalizedRoutine == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _glassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fitness_center, size: 64, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  AppStrings.of(context).noPersonalized,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.of(context).noPersonalizedSub,
                  style: GoogleFonts.raleway(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _evaButton(
                  label: AppStrings.of(context).setupProfile,
                  icon: Icons.person_add,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileSetupScreen(),
                      ),
                    ).then((_) => _loadData());
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingCard(),
          const SizedBox(height: 12),
          _buildWeeklyProgressCard(),
          const SizedBox(height: 16),
          _buildRoutineHeader(),
          const SizedBox(height: 16),
          _buildRoutineBlock(
            AppStrings.of(context).warmup,
            _personalizedRoutine!.calentamiento,
            EvaColors.motivationOrange,
            Icons.wb_sunny_outlined,
          ),
          const SizedBox(height: 12),
          _buildRoutineBlock(
            AppStrings.of(context).mainBlock,
            _personalizedRoutine!.principal,
            EvaColors.vibrantPink,
            Icons.fitness_center,
          ),
          const SizedBox(height: 12),
          _buildRoutineBlock(
            AppStrings.of(context).cooldown,
            _personalizedRoutine!.enfriamiento,
            EvaColors.strongBlue,
            Icons.ac_unit_outlined,
          ),
        ],
      ),
    );
  }

  // ── Saludo + frase motivacional ──────────────────────────────────────────

  String _getGreeting(BuildContext context) {
    final s = AppStrings.of(context);
    final hour = DateTime.now().hour;
    if (hour < 12) return s.goodMorning;
    if (hour < 19) return s.goodAfternoon;
    return s.goodEvening;
  }

  String _getDailyQuote(BuildContext context) {
    final quotes = AppStrings.of(context).dailyQuotes;
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  Widget _buildGreetingCard() {
    final userProfile = _userProfileService.currentUser;
    final isEn = context.read<LanguageProvider>().isEnglish;
    final name = userProfile?.name.split(' ').first ?? (isEn ? 'champion' : 'campeona');
    final greeting = _getGreeting(context);
    final hour = DateTime.now().hour;
    final greetIcon = hour < 12
        ? '🌸'
        : hour < 19
            ? '☀️'
            : '🌙';

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(greetIcon, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$greeting, $name',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EvaColors.vibrantPink.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: EvaColors.vibrantPink.withOpacity(0.25)),
            ),
            child: Text(
              _getDailyQuote(context),
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ── Racha + progreso semanal ─────────────────────────────────────────────

  int _calculateStreak() {
    if (_historyRecords.isEmpty) return 0;
    final today = DateTime.now();
    final trainedDays = _historyRecords
        .map((r) => DateTime(
            r.completedAt.year, r.completedAt.month, r.completedAt.day))
        .toSet();

    int streak = 0;
    DateTime day = DateTime(today.year, today.month, today.day);
    while (trainedDays.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Set<int> _getWeeklyActivity() {
    final now = DateTime.now();
    // Lunes de esta semana
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _historyRecords
        .where((r) =>
            r.completedAt.isAfter(
                weekStart.subtract(const Duration(seconds: 1))) &&
            r.completedAt.isBefore(weekEnd))
        .map((r) => r.completedAt.weekday) // 1=Lun … 7=Dom
        .toSet();
  }

  Widget _buildWeeklyProgressCard() {
    final streak = _calculateStreak();
    final activeWeekdays = _getWeeklyActivity();
    final today = DateTime.now().weekday;
    final dayLabels = AppStrings.of(context).weekdayLabelsShort;

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila racha + semana title
          Row(
            children: [
              // Racha
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: streak > 0
                      ? EvaColors.motivationOrange.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: streak > 0
                        ? EvaColors.motivationOrange.withOpacity(0.5)
                        : Colors.white24,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      streak > 0 ? '🔥' : '💤',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      streak > 0
                          ? AppStrings.of(context).streakDays(streak)
                          : AppStrings.of(context).noActiveStreak,
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: streak > 0
                            ? EvaColors.motivationOrange
                            : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.of(context).thisWeek,
                style: GoogleFonts.raleway(
                    fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Círculos de días
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final weekday = i + 1;
              final isActive = activeWeekdays.contains(weekday);
              final isToday = weekday == today;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive
                          ? LinearGradient(
                              colors: [
                                EvaColors.vibrantPink,
                                EvaColors.cosmicRed
                              ],
                            )
                          : null,
                      color: isActive
                          ? null
                          : isToday
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: isToday && !isActive
                            ? EvaColors.vibrantPink.withOpacity(0.7)
                            : isActive
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.15),
                        width: isToday ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color:
                                    EvaColors.vibrantPink.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isActive
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                              dayLabels[i],
                              style: GoogleFonts.raleway(
                                fontSize: 12,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isToday
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayLabels[i],
                    style: GoogleFonts.raleway(
                      fontSize: 10,
                      color: isToday
                          ? EvaColors.vibrantPink
                          : Colors.white38,
                      fontWeight: isToday
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }),
          ),
          if (activeWeekdays.isNotEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                AppStrings.of(context).daysTrainedThisWeek(activeWeekdays.length),
                style: GoogleFonts.raleway(
                  fontSize: 11,
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineHeader() {
    final userProfile = _userProfileService.currentUser;

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _personalizedRoutine!.name,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _personalizedRoutine!.description,
            style: GoogleFonts.raleway(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Perfil del usuario
          if (userProfile != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Tu Perfil: ${userProfile.name}',
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _infoChip('${userProfile.age} años', Icons.cake_outlined),
                      _infoChip(userProfile.fitnessLevel, Icons.fitness_center),
                    ],
                  ),
                  if (userProfile.kneeSensitive) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: EvaColors.motivationOrange.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: EvaColors.motivationOrange.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: EvaColors.motivationOrange, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.of(context).kneeAdapted,
                            style: GoogleFonts.raleway(
                              fontSize: 11,
                              color: EvaColors.motivationOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Chips de info
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _infoChip(
                  '${_personalizedRoutine!.duration} min', Icons.timer_outlined),
              _infoChip('${_personalizedRoutine!.mainCycles} ciclos',
                  Icons.repeat),
              _infoChip(_personalizedRoutine!.userProfile.fitnessLevel,
                  Icons.trending_up),
            ],
          ),
          const SizedBox(height: 16),

          // Botón empezar
          _evaButton(
            label: AppStrings.of(context).startRoutineLabel,
            icon: Icons.play_circle_filled,
            onPressed: () => _startRoutine(context, _personalizedRoutine!),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineBlock(
      String title, RoutineBlock block, Color accentColor, IconData icon) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          ...block.exercises.map((e) => _buildExerciseItem(e, accentColor)),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withOpacity(0.4)),
            ),
            child: Icon(Icons.fitness_center, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  exercise.shortDescription,
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (exercise.timeSeconds != null)
                Text(
                  '${exercise.timeSeconds}s',
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: accentColor,
                  ),
                ),
              if (exercise.restSeconds > 0)
                Text(
                  'Desc: ${exercise.restSeconds}s',
                  style: GoogleFonts.raleway(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────── TAB: TODAS ─────────────────────────────────────

  // ── Filtrado local ───────────────────────────────────────────────────────


  Widget _buildBackendRoutinesTab() {
    if (_loadingRoutines) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_backendRoutines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _glassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.library_books,
                    size: 64, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  AppStrings.of(context).noRoutinesAvailable,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtered = _filteredRoutinesCache;

    return Column(
      children: [
        // ── Barra de búsqueda ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.raleway(fontSize: 14, color: Colors.white),
            onChanged: (v) => setState(() { _searchQuery = v; _updateFilterCache(); }),
            decoration: InputDecoration(
              hintText: 'Buscar rutinas...',
              hintStyle: GoogleFonts.raleway(
                  fontSize: 13, color: Colors.white38),
              prefixIcon:
                  const Icon(Icons.search, color: Colors.white54, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white54, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() { _searchQuery = ''; _updateFilterCache(); });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: EvaColors.vibrantPink.withOpacity(0.6),
                    width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Chips de categoría ──
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _availableCategoriesCache.map((cat) {
              final selected = _filterCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () =>
                      setState(() { _filterCategory = cat; _updateFilterCache(); }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? EvaColors.vibrantPink
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? EvaColors.vibrantPink
                            : Colors.white.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      _capitalize(cat),
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : Colors.white60,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),

        // ── Chips de dificultad ──
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _availableDifficultiesCache.map((diff) {
              final selected = _filterDifficulty == diff;
              final color = _difficultyColor(diff);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () =>
                      setState(() { _filterDifficulty = diff; _updateFilterCache(); }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withOpacity(0.8)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? color
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _capitalize(diff),
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : Colors.white54,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // ── Contador de resultados ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${filtered.length} rutina${filtered.length == 1 ? '' : 's'}',
                style: GoogleFonts.raleway(
                    fontSize: 12, color: Colors.white54),
              ),
              if (_searchQuery.isNotEmpty ||
                  _filterCategory != 'todas' ||
                  _filterDifficulty != 'todas') ...[
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() {
                      _searchQuery = '';
                      _filterCategory = 'todas';
                      _filterDifficulty = 'todas';
                    });
                  },
                  child: Text(
                    AppStrings.of(context).clearFilters,
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: EvaColors.vibrantPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),

        // ── Lista filtrada ──
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _glassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off,
                              size: 48, color: Colors.white38),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.of(context).noResults,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Prueba con otros términos\no limpia los filtros.',
                            style: GoogleFonts.raleway(
                              fontSize: 12,
                              color: Colors.white38,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildBackendRoutineCard(filtered[index]),
                ),
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Color _difficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'beginner':
      case 'principiante':
        return EvaColors.activeGreen;
      case 'intermediate':
      case 'intermedio':
        return EvaColors.motivationOrange;
      case 'advanced':
      case 'avanzado':
        return EvaColors.cosmicRed;
      default:
        return EvaColors.balanceGray;
    }
  }

  Widget _buildBackendRoutineCard(Routine routine) {
    final canAccess = _trialStatus?.hasAccess ?? false;
    final isLocked = routine.accessLevel == 'premium' && !canAccess;
    final isFav = _favoriteIds.contains(routine.id);

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showSubscriptionDialog();
        } else {
          _showRoutineDetails(routine);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFav
                ? EvaColors.vibrantPink.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: EvaColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: EvaColors.cosmicRed.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_outline : Icons.fitness_center,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              routine.title,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Botón favorito
                          GestureDetector(
                            onTap: () => _toggleFavorite(routine),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(isFav),
                                color: isFav
                                    ? EvaColors.vibrantPink
                                    : Colors.white38,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildAccessBadge(routine.accessLevel),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        routine.description,
                        style: GoogleFonts.raleway(
                          fontSize: 12,
                          color: Colors.white60,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _infoChip('${routine.duration} min', Icons.timer_outlined),
                const SizedBox(width: 6),
                _infoChip(routine.difficulty, Icons.trending_up),
                const SizedBox(width: 6),
                _infoChip(routine.category, Icons.category_outlined),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: EvaColors.vitalityYellow, size: 16),
                    const SizedBox(width: 3),
                    Text(
                      routine.rating.toStringAsFixed(1),
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── TAB: FAVORITAS ─────────────────────────────────

  Widget _buildFavoritesTab() {
    if (_favoriteRoutines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _glassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_border,
                    size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                Text(
                  AppStrings.of(context).noFavoritesYet,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Toca el corazón en cualquier rutina\npara guardarla aquí.',
                  style: GoogleFonts.raleway(
                    fontSize: 13,
                    color: Colors.white60,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _evaButton(
                  label: 'Explorar Rutinas',
                  icon: Icons.library_books,
                  onPressed: () => _tabController.animateTo(1),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.favorite,
                  color: EvaColors.vibrantPink, size: 18),
              const SizedBox(width: 8),
              Text(
                '${_favoriteRoutines.length} rutina${_favoriteRoutines.length == 1 ? '' : 's'} guardada${_favoriteRoutines.length == 1 ? '' : 's'}',
                style: GoogleFonts.raleway(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: _favoriteRoutines.length,
            itemBuilder: (context, index) =>
                _buildBackendRoutineCard(_favoriteRoutines[index]),
          ),
        ),
      ],
    );
  }

  // ──────────────────────── TAB: HISTORIAL ─────────────────────────────────

  Widget _buildHistoryTab() {
    if (_historyRecords.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: _glassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                Text(
                  AppStrings.of(context).noWorkoutsYet,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa tu primera rutina\ny aparecerá aquí.',
                  style: GoogleFonts.raleway(
                    fontSize: 13,
                    color: Colors.white60,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _evaButton(
                  label: 'Ver Rutinas',
                  icon: Icons.fitness_center,
                  onPressed: () => _tabController.animateTo(1),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // ── Estadísticas globales ──
        if (_historyStats != null) _buildHistoryStats(),
        const SizedBox(height: 20),

        // ── Lista de registros ──
        Text(
          AppStrings.of(context).latestWorkouts,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ..._historyRecords.map(_buildHistoryCard),
      ],
    );
  }

  Widget _buildHistoryStats() {
    final stats = _historyStats!;
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: EvaColors.vibrantPink, size: 18),
              const SizedBox(width: 8),
              Text(
                AppStrings.of(context).totalProgress,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.fitness_center,
                  value: '${stats.totalWorkouts}',
                  label: 'Entrenam.',
                  color: EvaColors.vibrantPink,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timer_outlined,
                  value: '${stats.totalMinutes}',
                  label: AppStrings.of(context).minutesLabel,
                  color: EvaColors.motivationOrange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department_outlined,
                  value: '${stats.totalCalories}',
                  label: 'Cal. quemadas',
                  color: EvaColors.cosmicRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 10,
            color: Colors.white60,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryCard(WorkoutRecord record) {
    final date = record.completedAt;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: EvaColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.routineName,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoChip(
                        '${record.durationMinutes} min', Icons.timer_outlined),
                    const SizedBox(width: 6),
                    _infoChip('${record.caloriesEstimated} cal',
                        Icons.local_fire_department_outlined),
                  ],
                ),
              ],
            ),
          ),
          // Fecha
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateStr,
                style: GoogleFonts.raleway(
                  fontSize: 11,
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                timeStr,
                style: GoogleFonts.raleway(
                  fontSize: 11,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────── TAB: EXPLORAR ──────────────────────────────────

  Widget _buildExploreTab() {
    if (_loadingTemplates) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _templates.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _glassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off,
                              size: 48, color: Colors.white54),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.of(context).noResultsFilters,
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    return _buildTemplateCard(_templates[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final inputStyle = GoogleFonts.raleway(
      fontSize: 13,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    );
    final labelStyle = GoogleFonts.raleway(
      fontSize: 12,
      color: Colors.white70,
    );
    final dropDecoration = InputDecoration(
      isDense: true,
      labelStyle: labelStyle,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(context).filtersLabel,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedAgeRange,
                  dropdownColor: EvaColors.wellnessPurple,
                  style: inputStyle,
                  decoration: dropDecoration.copyWith(labelText: AppStrings.of(context).age),
                  items: ['18-35', '36-55', '55+'].map((age) {
                    return DropdownMenuItem(value: age, child: Text(age));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedAgeRange = value!);
                    _loadTemplates();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  dropdownColor: EvaColors.wellnessPurple,
                  style: inputStyle,
                  decoration: dropDecoration.copyWith(labelText: AppStrings.of(context).levelLabel),
                  items: ['principiante', 'intermedio', 'avanzado'].map((l) {
                    return DropdownMenuItem(value: l, child: Text(AppStrings.of(context).routineDifficulty(l)));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLevel = value!);
                    _loadTemplates();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: EvaColors.wellnessPurple,
                  style: inputStyle,
                  decoration:
                      dropDecoration.copyWith(labelText: AppStrings.of(context).categoryLabel),
                  items: ['funcional', 'gluteos', 'cardio', 'hiit', 'pilates', 'yoga', 'fuerza'].map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(AppStrings.of(context).routineCategory(cat)));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                    _loadTemplates();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<bool>(
                  value: _selectedKneeSensitive,
                  dropdownColor: EvaColors.wellnessPurple,
                  style: inputStyle,
                  decoration: dropDecoration.copyWith(
                      labelText: AppStrings.of(context).kneesLabel),
                  items: [
                    DropdownMenuItem(value: null, child: Text(AppStrings.of(context).all)),
                    DropdownMenuItem(value: false, child: Text(AppStrings.of(context).noRestriction)),
                    DropdownMenuItem(value: true,  child: Text(AppStrings.of(context).withSensitivity)),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedKneeSensitive = value);
                    _loadTemplates();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(RoutineTemplate template) {
    return GestureDetector(
      onTap: () => _showTemplateDetails(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: EvaColors.vibrantPink.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: EvaColors.vibrantPink.withOpacity(0.5)),
              ),
              child: const Icon(Icons.fitness_center,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    template.description,
                    style: GoogleFonts.raleway(
                        fontSize: 12, color: Colors.white60),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 14),
          ],
        ),
      ),
    );
  }

  void _showTemplateDetails(RoutineTemplate template) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: EvaColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  template.name,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  template.description,
                  style: GoogleFonts.raleway(
                      fontSize: 13, color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                    Icons.timer_outlined, AppStrings.of(context).durationLabel,
                    '${template.baseDurationMinutes} min'),
                _buildDetailRow(
                    Icons.category_outlined, AppStrings.of(context).categoryLabel,
                    AppStrings.of(context).routineCategory(template.category)),
                _buildDetailRow(
                    Icons.bolt, AppStrings.of(context).intensityLabel, template.intensity),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: template.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(tag,
                                style: GoogleFonts.raleway(
                                    fontSize: 11, color: Colors.white)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.of(context).close,
                            style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _generateRoutineFromTemplate(template.templateId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: EvaColors.cosmicRed,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.of(context).useTemplate,
                            style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateRoutineFromTemplate(String templateId) async {
    try {
      final response =
          await RoutineRecommendationService.generateRoutineFromTemplate(
              templateId: templateId);
      if (response['success']) {
        setState(() {
          _personalizedRoutine = PersonalizedRoutine.fromJson(
            response['data']['routine'],
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).routineGeneratedSuccess),
            backgroundColor: EvaColors.activeGreen,
          ),
        );
        _tabController.animateTo(0);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar rutina: $e'),
          backgroundColor: EvaColors.cosmicRed,
        ),
      );
    }
  }

  // ─────────────────────── DIALOG: DETALLES RUTINA ─────────────────────────

  void _showRoutineDetails(Routine routine) {
    final screenContext = context;
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          decoration: BoxDecoration(
            gradient: EvaColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título + badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        routine.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildAccessBadge(routine.accessLevel),
                  ],
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 4),

                Text(
                  routine.description,
                  style: GoogleFonts.raleway(
                      fontSize: 13, color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 16),

                _buildDetailRow(
                    Icons.person_outline, AppStrings.of(context).instructorLabel, routine.instructorName),
                _buildDetailRow(
                    Icons.timer_outlined, AppStrings.of(context).durationLabel, '${routine.duration} min'),
                _buildDetailRow(
                    Icons.trending_up, AppStrings.of(context).levelLabel,
                    AppStrings.of(context).routineDifficulty(routine.difficulty)),
                _buildDetailRow(
                    Icons.category_outlined, AppStrings.of(context).categoryLabel,
                    AppStrings.of(context).routineCategory(routine.category)),
                const SizedBox(height: 12),

                // Rating
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: EvaColors.vitalityYellow, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${routine.rating.toStringAsFixed(1)}  (${AppStrings.of(context).ratingsCount(routine.ratingCount)})',
                      style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: routine.tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(AppStrings.of(context).routineTag(tag),
                                style: GoogleFonts.raleway(
                                    fontSize: 11, color: Colors.white)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppStrings.of(context).close,
                            style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          Navigator.of(screenContext).push(
                            MaterialPageRoute(
                              builder: (_) => RoutineExecutionScreen(
                                routine: _routineToPersonalized(routine),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_filled, size: 18),
                        label: Text(
                          AppStrings.of(context).startWorkout,
                          style: GoogleFonts.raleway(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: EvaColors.cosmicRed,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── BANNER TRIAL ────────────────────────────────────

  Widget _buildTrialBanner() {
    if (_trialStatus == null) return const SizedBox.shrink();

    final message = TrialService.getStatusMessage(_trialStatus!);
    final isExpired = _trialStatus!.trialExpired;
    final daysRemaining = _trialStatus!.daysRemaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isExpired
                      ? EvaColors.cosmicRed
                      : daysRemaining <= 2
                          ? EvaColors.motivationOrange
                          : EvaColors.vibrantPink)
                  .withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpired ? Icons.lock_outline : Icons.info_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (!isExpired && daysRemaining <= 2)
                  Text(
                    '¡Suscríbete ahora para seguir disfrutando!',
                    style: GoogleFonts.raleway(
                        color: Colors.white70, fontSize: 11),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final token = await SecureStorageService.getToken();
              if (token != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PaymentsScreen(jwtToken: token)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
                  isExpired ? EvaColors.cosmicRed : EvaColors.wellnessPurple,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              textStyle:
                  GoogleFonts.raleway(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            child: Text(isExpired ? AppStrings.of(context).subscribe : AppStrings.of(context).viewPlans),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── DIALOG: SUSCRIPCIÓN ─────────────────────────────

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: _PremiumDialog(
          onUpgrade: () async {
            Navigator.pop(ctx);
            final token = await SecureStorageService.getToken();
            if (token != null && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PaymentsScreen(jwtToken: token)),
              );
            }
          },
          onDismiss: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  // ─────────────────────── HELPERS ─────────────────────────────────────────

  Widget _glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: child,
    );
  }

  Widget _infoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.raleway(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessBadge(String level) {
    Color color;
    String label;
    switch (level) {
      case 'free':
        color = EvaColors.activeGreen;
        label = 'FREE';
        break;
      case 'basic':
        color = EvaColors.strongBlue;
        label = 'BÁSICO';
        break;
      case 'premium':
        color = EvaColors.vitalityYellow;
        label = 'PREMIUM';
        break;
      case 'exclusive':
        color = EvaColors.cosmicRed;
        label = 'ELITE';
        break;
      default:
        color = EvaColors.balanceGray;
        label = level.toUpperCase();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.raleway(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white60),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.raleway(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _evaButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.raleway(
              fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: EvaColors.cosmicRed,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: EvaColors.cosmicRed.withOpacity(0.4),
        ),
      ),
    );
  }

  PersonalizedRoutine _routineToPersonalized(Routine routine) {
    final s = AppStrings.of(context);
    final warmupExercise = Exercise(
      exerciseId: 'CAL_MARCHA_SUAVE',
      name: s.languageCode == 'en' ? 'General Warm-up' : 'Calentamiento general',
      shortDescription: s.languageCode == 'en'
          ? 'Joint mobility and muscle activation'
          : 'Movilidad articular y activación muscular',
      type: 'cardio_suave',
      zone: 'cuerpo completo',
      timeSeconds: 300,
      restSeconds: 0,
      kneeFriendly: true,
      order: 1,
    );
    final mainExercise = Exercise(
      exerciseId: 'FICHA1_SENTADILLA_ELEVACION',
      name: routine.title,
      shortDescription: s.languageCode == 'en'
          ? 'Workout focused on glutes, legs and core strength'
          : 'Rutina de fuerza enfocada en glúteos, piernas y core',
      type: 'fuerza',
      zone: 'gluteos_piernas',
      timeSeconds: (routine.duration * 60 * 0.7).toInt(),
      restSeconds: 30,
      kneeFriendly: true,
      order: 1,
    );
    final cooldownExercise = Exercise(
      exerciseId: 'FICHA1_ESTIR_GLUTEOS',
      name: s.languageCode == 'en' ? 'Cool-down & Stretching' : 'Enfriamiento y estiramientos',
      shortDescription: s.languageCode == 'en'
          ? 'Gentle stretches for recovery'
          : 'Estiramientos suaves para recuperación',
      type: 'flexibilidad',
      zone: 'cuerpo completo',
      timeSeconds: 180,
      restSeconds: 0,
      kneeFriendly: true,
      order: 1,
    );
    return PersonalizedRoutine(
      name: routine.title,
      description: routine.description,
      duration: routine.duration,
      mainCycles: 1,
      calentamiento: RoutineBlock(exercises: [warmupExercise]),
      principal: RoutineBlock(exercises: [mainExercise]),
      enfriamiento: RoutineBlock(exercises: [cooldownExercise]),
      userProfile: UserProfile(
        ageRange: '18-35',
        constitution: 'normal',
        fitnessLevel: routine.difficulty,
        kneeSensitive: false,
        pathologies: 'ninguna',
        dailyTime: routine.duration,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PREMIUM DIALOG — elegant upsell card
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumDialog extends StatefulWidget {
  final VoidCallback onUpgrade;
  final VoidCallback onDismiss;

  const _PremiumDialog({required this.onUpgrade, required this.onDismiss});

  @override
  State<_PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<_PremiumDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Background gradient ──────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A0020), // deep plum
                      Color(0xFF6B0033), // dark crimson
                      Color(0xFFB8003E), // rich rose
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // ── Decorative circles ───────────────────────────────────────
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF69B4).withOpacity(0.08),
                  ),
                ),
              ),
              // ── Content ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Crown icon with glow
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.45),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.6)),
                        color: const Color(0xFFFFD700).withOpacity(0.08),
                      ),
                      child: Text(
                        s.premiumDialogBadge,
                        style: GoogleFonts.raleway(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFD700),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Headline
                    Text(
                      s.premiumDialogHeadline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      s.premiumDialogSub,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway(
                        fontSize: 12.5,
                        color: Colors.white60,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Benefits
                    _benefit(s.premiumBenefit1),
                    const SizedBox(height: 8),
                    _benefit(s.premiumBenefit2),
                    const SizedBox(height: 8),
                    _benefit(s.premiumBenefit3),
                    const SizedBox(height: 28),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onUpgrade,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            s.premiumDialogCta,
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A0020),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Decline link
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Text(
                        s.premiumDialogDecline,
                        style: GoogleFonts.raleway(
                          fontSize: 12,
                          color: Colors.white38,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefit(String text) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0x22FFD700),
          ),
          child: const Icon(Icons.check_rounded,
              size: 13, color: Color(0xFFFFD700)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.raleway(
              fontSize: 12.5,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
