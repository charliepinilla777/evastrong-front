import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/eva_colors.dart';
import '../services/effects_3d_service.dart';
import '../services/admin_service.dart';
import '../config/app_config.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService.instance;
  AdminDashboardData? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _adminService.getDashboardData();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _dashboardData = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    _adminService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Effects3DService.appBar3D(
        title: 'Dashboard Administrativo',
        gradient: Effects3DService.primaryGradient3D,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: EvaColors.vibrantPink),
            )
          : _dashboardData == null
          ? _buildErrorState()
          : _buildDashboard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Effects3DService.card3D(
        gradient: Effects3DService.cardGradient3D,
        shadows: Effects3DService.elevatedShadow3D,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Effects3DService.icon3D(
                icon: Icons.error,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Effects3DService.text3D(
                text: 'Error al cargar datos',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                shadows: Effects3DService.bigTextShadow3D,
              ),
              const SizedBox(height: 16),
              Effects3DService.button3D(
                onPressed: _loadDashboardData,
                gradient: Effects3DService.buttonGradient3D,
                child: Effects3DService.text3D(
                  text: 'Reintentar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas rápidas
          _buildQuickStats(),
          const SizedBox(height: 24),

          // Grid de métricas principales
          Row(
            children: [
              Expanded(child: _buildUsersSection()),
              const SizedBox(width: 16),
              Expanded(child: _buildRevenueSection()),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _buildAchievementsSection()),
              const SizedBox(width: 16),
              Expanded(child: _buildSubscriptionsSection()),
            ],
          ),
          const SizedBox(height: 24),

          // Secciones largas
          _buildTrafficSection(),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _buildFeedbackSection()),
              const SizedBox(width: 16),
              Expanded(child: _buildRecentActivitySection()),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = _adminService.getQuickStats(_dashboardData!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Effects3DService.text3D(
          text: 'Resumen Rápido',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          shadows: Effects3DService.bigTextShadow3D,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildQuickStatCard(stat);
          },
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(Map<String, dynamic> stat) {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.primaryShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Effects3DService.icon3D(
                  icon: stat['icon'],
                  color: stat['color'],
                  size: 24,
                ),
                const Spacer(),
                Effects3DService.icon3D(
                  icon: stat['trend'] == 'up'
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: stat['trend'] == 'up' ? Colors.green : Colors.red,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Effects3DService.text3D(
              text: stat['value'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shadows: Effects3DService.textShadow3D,
            ),
            const SizedBox(height: 4),
            Effects3DService.text3D(
              text: stat['title'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              shadows: Effects3DService.textShadow3D,
            ),
            const SizedBox(height: 4),
            Effects3DService.text3D(
              text: stat['change'],
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              shadows: Effects3DService.textShadow3D,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersSection() {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Effects3DService.text3D(
              text: 'Usuarios',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shadows: Effects3DService.bigTextShadow3D,
            ),
            const SizedBox(height: 16),
            _buildUserStat('Total', _dashboardData!.totalUsers.toString()),
            _buildUserStat('Activos', _dashboardData!.activeUsers.toString()),
            _buildUserStat('Nuevos Hoy', '+${_dashboardData!.newUsersToday}'),
            const SizedBox(height: 16),
            Effects3DService.text3D(
              text: 'Top Usuarios',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              shadows: Effects3DService.textShadow3D,
            ),
            const SizedBox(height: 8),
            ..._dashboardData!.topUsers
                .take(3)
                .map(
                  (user) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(user.avatar, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Effects3DService.text3D(
                            text: user.name,
                            style: const TextStyle(fontSize: 12),
                            shadows: Effects3DService.textShadow3D,
                          ),
                        ),
                        Effects3DService.text3D(
                          text: '${user.performance.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 12),
                          shadows: Effects3DService.textShadow3D,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Effects3DService.text3D(
            text: label,
            style: const TextStyle(fontSize: 14),
            shadows: Effects3DService.textShadow3D,
          ),
          Effects3DService.text3D(
            text: value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            shadows: Effects3DService.textShadow3D,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSection() {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Effects3DService.text3D(
              text: 'Ventas',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shadows: Effects3DService.bigTextShadow3D,
            ),
            const SizedBox(height: 16),
            _buildRevenueStat(
              'Diarias',
              _adminService.formatCurrency(_dashboardData!.dailyRevenue),
            ),
            _buildRevenueStat(
              'Mensuales',
              _adminService.formatCurrency(_dashboardData!.monthlyRevenue),
            ),
            _buildRevenueStat(
              'Ventas Hoy',
              _dashboardData!.dailySales.toString(),
            ),
            const SizedBox(height: 16),
            Effects3DService.text3D(
              text: 'Ventas Recientes',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              shadows: Effects3DService.textShadow3D,
            ),
            const SizedBox(height: 8),
            ..._dashboardData!.recentSales
                .take(3)
                .map(
                  (sale) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Effects3DService.text3D(
                          text: sale.plan,
                          style: const TextStyle(fontSize: 12),
                          shadows: Effects3DService.textShadow3D,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Effects3DService.text3D(
                              text: sale.userId,
                              style: const TextStyle(fontSize: 10),
                              shadows: Effects3DService.textShadow3D,
                            ),
                            Effects3DService.text3D(
                              text: _adminService.formatCurrency(sale.amount),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              shadows: Effects3DService.textShadow3D,
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
    );
  }

  Widget _buildRevenueStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Effects3DService.text3D(
            text: label,
            style: const TextStyle(fontSize: 14),
            shadows: Effects3DService.textShadow3D,
          ),
          Effects3DService.text3D(
            text: value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            shadows: Effects3DService.textShadow3D,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Effects3DService.text3D(
              text: 'Logros',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shadows: Effects3DService.bigTextShadow3D,
            ),
            const SizedBox(height: 16),
            _buildAchievementStat(
              'Total',
              _dashboardData!.totalAchievements.toString(),
            ),
            _buildAchievementStat(
              'Hoy',
              '+${_dashboardData!.achievementsUnlockedToday}',
            ),
            const SizedBox(height: 16),
            Effects3DService.text3D(
              text: 'Logros Recientes',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              shadows: Effects3DService.textShadow3D,
            ),
            const SizedBox(height: 8),
            ..._dashboardData!.recentAchievements
                .take(3)
                .map(
                  (achievement) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Effects3DService.text3D(
                          text: achievement.achievement,
                          style: const TextStyle(fontSize: 12),
                          shadows: Effects3DService.textShadow3D,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Effects3DService.text3D(
                              text: achievement.userName,
                              style: const TextStyle(fontSize: 10),
                              shadows: Effects3DService.textShadow3D,
                            ),
                            Effects3DService.text3D(
                              text: achievement.time,
                              style: const TextStyle(fontSize: 10),
                              shadows: Effects3DService.textShadow3D,
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
    );
  }

  Widget _buildAchievementStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Effects3DService.text3D(
            text: label,
            style: const TextStyle(fontSize: 14),
            shadows: Effects3DService.textShadow3D,
          ),
          Effects3DService.text3D(
            text: value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            shadows: Effects3DService.textShadow3D,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsSection() {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Effects3DService.text3D(
              text: 'Suscripciones',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shadows: Effects3DService.bigTextShadow3D,
            ),
            const SizedBox(height: 16),
            _buildSubscriptionStat(
              'Activas',
              _dashboardData!.activeSubscriptions.toString(),
            ),
            _buildSubscriptionStat(
              'Expiran Mes',
              _dashboardData!.expiredThisMonth.toString(),
            ),
            const SizedBox(height: 16),
            Effects3DService.text3D(
              text: 'Por Vencer',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              shadows: Effects3DService.textShadow3D,
            ),
            const SizedBox(height: 8),
            ..._dashboardData!.expiringSubscriptions
                .take(3)
                .map(
                  (subscription) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Effects3DService.text3D(
                                text: subscription.userName,
                                style: const TextStyle(fontSize: 12),
                                shadows: Effects3DService.textShadow3D,
                              ),
                              Effects3DService.text3D(
                                text: subscription.plan,
                                style: const TextStyle(fontSize: 10),
                                shadows: Effects3DService.textShadow3D,
                              ),
                            ],
                          ),
                        ),
                        Effects3DService.button3D(
                          onPressed: () => _sendReminder(
                            subscription.userId,
                            subscription.userName,
                          ),
                          gradient: subscription.daysLeft <= 3
                              ? LinearGradient(
                                  colors: [Colors.red, Colors.orange],
                                )
                              : Effects3DService.buttonGradient3D,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Effects3DService.text3D(
                            text: '${subscription.daysLeft}d',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Effects3DService.text3D(
            text: label,
            style: const TextStyle(fontSize: 14),
            shadows: Effects3DService.textShadow3D,
          ),
          Effects3DService.text3D(
            text: value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            shadows: Effects3DService.textShadow3D,
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficSection() {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Effects3DService.text3D(
              text: 'Tráfico y Métricas',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shadows: Effects3DService.bigTextShadow3D,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTrafficStat(
                    'Usuarios Activos',
                    _dashboardData!.dailyActiveUsers.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTrafficStat(
                    'Sesiones',
                    _dashboardData!.sessionCount.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTrafficStat(
                    'Duración Promedio',
                    _adminService.formatDuration(
                      _dashboardData!.avgSessionDuration,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Effects3DService.text3D(
              text: 'Tendencia de 7 Días',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              shadows: Effects3DService.textShadow3D,
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildTrafficChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficStat(String label, String value) {
    return Column(
      children: [
        Effects3DService.text3D(
          text: value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shadows: Effects3DService.bigTextShadow3D,
        ),
        Effects3DService.text3D(
          text: label,
          style: const TextStyle(fontSize: 12),
          shadows: Effects3DService.textShadow3D,
        ),
      ],
    );
  }

  Widget _buildTrafficChart() {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.primaryShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomPaint(
          size: const Size(double.infinity, 150),
          painter: TrafficChartPainter(data: _dashboardData!.trafficTrend),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Effects3DService.text3D(
              text: 'Feedback',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shadows: Effects3DService.bigTextShadow3D,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFeedbackStat(
                    'Satisfacción',
                    '${_dashboardData!.satisfactionScore.toStringAsFixed(1)}/5.0',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeedbackStat(
                    'Pendientes',
                    _dashboardData!.pendingResponses.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Effects3DService.text3D(
              text: 'Comentarios Recientes',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              shadows: Effects3DService.textShadow3D,
            ),
            const SizedBox(height: 8),
            ..._dashboardData!.recentFeedback
                .take(3)
                .map(
                  (feedback) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Effects3DService.text3D(
                              text: feedback.userName,
                              style: const TextStyle(fontSize: 12),
                              shadows: Effects3DService.textShadow3D,
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(
                              5,
                              (index) => Effects3DService.icon3D(
                                icon: index < feedback.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 12,
                              ),
                            ),
                          ],
                        ),
                        Effects3DService.text3D(
                          text: feedback.comment,
                          style: const TextStyle(fontSize: 10),
                          shadows: Effects3DService.textShadow3D,
                        ),
                        Effects3DService.text3D(
                          text: feedback.time,
                          style: const TextStyle(fontSize: 10),
                          shadows: Effects3DService.textShadow3D,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackStat(String label, String value) {
    return Column(
      children: [
        Effects3DService.text3D(
          text: value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shadows: Effects3DService.textShadow3D,
        ),
        Effects3DService.text3D(
          text: label,
          style: const TextStyle(fontSize: 12),
          shadows: Effects3DService.textShadow3D,
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Effects3DService.card3D(
      gradient: Effects3DService.cardGradient3D,
      shadows: Effects3DService.elevatedShadow3D,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Effects3DService.text3D(
              text: 'Actividad Reciente',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shadows: Effects3DService.bigTextShadow3D,
            ),
            const SizedBox(height: 16),
            Effects3DService.button3D(
              onPressed: _loadDashboardData,
              gradient: Effects3DService.buttonGradient3D,
              child: Effects3DService.text3D(
                text: 'Actualizar Datos',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Effects3DService.button3D(
              onPressed: _testBackendConnection,
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bug_report, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Effects3DService.text3D(
                    text: 'Test Backend',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Effects3DService.text3D(
              text: 'Última actualización',
              style: const TextStyle(fontSize: 12),
              shadows: Effects3DService.textShadow3D,
            ),
            Effects3DService.text3D(
              text: DateTime.now().toString().substring(0, 19),
              style: const TextStyle(fontSize: 10),
              shadows: Effects3DService.textShadow3D,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendReminder(String userId, String userName) async {
    try {
      await _adminService.sendReminderEmail(userId, userName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Effects3DService.text3D(
              text: 'Recordatorio enviado a $userName',
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: EvaColors.vibrantPink,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar recordatorio: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _testBackendConnection() async {
    try {
      print('🔍 Testeando conexión con el backend...');
      print('📍 URL del backend: ${AppConfig.backendUrl}');

      final response = await http
          .get(Uri.parse('${AppConfig.backendUrl}/health'))
          .timeout(const Duration(seconds: 30));

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Backend conectado correctamente: ${response.body}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Backend respondió con código: ${response.statusCode}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al conectar con backend: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

class TrafficChartPainter extends CustomPainter {
  final List<TrafficData> data;

  TrafficChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = EvaColors.vibrantPink
      ..style = PaintingStyle.fill;

    final maxValue = data
        .map((d) => d.users.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final barWidth = size.width / (data.length * 2);
    final spacing = barWidth;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i].users / maxValue) * size.height * 0.8;
      final x = i * (barWidth + spacing) + spacing;
      final y = size.height - barHeight;

      // Dibujar barra con gradiente
      final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));

      final gradient = LinearGradient(
        colors: [EvaColors.vibrantPink, EvaColors.vibrantPink.withOpacity(0.6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

      paint.shader = gradient.createShader(rect);
      canvas.drawRRect(rRect, paint);

      // Dibujar etiqueta
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${data[i].users}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - textPainter.width / 2, y - 15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
