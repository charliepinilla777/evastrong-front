import 'package:flutter/material.dart';
import 'package:eva_strong/services/logo_3d_service.dart';
import 'package:eva_strong/theme/eva_colors.dart';
import 'package:eva_strong/screens/user_profile_screen.dart';
import 'package:eva_strong/screens/routines_screen.dart';
import 'package:eva_strong/screens/contact_screen.dart';
import 'package:eva_strong/screens/test_screen.dart';

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
        '/user-profile': (context) => const UserProfileScreen(),
        '/routines': (context) => const RoutinesScreen(),
        '/contact': (context) => const ContactScreen(),
        '/test': (context) => const TestScreen(),
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
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
              decoration: BoxDecoration(
                gradient: EvaColors.primaryGradient,
              ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
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
              leading: const Icon(Icons.fitness_center, color: EvaColors.vibrantPink),
              title: const Text('Rutinas'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone, color: EvaColors.vibrantPink),
              title: const Text('Contacto'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Logo 3D - Modelo Seren
          EvaLogo3DAdvanced(
            size: 120,
            animate: true,
            showGlow: true,
            showParticles: true,
          ),

          const SizedBox(height: 30),

          // Frases motivacionales
          Container(
            width: double.infinity,
            height: 140,
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Botones responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Desktop/Tablet layout
                return Row(
                  children: [
                    Expanded(child: _buildActionCard('Entrenar', Icons.fitness_center, EvaColors.vibrantPink)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildActionCard('Logros', Icons.emoji_events, EvaColors.cosmicRed)),
                  ],
                );
              } else {
                // Mobile layout
                return Column(
                  children: [
                    _buildActionCard('Entrenar', Icons.fitness_center, EvaColors.vibrantPink),
                    const SizedBox(height: 16),
                    _buildActionCard('Logros', Icons.emoji_events, EvaColors.cosmicRed),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
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
                Icon(icon, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
}
