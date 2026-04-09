// EvaStrong — Flutter App
// Copyright (c) 2024-2025 Carlos Pinilla. All Rights Reserved.
// Unauthorized copying, modification or distribution is strictly prohibited.
// See LICENSE file for full terms.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:animations/animations.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:particles_fly/particles_fly.dart';
import 'package:provider/provider.dart';
import 'services/cache_service.dart';
import 'utils/page_transitions.dart';
import 'services/payment_service.dart';
import 'config/app_config.dart';
import 'theme/eva_colors.dart';
import 'screens/user_profile_screen.dart';
import 'screens/routines_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/test_screen.dart';
import 'screens/achievements_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/access_control_service.dart';
import 'widgets/protected_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/diet_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/language_provider.dart';
import 'providers/backend_status_provider.dart';
import 'l10n/app_strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-carga SharedPreferences para que CacheService no tenga latencia en el primer uso
  await CacheService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => BackendStatusProvider()),
      ],
      child: const EvaStrongApp(),
    ),
  );
}

class EvaStrongApp extends StatelessWidget {
  const EvaStrongApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageProvider>().locale;
    return MaterialApp(
      title: 'Eva Strong',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: EvaColors.lightTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: EvaColors.darkTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(title: 'Eva Strong'),
      routes: {
        '/user-profile': (context) => ProtectedScreen(
          screenName: 'Profile',
          requireSubscription: true,
          child: const UserProfileScreen(),
        ),
        '/routines': (context) => ProtectedScreen(
          screenName: 'Routines',
          requireSubscription: true,
          child: const RoutinesScreen(),
        ),
        '/contact': (context) => const ContactScreen(),
        '/test': (context) => const TestScreen(),
        '/achievements': (context) => ProtectedScreen(
          screenName: 'Achievements',
          requireSubscription: true,
          child: const AchievementsScreen(),
        ),
        '/chat': (context) => ProtectedScreen(
          screenName: 'Chat',
          requireSubscription: true,
          child: const ChatListScreen(),
        ),
        '/feedback': (context) => const FeedbackScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Servicios de pago y almacenamiento
  final PaymentService _paymentService = PaymentService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Frases motivacionales rotativas
  // Quotes are served from AppStrings.of(context).dailyQuotes (bilingual)
  int _currentMotivationalQuote = 0;

  // Carrusel de imágenes motivacionales
  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  // Carousel image paths — texts are served from AppStrings.of(context).carouselTexts
  static const List<String> _carouselImages = [
    'assets/images/carousel1.jpg',
    'assets/images/carousel2.jpg',
    'assets/images/carousel3.jpg',
    'assets/images/carousel4.jpg',
    'assets/images/carousel5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carouselController = PageController(viewportFraction: 1.0);
    _initializePaymentService();
    _startCarouselAutoPlay();
    // Arranca el warmup del backend con seguimiento de estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BackendStatusProvider>().warmup();
    });
  }

  void _startCarouselAutoPlay() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) return false;
      final next = (_currentCarouselIndex + 1) % _carouselImages.length;
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
      return true;
    });
  }

  // Inicializar servicio de pago con token JWT
  Future<void> _initializePaymentService() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null && mounted) {
        setState(() => _paymentService.jwtToken = token);
      }
    } catch (e) {
      debugPrint('Error al inicializar servicio de pago: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: EvaColors.vibrantPink,
        elevation: 8,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          _buildBackendBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(),
                _buildRoutinesTab(),
                _buildDietTab(),
                _buildContactTab(),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(gradient: EvaColors.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fitness_center, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'Eva Strong',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Tu transformación empieza aquí',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: EvaColors.vibrantPink),
              title: Text(AppStrings.of(context).home),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.fitness_center,
                color: EvaColors.vibrantPink,
              ),
              title: Text(AppStrings.of(context).routines),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.restaurant_menu,
                color: EvaColors.vibrantPink,
              ),
              title: Text(AppStrings.of(context).diets),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.contact_phone,
                color: EvaColors.vibrantPink,
              ),
              title: Text(AppStrings.of(context).contact),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(3);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.emoji_events,
                color: EvaColors.vibrantPink,
              ),
              title: Text(AppStrings.of(context).achievements),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/achievements');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.chat,
                color: EvaColors.vibrantPink,
              ),
              title: Text(AppStrings.of(context).chat),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: EvaColors.vibrantPink),
              title: Text(AppStrings.of(context).profile),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user-profile');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: EvaColors.vibrantPink,
              ),
              title: Text(AppStrings.of(context).feedback),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/feedback');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: EvaColors.vibrantPink),
              title: Text(AppStrings.of(context).settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBackendBanner() {
    return Consumer<BackendStatusProvider>(
      builder: (context, backend, _) {
        if (!backend.isVisible) return const SizedBox.shrink();

        final isOffline = backend.status == BackendStatus.offline;
        final color = isOffline
            ? Colors.red.shade700.withOpacity(0.92)
            : Colors.deepPurple.shade700.withOpacity(0.92);
        final icon = isOffline ? Icons.wifi_off_rounded : Icons.cloud_sync_rounded;
        final message = isOffline
            ? '😔 Sin conexión al servidor. Mostrando datos guardados.'
            : '☕ Despertando el servidor, un momento...';

        return AnimatedSlide(
          offset: backend.isVisible ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: backend.isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 350),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: color,
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!isOffline)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: EvaColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: EvaColors.textOnVibrant,
        labelColor: EvaColors.textOnVibrant,
        unselectedLabelColor: EvaColors.textOnVibrant.withOpacity(0.7),
        tabs: [
          Tab(icon: const Icon(Icons.home), text: AppStrings.of(context).tabHome),
          Tab(icon: const Icon(Icons.fitness_center), text: AppStrings.of(context).tabRoutines),
          Tab(icon: const Icon(Icons.restaurant_menu), text: AppStrings.of(context).tabDiets),
          Tab(icon: const Icon(Icons.phone), text: AppStrings.of(context).tabContact),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Partículas de fondo en toda la pantalla
            Positioned.fill(
              child: ParticlesFly(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                connectDots: false,
                numberOfParticles: 25,
                speedOfParticles: 0.8,
                lineColor: EvaColors.vibrantPink.withOpacity(0.2),
                particleColor: Colors.white.withOpacity(0.7),
                awayRadius: 180,
                onTapAnimation: true,
                isRandSize: true,
                isRandomColor: false,
                randColorList: [
                  EvaColors.vibrantPink.withOpacity(0.5),
                  Colors.white.withOpacity(0.7),
                  EvaColors.cosmicRed.withOpacity(0.4),
                ],
              ),
            ),
            // Background animado con gradiente
            AnimateGradient(
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

            // Contenido principal
            SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo animado Eva Strong
              _buildAnimatedLogo(),

              const SizedBox(height: 30),

              // Carrusel de fotos motivacionales (widget independiente — su timer no hace rebuild del padre)
              const _AutoCarousel(),

              const SizedBox(height: 32),

              // ── Descripción de la app ──────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                    ),
                    child: Column(
                      children: [
                        // Línea decorativa superior
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 40, height: 1, color: Colors.white.withOpacity(0.4)),
                            const SizedBox(width: 10),
                            Icon(Icons.self_improvement_rounded, color: Colors.white.withOpacity(0.7), size: 18),
                            const SizedBox(width: 10),
                            Container(width: 40, height: 1, color: Colors.white.withOpacity(0.4)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.of(context).aboutAppTagline,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.7,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          AppStrings.of(context).aboutAppNutrition,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.88),
                            height: 1.75,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.of(context).aboutAppRoutines,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.88),
                            height: 1.75,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.of(context).aboutAppLifestyle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withOpacity(0.92),
                            height: 1.75,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Línea decorativa inferior
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 40, height: 1, color: Colors.white.withOpacity(0.4)),
                            const SizedBox(width: 10),
                            Icon(Icons.favorite_rounded, color: Colors.white.withOpacity(0.7), size: 14),
                            const SizedBox(width: 10),
                            Container(width: 40, height: 1, color: Colors.white.withOpacity(0.4)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Galería de fotos y videos
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: _buildMediaGallery(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Banner de suscripción
              SizedBox(
                width: double.infinity,
                height: 140,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        EvaColors.cosmicRed,
                        EvaColors.vibrantPink,
                        EvaColors.wellnessPurple,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: EvaColors.cosmicRed.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 30),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.of(context).subscribeTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        AppStrings.of(context).subscribeSubtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Sección de Planes y Métodos de Pago
              _buildSubscriptionPlansSection(),

              const SizedBox(height: 30),

              // Acciones rápidas
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      'train',
                      Icons.fitness_center,
                      EvaColors.vibrantPink,
                      EvaColors.wellnessPurple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionCard(
                      'achievements',
                      Icons.emoji_events,
                      EvaColors.cosmicRed,
                      EvaColors.vibrantPink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

          ],
        );
      },
    );
  }

  Widget _buildActionCard(String key, IconData icon, Color colorFrom, Color colorTo) {
    final s = AppStrings.of(context);
    final title = key == 'train' ? s.actionTrain : s.actionAchievements;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorFrom.withOpacity(0.75),
                colorTo.withOpacity(0.55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorFrom.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (key == 'train') {
                  _tabController.animateTo(1);
                } else if (key == 'achievements') {
                  Navigator.pushNamed(context, '/achievements');
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
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

  Widget _buildRoutinesTab() {
    return const RoutinesScreen();
  }

  Widget _buildDietTab() {
    return const DietScreen();
  }

  Widget _buildContactTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimateGradient(
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
          child: Stack(
            children: [
              // Partículas igual que home
              Positioned.fill(
                child: ParticlesFly(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  connectDots: false,
                  numberOfParticles: 25,
                  speedOfParticles: 0.8,
                  lineColor: EvaColors.vibrantPink.withOpacity(0.2),
                  particleColor: Colors.white.withOpacity(0.7),
                  awayRadius: 180,
                  onTapAnimation: true,
                  isRandSize: true,
                  isRandomColor: false,
                  randColorList: [
                    EvaColors.vibrantPink.withOpacity(0.5),
                    Colors.white.withOpacity(0.7),
                    EvaColors.cosmicRed.withOpacity(0.4),
                  ],
                ),
              ),
              // Contenido
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Logo
                    _buildAnimatedLogo(),
                    const SizedBox(height: 10),
                    // Subtítulo
                    Text(
                      AppStrings.of(context).contactSubtitle,
                      style: GoogleFonts.raleway(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Redes sociales ──────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Síguenos en:',
                                style: GoogleFonts.cormorantGaramond(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildAnimatedSocialButton(
                                icon: Icons.camera_alt_rounded,
                                label: 'Instagram',
                                subtitle: AppStrings.of(context).instagramSubtitle,
                                primaryColors: const [Color(0xFF833AB4), Color(0xFFE1306C)],
                                secondaryColors: const [Color(0xFFE1306C), Color(0xFFF77737)],
                                onTap: () => _launchContactURL('https://www.instagram.com/evastrong'),
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedSocialButton(
                                icon: Icons.facebook,
                                label: 'Facebook',
                                subtitle: AppStrings.of(context).facebookSubtitle,
                                primaryColors: const [Color(0xFF1877F2), Color(0xFF0D6EFD)],
                                secondaryColors: const [Color(0xFF0C5FCD), Color(0xFF1877F2)],
                                onTap: () => _launchContactURL('https://www.facebook.com/evastrong'),
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedSocialButton(
                                icon: Icons.push_pin_rounded,
                                label: 'Pinterest',
                                subtitle: AppStrings.of(context).pinterestSubtitle,
                                primaryColors: const [Color(0xFFE60023), Color(0xFFAD081B)],
                                secondaryColors: const [Color(0xFFAD081B), Color(0xFF8B0000)],
                                onTap: () => _launchContactURL('https://www.pinterest.com/evastrong'),
                              ),
                              const SizedBox(height: 12),
                              _buildAnimatedSocialButton(
                                icon: Icons.mail_rounded,
                                label: AppStrings.of(context).emailLabel,
                                subtitle: AppStrings.of(context).emailSubtitle,
                                primaryColors: const [EvaColors.cosmicRed, EvaColors.vibrantPink],
                                secondaryColors: const [EvaColors.vibrantPink, EvaColors.wellnessPurple],
                                onTap: () => _launchContactURL('mailto:soporte@evastrong.app'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Información de contacto ─────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Información de contacto',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => _launchContactURL('mailto:soporte@evastrong.app'),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.email, color: EvaColors.vibrantPink, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'soporte@evastrong.app',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 15,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.white54,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () => _launchContactURL('https://maps.google.com/?q=Bogota,Colombia'),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, color: EvaColors.vibrantPink, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Bogotá, Colombia',
                                          style: GoogleFonts.montserrat(
                                            color: Colors.white,
                                            fontSize: 15,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.white54,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.open_in_new, color: Colors.white54, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSocialButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> primaryColors,
    required List<Color> secondaryColors,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 76,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimateGradient(
                primaryColors: primaryColors,
                secondaryColors: secondaryColors,
                duration: const Duration(seconds: 3),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.white.withOpacity(0.15),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: GoogleFonts.raleway(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: GoogleFonts.raleway(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 11,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchContactURL(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('No se pudo abrir la URL: $url — $e');
    }
  }

  Widget _buildTestTab() {
    return const Center(
      child: Text(
        'Test',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo "EVA STRONG" estilo pantalla restringida — shaders blancos
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EVA',
                  style: GoogleFonts.greatVibes(
                    fontSize: 84,
                    fontWeight: FontWeight.w700,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFD6EC)],
                      ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'STRONG',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [Colors.white, Color(0xFFE8B4FF)],
                      ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Línea decorativa
          Container(
            width: 140,
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0),
                  Colors.white.withOpacity(0.8),
                  Colors.white.withOpacity(0),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Frase principal — aparece desde el fondo con fade
          // SizedBox con altura fija para que no muevan los elementos de abajo
          SizedBox(
            width: double.infinity,
            height: 100,
            child: AnimatedTextKit(
              repeatForever: true,
              pause: const Duration(milliseconds: 4000),
              animatedTexts: [
                FadeAnimatedText(
                  AppStrings.of(context).homeTagline,
                  textAlign: TextAlign.center,
                  duration: const Duration(milliseconds: 5000),
                  fadeOutBegin: 0.85,
                  fadeInEnd: 0.25,
                  textStyle: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.6,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Datos de ejemplo — reemplazar con URLs reales cuando estén disponibles
  List<Map<String, String>> get _galleryPhotos {
    final s = AppStrings.of(context);
    return [
      {'url': 'assets/images/carousel/slide_1.jpg', 'caption': s.photoStrengthCaption},
      {'url': 'assets/images/carousel/slide_2.jpg', 'caption': s.photoCardioCaption},
      {'url': 'assets/images/carousel/slide_3.jpg', 'caption': s.photoYogaCaption},
      {'url': 'assets/images/carousel/slide_4.jpg', 'caption': s.photoToningCaption},
      {'url': 'assets/images/carousel/slide_5.jpg', 'caption': s.photoResultsCaption},
    ];
  }

  List<Map<String, String>> get _galleryVideos {
    final s = AppStrings.of(context);
    return [
      {
        'url': '',
        'thumbnail': 'assets/images/carousel/slide_1.jpg',
        'title': s.videoGlutesTitle,
        'subtitle': s.videoGlutesSubtitle,
      },
      {
        'url': '',
        'thumbnail': 'assets/images/carousel/slide_3.jpg',
        'title': s.videoCardioTitle,
        'subtitle': s.videoCardioSubtitle,
      },
    ];
  }

  void _openImageGallery(BuildContext ctx, List<String> urls, int initialIndex) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => _FullScreenGallery(urls: urls, initialIndex: initialIndex),
    ));
  }

  Widget _buildMediaGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de sección
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [EvaColors.vibrantPink, EvaColors.wellnessPurple],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.of(context).mediaTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                if (_galleryPhotos.isNotEmpty) {
                  _openImageGallery(context, _galleryPhotos.map((p) => p['url']!).toList(), 0);
                }
              },
              child: Text(
                AppStrings.of(context).mediaViewAll,
                style: TextStyle(
                  fontSize: 13,
                  color: EvaColors.vibrantPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Fila de fotos en miniatura
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _galleryPhotos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final photo = _galleryPhotos[index];
              return GestureDetector(
                onTap: () {
                  _openImageGallery(context, _galleryPhotos.map((p) => p['url']!).toList(), index);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.asset(
                        photo['url']!,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                EvaColors.vibrantPink.withOpacity(0.6),
                                EvaColors.wellnessPurple.withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.photo, color: Colors.white54, size: 36),
                        ),
                      ),
                      // Overlay con número
                      if (index == _galleryPhotos.length - 1)
                        Container(
                          width: 110,
                          height: 110,
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                            child: Text(
                              '+${_galleryPhotos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        // Encabezado videos
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [EvaColors.wellnessPurple, EvaColors.vibrantPink],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.of(context).mediaFeaturedVideos,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Video en miniatura
        ..._galleryVideos.map((video) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTap: () {
              final url = video['url']!.isEmpty
                  ? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
                  : video['url']!;
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: EvaColors.primaryGradient,
                border: Border.all(
                  color: EvaColors.vibrantPink.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: EvaColors.vibrantPink.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (video['thumbnail'] != null && video['thumbnail']!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: video['thumbnail']!.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: video['thumbnail']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorWidget: (_, __, ___) => const SizedBox(),
                            )
                          : Image.asset(
                              video['thumbnail']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                    ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      video['title'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPhotoCarousel() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _carouselController,
              itemCount: _carouselImages.length,
              onPageChanged: (index) {
                setState(() => _currentCarouselIndex = index);
              },
              itemBuilder: (context, index) {
                final imageAsset = _carouselImages[index];
                final slideText = AppStrings.of(context).carouselTexts[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen con fallback a degradado
                    Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                [Colors.purple, Colors.pink],
                                [Colors.pink, Colors.orange],
                                [Colors.orange, Colors.red],
                                [Colors.teal, Colors.purple],
                                [Colors.indigo, Colors.pink],
                              ][index],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        );
                      },
                    ),
                    // Overlay oscuro
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.55),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Texto motivacional
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Text(
                        slideText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Dots de paginación
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _carouselImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentCarouselIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentCarouselIndex == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalQuoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFD700), // Dorado brillante
            Color(0xFFFFA500), // Naranja dorado
            Color(0xFF8B4513), // Dorado oscuro
            Color(0xFFE91E63), // Rosa intenso
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Sombra dorada principal
          BoxShadow(
            color: Color(0xFFFFD700).withOpacity(0.6),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 3,
          ),
          // Sombra rosa intensa
          BoxShadow(
            color: Color(0xFFE91E63).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
          // Sombra de profundidad
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Color(0xFFFFD700).withOpacity(0.6), width: 3),
      ),
      child: Stack(
        children: [
          // Efecto de brillo dorado premium
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                    Color(0xFFFFD700).withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // Partículas doradas decorativas
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD700).withOpacity(0.6),
                boxShadow: [BoxShadow(color: Color(0xFFFFD700), blurRadius: 4)],
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 20,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFA500).withOpacity(0.5),
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 25,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD700).withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 15,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFA500).withOpacity(0.6),
              ),
            ),
          ),
          // Contenido principal
          Column(
            children: [
              // Icono de inspiración premium
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFF8DC), // Lino dorado
                      Color(0xFFFFD700), // Dorado brillante
                      Color(0xFFFFA500), // Naranja dorado
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFFD700).withOpacity(0.6),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Color(0xFF8B4513).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Color(0xFFFFD700).withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF8B4513),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // Frase motivacional
              GestureDetector(
                onTap: () => _processPayment('Premium', '19.99'),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.transparent,
                        Colors.white.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.of(context).dailyQuotes[_currentMotivationalQuote % AppStrings.of(context).dailyQuotes.length],
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            height: 1.4,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Color(0xFF8B4513),
                                blurRadius: 3,
                                offset: Offset(2, 2),
                              ),
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 2,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Icono de toque dorado
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFF8DC), Color(0xFFFFD700)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFD700).withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.touch_app,
                          color: Color(0xFF8B4513),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botón para cambiar frase
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentMotivationalQuote =
                        (_currentMotivationalQuote + 1) %
                        AppStrings.of(context).dailyQuotes.length;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF), // Blanco
                        Color(0xFFFFF8DC), // Lino dorado
                        Color(0xFFFFD700), // Dorado
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFFD700).withOpacity(0.6),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Color(0xFF8B4513).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Color(0xFFFFD700), width: 2),
                  ),
                  child: Text(
                    '🔄 Siguiente frase',
                    style: GoogleFonts.playfairDisplay(
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.8,
                      shadows: [
                        Shadow(
                          color: Color(0xFFFFD700),
                          blurRadius: 1,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlansSection() {
    return Column(
      children: [
        // ── Título elegante ──
        Column(
          children: [
            Text(
              AppStrings.of(context).plansTitle,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.of(context).plansSubtitle,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 60,
              height: 2,
              decoration: BoxDecoration(
                gradient: EvaColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // ── Tarjetas ──
        _buildPlanCard('basic', '9.99', false),
        const SizedBox(height: 20),
        _buildPlanCard('premium', '19.99', true),
        const SizedBox(height: 20),
        _buildPlanCard('elite', '29.99', false),
      ],
    );
  }

  // ── Datos de cada plan ──────────────────────────────────────────────────
  Map<String, Map<String, dynamic>> get _planConfig {
    final s = AppStrings.of(context);
    return {
      'basic': {
        'name':        s.planBasicName,
        'emoji':       '🌸',
        'tagline':     s.planBasicTagline,
        'description': s.planBasicDescription,
        'quote':       s.planBasicQuote,
        'hook':        s.planBasicHook,
        'features':    s.planBasicFeatures,
      },
      'premium': {
        'name':        s.planPremiumName,
        'emoji':       '💎',
        'tagline':     s.planPremiumTagline,
        'description': s.planPremiumDescription,
        'quote':       s.planPremiumQuote,
        'hook':        s.planPremiumHook,
        'features':    s.planPremiumFeatures,
      },
      'elite': {
        'name':        s.planEliteName,
        'emoji':       '👑',
        'tagline':     s.planEliteTagline,
        'description': s.planEliteDescription,
        'quote':       s.planEliteQuote,
        'hook':        s.planEliteHook,
        'features':    s.planEliteFeatures,
      },
    };
  }

  Widget _buildPlanCard(String key, String price, bool isPopular) {
    final s       = AppStrings.of(context);
    final config   = _planConfig[key]!;
    final name     = config['name']        as String;
    final emoji    = config['emoji']       as String;
    final tagline  = config['tagline']     as String;
    final desc     = config['description'] as String;
    final quote    = config['quote']       as String;
    final hook     = config['hook']        as String;
    final features = config['features']   as List<String>;
    final title    = key;

    // Colores por plan
    final Color accent = title == 'Elite'
        ? EvaColors.wellnessPurple
        : isPopular
            ? EvaColors.cosmicRed
            : EvaColors.vibrantPink;
    final Color accentDark = title == 'Elite'
        ? const Color(0xFF4A0050)
        : isPopular
            ? EvaColors.wellnessPurple
            : EvaColors.darkPink;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isPopular ? 0.16 : 0.11),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withOpacity(isPopular ? 0.85 : 0.5),
          width: isPopular ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isPopular ? 0.35 : 0.2),
            blurRadius: isPopular ? 20 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Barra superior de acento ──
            Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accentDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Cabecera: icono + badge POPULAR ──
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [accent.withOpacity(0.3), accentDark.withOpacity(0.5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: accent.withOpacity(0.5)),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const Spacer(),
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [EvaColors.vibrantPink, EvaColors.cosmicRed],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: EvaColors.cosmicRed.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            s.planMostPopular,
                            style: GoogleFonts.raleway(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Nombre del plan ──
                  Text(
                    'Plan $name',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  // ── Tagline ──
                  Text(
                    '— $tagline',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Descripción breve ──
                  Text(
                    desc,
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: Colors.white60,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Cita de marketing ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      quote,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Precio ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$$price',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          s.planUsdPerMonth,
                          style: GoogleFonts.raleway(
                            fontSize: 13,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Features ──
                  ...features.map((f) => _buildFeatureRow(f, accent, f.endsWith(':'))),
                  const SizedBox(height: 14),

                  // ── Hook final ──
                  Text(
                    hook,
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: accent,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Botón Suscribirse ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _processPayment(title, price),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: accent.withOpacity(0.5),
                      ),
                      child: Text(
                        isPopular ? s.planButtonPopular : s.planButtonDefault,
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
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

  Widget _buildFeatureRow(String text, Color accent, bool isHeader) {
    if (isHeader) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: Text(
          text,
          style: GoogleFonts.raleway(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: accent,
            letterSpacing: 0.3,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: accent.withOpacity(0.5)),
            ),
            child: Icon(Icons.check, size: 11, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.raleway(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Test de conexión con el backend
  Future<void> _testBackendConnection() async {
    try {
      print('🔍 Testeando conexión con el backend...');

      // Mostrar URL actual
      print('📍 URL del backend: ${AppConfig.backendUrl}');
      print('💳 URL de pagos: ${AppConfig.paymentsUrl}');

      // Verificar si hay token JWT
      final token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        print('✅ Token JWT encontrado: ${token.substring(0, 20)}...');
        _paymentService.jwtToken = token;
      } else {
        print('⚠️ No se encontró token JWT - usando modo demo');
      }

      // Test de conexión básica (sin autenticación)
      try {
        final response = await http
            .get(
              Uri.parse('${AppConfig.backendUrl}/health'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(Duration(seconds: 15));

        if (response.statusCode == 200) {
          print('✅ Backend respondió correctamente: ${response.body}');
        } else {
          print('⚠️ Backend respondió con código: ${response.statusCode}');
        }
      } catch (e) {
        print('⚠️ Error en conexión básica: $e');
        print('💡 Esto es normal si el backend está iniciando (Render.com)');
      }

      // Test de endpoint de pagos (con o sin token)
      try {
        final response = await http
            .post(
              Uri.parse('${AppConfig.paymentsUrl}/test'),
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'test': true}),
            )
            .timeout(Duration(seconds: 15));

        print('📊 Respuesta endpoint pagos: ${response.statusCode}');
        if (response.statusCode == 200) {
          print('✅ Endpoint de pagos funcionando');
        } else {
          print('⚠️ Endpoint de pagos: ${response.body}');
        }
      } catch (e) {
        print('⚠️ Error en endpoint de pagos: $e');
        print('💡 Esto es normal si el backend está iniciando (Render.com)');
      }

      // Mostrar resultado en UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Test completado - Revisa la consola para detalles'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('❌ Error general en test: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error en test: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Procesar pago directamente con PayPal
  Future<void> _processPayment(String planTitle, String price) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Procesando pago...'),
            ],
          ),
        ),
      );

      // Convertir nombre del plan a formato del backend
      String plan = 'basic'; // default
      if (planTitle.toLowerCase().contains('premium')) {
        plan = 'premium';
      } else if (planTitle.toLowerCase().contains('elite')) {
        plan = 'elite';
      }

      // Crear orden de PayPal
      final orderResponse = await _paymentService.createPayPalOrder(
        plan: plan,
        period: 'monthly',
      );

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      if (orderResponse['approvalUrl'] != null) {
        // Redirigir a PayPal para aprobación
        final Uri paypalUrl = Uri.parse(orderResponse['approvalUrl']);

        if (await canLaunchUrl(paypalUrl)) {
          await launchUrl(paypalUrl, mode: LaunchMode.externalApplication);

          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Redirigiendo a PayPal para completar el pago...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          throw Exception('No se puede abrir PayPal');
        }
      } else {
        throw Exception('No se recibió URL de aprobación de PayPal');
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      Navigator.of(context).pop();

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar pago: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Método para lanzar opciones de pago
  Future<void> _launchPaymentOptions() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '¡Elige tu método de pago!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Comienza tu transformación hoy mismo:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPaymentLinkButton(
                    'PayPal',
                    Icons.account_balance_wallet,
                    Colors.blue,
                    'https://www.paypal.com',
                  ),
                  _buildPaymentLinkButton(
                    'MercadoPago',
                    Icons.payment,
                    Colors.blue.shade800,
                    'https://www.mercadopago.com',
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentLinkButton(
    String name,
    IconData icon,
    Color color,
    String url,
  ) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop();
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir $name'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _FullScreenGallery({required this.urls, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.urls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          final url = widget.urls[index];
          final isNetwork = url.startsWith('http');
          return InteractiveViewer(
            child: Center(
              child: isNetwork
                  ? CachedNetworkImage(imageUrl: url, fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 80))
                  : Image.asset(url, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 80)),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _AutoCarousel — carrusel con autoplay propio
// Al tener su propio State, el timer ya NO hace rebuild del HomeScreen completo
// ══════════════════════════════════════════════════════════════════════════════

class _AutoCarousel extends StatefulWidget {
  const _AutoCarousel();

  @override
  State<_AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<_AutoCarousel> {
  final PageController _controller = PageController();
  int _current = 0;
  Timer? _timer;

  static const _slideImages = [
    'assets/images/carousel/slide_1.jpg',
    'assets/images/carousel/slide_2.jpg',
    'assets/images/carousel/slide_3.jpg',
    'assets/images/carousel/slide_4.jpg',
    'assets/images/carousel/slide_5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_current + 1) % _slideImages.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _controller,
              itemCount: _slideImages.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) {
                final autoText = AppStrings.of(context).autoCarouselTexts[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _slideImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              [Colors.purple, Colors.pink],
                              [Colors.pink, Colors.orange],
                              [Colors.orange, Colors.red],
                              [Colors.teal, Colors.purple],
                              [Colors.indigo, Colors.pink],
                            ][index],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.55),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Text(
                        autoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slideImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _current == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _current == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
