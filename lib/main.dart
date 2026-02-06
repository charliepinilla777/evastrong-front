import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/logo_3d_service.dart';
import 'services/payment_service.dart';
import 'config/app_config.dart';
import 'theme/eva_colors.dart';
import 'screens/user_profile_screen.dart';
import 'screens/routines_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/test_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/achievements_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/access_control_service.dart';
import 'widgets/protected_screen.dart';
import 'widgets/eva_3d_model_widget.dart';
import 'screens/admin_dashboard_screen.dart';

void main() {
  runApp(const EvaStrongApp());
}

class EvaStrongApp extends StatelessWidget {
  const EvaStrongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eva Strong',
      debugShowCheckedModeBanner: false,
      theme: EvaColors.lightTheme,
      darkTheme: EvaColors.darkTheme,
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
        '/admin-dashboard': (context) => ProtectedScreen(
          screenName: 'Admin Dashboard',
          requireAdmin: true,
          child: const AdminLoginScreen(),
        ),
        '/dashboard': (context) => ProtectedScreen(
          screenName: 'Dashboard',
          requireAdmin: true,
          child: const AdminDashboardScreen(),
        ),
        '/role-management': (context) => ProtectedScreen(
          screenName: 'Role Management',
          requireAdmin: true,
          child: const AdminLoginScreen(),
        ),
        '/achievements': (context) => ProtectedScreen(
          screenName: 'Achievements',
          requireSubscription: true,
          child: const AchievementsScreen(),
        ),
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
  late Timer _quoteTimer;
  int _currentMotivationalQuote = 0;

  // Servicios de pago y almacenamiento
  final PaymentService _paymentService = PaymentService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Lista de frases motivacionales
  final List<String> _motivationalQuotes = [
    "💪 Tu fuerza interior es más poderosa que cualquier obstáculo",
    "🌟 Cada repetición te acerca a tu mejor versión",
    "🔥 El dolor de hoy es la fuerza del mañana",
    "⚡ No te rindas, lo mejor está por venir",
    "🏆 Los campeones se hacen cuando nadie está mirando",
    "💎 Eres más fuerte de lo que crees",
    "🎯 El éxito es la suma de pequeños esfuerzos repetidos",
    "� Transforma tu cuerpo, transforma tu vida",
    "🌈 Tu única limitación es la que tú te impones",
    "⭐ Grandes logros requieren grandes sacrificios",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Inicializar servicio de pago con token
    _initializePaymentService();

    // Iniciar timer para cambiar frases cada 10 segundos
    _quoteTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentMotivationalQuote =
            (_currentMotivationalQuote + 1) % _motivationalQuotes.length;
      });
    });
  }

  // Inicializar servicio de pago con token JWT
  Future<void> _initializePaymentService() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        setState(() {
          _paymentService.jwtToken = token;
        });
      }
    } catch (e) {
      print('Error al inicializar servicio de pago: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quoteTimer.cancel(); // Cancelar el timer
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildRoutinesTab(),
          _buildContactTab(),
          _buildTestTab(),
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
                  EvaLogo3D(size: 40, animate: true),
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
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.fitness_center,
                color: EvaColors.vibrantPink,
              ),
              title: const Text('Rutinas'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.contact_phone,
                color: EvaColors.vibrantPink,
              ),
              title: const Text('Contacto'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.emoji_events,
                color: EvaColors.vibrantPink,
              ),
              title: const Text('Logros'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/achievements');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: EvaColors.vibrantPink),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/user-profile');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: EvaColors.vibrantPink,
              ),
              title: const Text('Panel Administrativo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/admin-dashboard');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.dashboard,
                color: EvaColors.vibrantPink,
              ),
              title: const Text('Dashboard Admin'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.manage_accounts,
                color: EvaColors.vibrantPink,
              ),
              title: const Text('Gestión de Roles'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/role-management');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: EvaColors.vibrantPink),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        tabs: const [
          Tab(icon: Icon(Icons.home), text: 'Inicio'),
          Tab(icon: Icon(Icons.fitness_center), text: 'Rutinas'),
          Tab(icon: Icon(Icons.phone), text: 'Contacto'),
          Tab(icon: Icon(Icons.settings), text: 'Test'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        // Background animado con partículas
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                EvaColors.vibrantPink.withOpacity(0.05),
                EvaColors.cosmicRed.withOpacity(0.03),
                EvaColors.wellnessPurple.withOpacity(0.05),
              ],
            ),
          ),
        ),

        // Contenido principal
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Frase motivacional aleatoria
              _buildMotivationalQuoteSection(),

              const SizedBox(height: 20),

              // Espacio reservado para el modelo 3D
              const SizedBox(height: 120),

              const SizedBox(height: 30),

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
                      const Text(
                        '¡SUSCRÍBETE YA!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Cambia tu vida hoy',
                        style: TextStyle(
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

              // Modelo 3D de Eva
              SizedBox(
                width: double.infinity,
                height: 300,
                child: const Eva3DModelWidget(),
              ),

              const SizedBox(height: 20),

              // Frases motivacionales
              SizedBox(
                width: double.infinity,
                height: 140,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: EvaColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: EvaColors.vibrantPink.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 30),
                      SizedBox(height: 10),
                      Text(
                        '¡Eres más fuerte de lo que crees! 💪',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Cada paso te hace más poderosa',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Botones responsive
              SizedBox(
                height: 120,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Desktop/Tablet layout
                      return Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              'Entrenar',
                              Icons.fitness_center,
                              EvaColors.vibrantPink,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionCard(
                              'Logros',
                              Icons.emoji_events,
                              EvaColors.cosmicRed,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile layout
                      return Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              'Entrenar',
                              Icons.fitness_center,
                              EvaColors.vibrantPink,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionCard(
                              'Logros',
                              Icons.emoji_events,
                              EvaColors.cosmicRed,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Modelo 3D en esquina superior derecha
        Positioned(
          top: 20,
          right: 16,
          child: SizedBox(
            width: 80,
            height: 80,
            child: EvaLogo3DAdvanced(
              size: 80,
              animate: true,
              showGlow: true,
              showParticles: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD700), // Dorado brillante
              Color(0xFFFFA500), // Naranja dorado
              Color(0xFF8B4513), // Dorado oscuro
              color, // Color original del tema
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Sombra dorada principal
            BoxShadow(
              color: Color(0xFFFFD700).withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            // Sombra del color original
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 1,
            ),
            // Sombra de profundidad
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Color(0xFFFFD700).withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            // Efecto de brillo dorado
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.4),
                      Colors.transparent,
                      Colors.white.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Contenido
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (title == 'Logros') {
                    _tabController.animateTo(1);
                  }
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono con efecto dorado
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFFF8DC), // Lino dorado
                              Color(0xFFFFD700), // Dorado
                              Color(0xFFFFA500), // Naranja dorado
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFFD700).withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 35),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: Color(0xFF8B4513),
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
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

  Widget _buildRoutinesTab() {
    return const Center(
      child: Text(
        'Rutinas',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContactTab() {
    return const Center(
      child: Text(
        'Contacto',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTestTab() {
    return const Center(
      child: Text(
        'Test',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
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
                          _motivationalQuotes[_currentMotivationalQuote],
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
                        _motivationalQuotes.length;
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
        // Título de la sección
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [EvaColors.vibrantPink, EvaColors.cosmicRed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: EvaColors.vibrantPink.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.diamond, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              const Text(
                'PLANES PREMIUM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Planes de suscripción
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop layout - 3 columnas
              return Row(
                children: [
                  Expanded(
                    child: _buildPlanCard('Básico', '9.99', '🌟', false),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPlanCard('Premium', '19.99', '💎', true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPlanCard('Elite', '29.99', '👑', false),
                  ),
                ],
              );
            } else {
              // Mobile layout - 1 columna
              return Column(
                children: [
                  _buildPlanCard('Básico', '9.99', '🌟', false),
                  const SizedBox(height: 16),
                  _buildPlanCard('Premium', '19.99', '💎', true),
                  const SizedBox(height: 16),
                  _buildPlanCard('Elite', '29.99', '👑', false),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 20),

        // Botón de test de conexión
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4CAF50), // Verde
                Color(0xFF45A049), // Verde oscuro
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF4CAF50).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _testBackendConnection,
            icon: const Icon(Icons.bug_report, color: Colors.white),
            label: Text(
              '🔍 Test Conexión Backend',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Métodos de pago
        _buildPaymentMethodsSection(),
      ],
    );
  }

  Widget _buildPlanCard(
    String title,
    String price,
    String emoji,
    bool isPopular,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPopular
            ? LinearGradient(
                colors: [
                  Color(0xFFFFD700), // Dorado brillante
                  Color(0xFFFFA500), // Naranja dorado
                  Color(0xFF8B4513), // Dorado oscuro
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              )
            : title == 'Elite'
            ? LinearGradient(
                colors: [
                  Color(0xFF4A148C), // Púrpura profundo
                  Color(0xFF7B1FA2), // Púrpura medio
                  Color(0xFF9C27B0), // Púrpura brillante
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              )
            : LinearGradient(
                colors: [
                  Color(0xFFE3F2FD), // Azul muy claro
                  Color(0xFFFFFFFF), // Blanco
                  Color(0xFFF3E5F5), // Rosa muy claro
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Sombra dorada para el plan popular
          if (isPopular)
            BoxShadow(
              color: Color(0xFFFFD700).withOpacity(0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          // Sombra púrpura para Elite
          if (title == 'Elite')
            BoxShadow(
              color: Color(0xFF9C27B0).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          // Sombra azul para Básico
          if (title == 'Básico')
            BoxShadow(
              color: Color(0xFF2196F3).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          // Sombra general
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isPopular
              ? Color(0xFFFFD700) // Dorado
              : title == 'Elite'
              ? Color(0xFF9C27B0) // Púrpura
              : Color(0xFF2196F3), // Azul
          width: isPopular ? 3 : 2,
        ),
      ),
      child: Stack(
        children: [
          // Efecto de brillo en el plan popular
          if (isPopular)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                      Colors.white.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          if (isPopular)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B), // Rojo coral
                      Color(0xFFE91E63), // Rosa intenso
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFE91E63).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Icono del plan con efecto especial
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isPopular
                          ? [
                              Color(0xFFFFF8DC), // Lino dorado
                              Color(0xFFFFD700), // Dorado
                            ]
                          : title == 'Elite'
                          ? [
                              Color(0xFFF3E5F5), // Rosa muy claro
                              Color(0xFF9C27B0), // Púrpura
                            ]
                          : [
                              Color(0xFFE3F2FD), // Azul muy claro
                              Color(0xFF2196F3), // Azul
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isPopular
                            ? Color(0xFFFFD700).withOpacity(0.5)
                            : title == 'Elite'
                            ? Color(0xFF9C27B0).withOpacity(0.4)
                            : Color(0xFF2196F3).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 36)),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isPopular
                        ? Color(0xFF8B4513) // Dorado oscuro
                        : title == 'Elite'
                        ? Colors.white
                        : Color(0xFF1565C0), // Azul oscuro
                    shadows: isPopular
                        ? [
                            Shadow(
                              color: Color(0xFFFFD700),
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ]
                        : null,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPopular
                          ? [Color(0xFFFFF8DC), Color(0xFFFFD700)]
                          : title == 'Elite'
                          ? [Color(0xFFF3E5F5), Color(0xFF9C27B0)]
                          : [Color(0xFFE3F2FD), Color(0xFF2196F3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPopular
                          ? Color(0xFFFFD700)
                          : title == 'Elite'
                          ? Color(0xFF9C27B0)
                          : Color(0xFF2196F3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '\$$price/mes',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isPopular
                          ? Color(0xFF8B4513) // Dorado oscuro
                          : title == 'Elite'
                          ? Colors.white
                          : Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPlanFeatures(title, isPopular),
                const SizedBox(height: 20),
                // Botón mejorado
                Container(
                  decoration: BoxDecoration(
                    gradient: isPopular
                        ? LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF), // Blanco
                              Color(0xFFFFF8DC), // Lino dorado
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Color(0xFF4CAF50), // Verde
                              Color(0xFF45A049), // Verde oscuro
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: isPopular
                            ? Color(0xFFFFD700).withOpacity(0.5)
                            : Color(0xFF4CAF50).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: isPopular ? Color(0xFFFFD700) : Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () => _processPayment(title, price),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: isPopular
                          ? Color(0xFF8B4513) // Dorado oscuro
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Suscribirse',
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.8,
                        shadows: isPopular
                            ? [
                                Shadow(
                                  color: Color(0xFFFFD700),
                                  blurRadius: 1,
                                  offset: Offset(1, 1),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanFeatures(String plan, bool isPopular) {
    final features = {
      'Básico': [
        '✓ 10 rutinas básicas',
        '✓ Seguimiento de progreso',
        '✓ Logros básicos',
        '✗ Sin personalización',
      ],
      'Premium': [
        '✓ Rutinas ilimitadas',
        '✓ Personalización completa',
        '✓ Análisis avanzado',
        '✓ Soporte prioritario',
      ],
      'Elite': [
        '✓ Todo lo de Premium',
        '✓ Coach personal',
        '✓ Plan nutricional',
        '✓ Video llamadas',
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (features[plan] ?? []).map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            feature,
            style: TextStyle(
              fontSize: 12,
              color: isPopular ? Colors.white : Colors.grey.shade700,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFD700), // Dorado brillante
            Color(0xFFFFA500), // Naranja dorado
            Color(0xFF8B4513), // Dorado oscuro
            Color(0xFF424242), // Gris oscuro
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Sombra dorada principal
          BoxShadow(
            color: Color(0xFFFFD700).withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          // Sombra gris intensa
          BoxShadow(
            color: Color(0xFF424242).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          // Sombra de profundidad
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Color(0xFFFFD700).withOpacity(0.6), width: 2),
      ),
      child: Stack(
        children: [
          // Efecto de brillo dorado premium
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
            top: 15,
            left: 20,
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
            top: 10,
            right: 25,
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
            left: 30,
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
            right: 20,
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
              // Icono de seguridad dorado
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
                  Icons.security,
                  color: Color(0xFF8B4513),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // Título con efecto dorado
              Text(
                'Métodos de Pago Seguros',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.8,
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
              ),
              const SizedBox(height: 20),
              // Métodos de pago
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethod(
                      'PayPal',
                      'assets/icons/paypal.png',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethod(
                      'MercadoPago',
                      'assets/icons/mercadopago.png',
                      Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentMethod(
                      'Tarjeta',
                      'assets/icons/credit-card.png',
                      Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Mensaje de seguridad
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '🔒 Pagos 100% seguros y encriptados',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Color(0xFF8B4513),
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String name, String assetPath, Color color) {
    // Como no tenemos los assets, usaremos iconos y colores
    IconData icon;
    switch (name) {
      case 'PayPal':
        icon = Icons.account_balance_wallet;
        break;
      case 'MercadoPago':
        icon = Icons.payment;
        break;
      case 'Tarjeta':
        icon = Icons.credit_card;
        break;
      default:
        icon = Icons.payment;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFF8DC), // Lino dorado
            Color(0xFFFFD700), // Dorado brillante
            Color(0xFFFFA500), // Naranja dorado
            color.withOpacity(0.8), // Color del método
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Sombra dorada principal
          BoxShadow(
            color: Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
          // Sombra del color del método
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          // Sombra de profundidad
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Color(0xFFFFD700).withOpacity(0.6), width: 2),
      ),
      child: Stack(
        children: [
          // Efecto de brillo dorado
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
          // Partícula dorada decorativa
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD700).withOpacity(0.6),
                boxShadow: [BoxShadow(color: Color(0xFFFFD700), blurRadius: 3)],
              ),
            ),
          ),
          // Contenido
          Column(
            children: [
              // Icono con efecto dorado
              Container(
                padding: const EdgeInsets.all(12),
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
                      color: Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Color(0xFF8B4513),
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
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

// Fresh deployment 02/05/2026 21:09:03
