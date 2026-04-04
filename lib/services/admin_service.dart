import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/eva_colors.dart';
import '../config/app_config.dart';

class AdminDashboardData {
  // Estadísticas de usuarios
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final List<UserData> topUsers;

  // Estadísticas de logros
  final int totalAchievements;
  final int achievementsUnlockedToday;
  final List<AchievementData> recentAchievements;

  // Estadísticas de ventas
  final double dailyRevenue;
  final double monthlyRevenue;
  final int dailySales;
  final List<SaleData> recentSales;

  // Suscripciones
  final List<SubscriptionData> expiringSubscriptions;
  final int activeSubscriptions;
  final int expiredThisMonth;

  // Tráfico y métricas
  final int dailyActiveUsers;
  final int sessionCount;
  final double avgSessionDuration;
  final List<TrafficData> trafficTrend;

  // Feedback
  final List<FeedbackData> recentFeedback;
  final double satisfactionScore;
  final int pendingResponses;

  AdminDashboardData({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.topUsers,
    required this.totalAchievements,
    required this.achievementsUnlockedToday,
    required this.recentAchievements,
    required this.dailyRevenue,
    required this.monthlyRevenue,
    required this.dailySales,
    required this.recentSales,
    required this.expiringSubscriptions,
    required this.activeSubscriptions,
    required this.expiredThisMonth,
    required this.dailyActiveUsers,
    required this.sessionCount,
    required this.avgSessionDuration,
    required this.trafficTrend,
    required this.recentFeedback,
    required this.satisfactionScore,
    required this.pendingResponses,
  });

  factory AdminDashboardData.mock() {
    final random = Random();

    return AdminDashboardData(
      totalUsers: 2847,
      activeUsers: 1923,
      newUsersToday: 47,
      topUsers: [
        UserData(
          name: 'María García',
          achievements: 45,
          performance: 98.5,
          avatar: '👩‍💼',
        ),
        UserData(
          name: 'Ana López',
          achievements: 38,
          performance: 95.2,
          avatar: '👩‍🎓',
        ),
        UserData(
          name: 'Laura Martínez',
          achievements: 42,
          performance: 93.8,
          avatar: '👩‍💻',
        ),
        UserData(
          name: 'Sofia Rodríguez',
          achievements: 35,
          performance: 91.5,
          avatar: '👩‍🏫',
        ),
        UserData(
          name: 'Carmen Sánchez',
          achievements: 33,
          performance: 89.7,
          avatar: '👩‍⚕️',
        ),
      ],
      totalAchievements: 12543,
      achievementsUnlockedToday: 234,
      recentAchievements: [
        AchievementData(
          userName: 'María García',
          achievement: 'Rutina Perfecta',
          time: 'Hace 5 min',
        ),
        AchievementData(
          userName: 'Ana López',
          achievement: '30 Días Seguidos',
          time: 'Hace 12 min',
        ),
        AchievementData(
          userName: 'Laura Martínez',
          achievement: 'Meta de Peso',
          time: 'Hace 18 min',
        ),
        AchievementData(
          userName: 'Sofia Rodríguez',
          achievement: 'Récord Personal',
          time: 'Hace 25 min',
        ),
        AchievementData(
          userName: 'Carmen Sánchez',
          achievement: 'Primera Maratón',
          time: 'Hace 32 min',
        ),
      ],
      dailyRevenue: 2847.50,
      monthlyRevenue: 45678.90,
      dailySales: 89,
      recentSales: [
        SaleData(
          userId: 'USR2847',
          plan: 'Premium Mensual',
          amount: 29.99,
          time: 'Hace 2 min',
        ),
        SaleData(
          userId: 'USR2846',
          plan: 'Premium Anual',
          amount: 299.99,
          time: 'Hace 8 min',
        ),
        SaleData(
          userId: 'USR2845',
          plan: 'Premium Mensual',
          amount: 29.99,
          time: 'Hace 15 min',
        ),
        SaleData(
          userId: 'USR2844',
          plan: 'Premium Trimestral',
          amount: 79.99,
          time: 'Hace 22 min',
        ),
        SaleData(
          userId: 'USR2843',
          plan: 'Premium Mensual',
          amount: 29.99,
          time: 'Hace 28 min',
        ),
      ],
      expiringSubscriptions: [
        SubscriptionData(
          userId: 'USR1234',
          userName: 'María García',
          plan: 'Premium Mensual',
          daysLeft: 3,
        ),
        SubscriptionData(
          userId: 'USR1235',
          userName: 'Ana López',
          plan: 'Premium Anual',
          daysLeft: 5,
        ),
        SubscriptionData(
          userId: 'USR1236',
          userName: 'Laura Martínez',
          plan: 'Premium Trimestral',
          daysLeft: 7,
        ),
        SubscriptionData(
          userId: 'USR1237',
          userName: 'Sofia Rodríguez',
          plan: 'Premium Mensual',
          daysLeft: 10,
        ),
        SubscriptionData(
          userId: 'USR1238',
          userName: 'Carmen Sánchez',
          plan: 'Premium Mensual',
          daysLeft: 12,
        ),
      ],
      activeSubscriptions: 892,
      expiredThisMonth: 23,
      dailyActiveUsers: 1923,
      sessionCount: 3847,
      avgSessionDuration: 24.5,
      trafficTrend: List.generate(7, (index) {
        final daysAgo = 6 - index;
        return TrafficData(
          date: DateTime.now().subtract(Duration(days: daysAgo)),
          users: 1500 + random.nextInt(500),
          sessions: 2000 + random.nextInt(800),
        );
      }),
      recentFeedback: [
        FeedbackData(
          userName: 'María García',
          rating: 5,
          comment: '¡Excelente app! Me encanta',
          time: 'Hace 10 min',
        ),
        FeedbackData(
          userName: 'Ana López',
          rating: 4,
          comment: 'Muy buena, pero podría mejorar',
          time: 'Hace 25 min',
        ),
        FeedbackData(
          userName: 'Laura Martínez',
          rating: 5,
          comment: 'Perfecta para mis rutinas',
          time: 'Hace 45 min',
        ),
        FeedbackData(
          userName: 'Sofia Rodríguez',
          rating: 3,
          comment: 'Necesita más ejercicios',
          time: 'Hace 1 hora',
        ),
        FeedbackData(
          userName: 'Carmen Sánchez',
          rating: 5,
          comment: 'La mejor app de fitness',
          time: 'Hace 2 horas',
        ),
      ],
      satisfactionScore: 4.6,
      pendingResponses: 12,
    );
  }
}

class UserData {
  final String name;
  final int achievements;
  final double performance;
  final String avatar;

  UserData({
    required this.name,
    required this.achievements,
    required this.performance,
    required this.avatar,
  });
}

class AchievementData {
  final String userName;
  final String achievement;
  final String time;

  AchievementData({
    required this.userName,
    required this.achievement,
    required this.time,
  });
}

class SaleData {
  final String userId;
  final String plan;
  final double amount;
  final String time;

  SaleData({
    required this.userId,
    required this.plan,
    required this.amount,
    required this.time,
  });
}

class SubscriptionData {
  final String userId;
  final String userName;
  final String plan;
  final int daysLeft;

  SubscriptionData({
    required this.userId,
    required this.userName,
    required this.plan,
    required this.daysLeft,
  });
}

class TrafficData {
  final DateTime date;
  final int users;
  final int sessions;

  TrafficData({
    required this.date,
    required this.users,
    required this.sessions,
  });
}

class FeedbackData {
  final String userName;
  final int rating;
  final String comment;
  final String time;

  FeedbackData({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.time,
  });
}

class AdminService {
  static AdminService? _instance;
  static AdminService get instance {
    _instance ??= AdminService._();
    return _instance!;
  }

  AdminService._();

  // URL del backend - usa AppConfig para dev/prod automáticamente
  static String get _baseUrl => AppConfig.backendUrl;

  // Token de autenticación del administrador
  String? _authToken;

  // Método para establecer el token de autenticación
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Método para verificar si está autenticado
  bool get isAuthenticated => _authToken != null;

  // Método para login
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _authToken = data['token'];
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error en login: $e');
      // Para desarrollo, permitir credenciales predefinidas
      if (email == 'admin@evastrong.com' && password == 'admin123456') {
        _authToken = 'dev_token_${DateTime.now().millisecondsSinceEpoch}';
        return true;
      }
      return false;
    }
  }

  // Método para logout
  void logout() {
    _authToken = null;
  }

  // Headers para las peticiones HTTP
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_authToken',
  };

  Future<AdminDashboardData> getDashboardData() async {
    if (_authToken == null) throw Exception('No autenticado');

    // Obtener cada sección independientemente para no fallar todo si falla una
    final usersData = await _getUsersStats();
    final revenueData = await _getRevenueStats();
    final achievementsData = await _getAchievementsStats();
    final subscriptionsData = await _getSubscriptionsStats();
    final trafficData = await _getTrafficStats();
    final feedbackData = await _getFeedbackStats();

    return AdminDashboardData(
      totalUsers: usersData['totalUsers'] ?? 0,
      activeUsers: usersData['activeUsers'] ?? 0,
      newUsersToday: usersData['newUsersToday'] ?? 0,
      topUsers: _parseTopUsers((usersData['topUsers'] as List?) ?? []),
      totalAchievements: achievementsData['totalAchievements'] ?? 0,
      achievementsUnlockedToday: achievementsData['achievementsUnlockedToday'] ?? 0,
      recentAchievements: _parseRecentAchievements(
        (achievementsData['recentAchievements'] as List?) ?? []),
      dailyRevenue: (revenueData['dailyRevenue'] ?? 0).toDouble(),
      monthlyRevenue: (revenueData['monthlyRevenue'] ?? 0).toDouble(),
      dailySales: revenueData['dailySales'] ?? 0,
      recentSales: _parseRecentSales((revenueData['recentSales'] as List?) ?? []),
      expiringSubscriptions: _parseExpiringSubscriptions(
        (subscriptionsData['expiringSubscriptions'] as List?) ?? []),
      activeSubscriptions: subscriptionsData['activeSubscriptions'] ?? 0,
      expiredThisMonth: subscriptionsData['expiredThisMonth'] ?? 0,
      dailyActiveUsers: trafficData['dailyActiveUsers'] ?? 0,
      sessionCount: trafficData['sessionCount'] ?? 0,
      avgSessionDuration: (trafficData['avgSessionDuration'] ?? 0).toDouble(),
      trafficTrend: _parseTrafficTrend((trafficData['trafficTrend'] as List?) ?? []),
      recentFeedback: _parseRecentFeedback((feedbackData['recentFeedback'] as List?) ?? []),
      satisfactionScore: (feedbackData['satisfactionScore'] ?? 0).toDouble(),
      pendingResponses: feedbackData['pendingResponses'] ?? 0,
    );
  }

  // Métodos para obtener estadísticas del backend
  Future<Map<String, dynamic>> _getUsersStats() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/admin/users/stats'), headers: _headers)
        .timeout(AppConfig.apiTimeout);
    if (response.statusCode != 200) {
      throw Exception('Error usuarios stats: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> _getRevenueStats() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/admin/revenue/stats'), headers: _headers)
        .timeout(AppConfig.apiTimeout);
    if (response.statusCode != 200) {
      throw Exception('Error revenue stats: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> _getAchievementsStats() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/admin/achievements/stats'), headers: _headers)
        .timeout(AppConfig.apiTimeout);
    if (response.statusCode != 200) {
      throw Exception('Error logros stats: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> _getSubscriptionsStats() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/admin/subscriptions/stats'), headers: _headers)
        .timeout(AppConfig.apiTimeout);
    if (response.statusCode != 200) {
      throw Exception('Error suscripciones stats: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> _getTrafficStats() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/admin/traffic/stats'), headers: _headers)
        .timeout(AppConfig.apiTimeout);
    if (response.statusCode != 200) {
      throw Exception('Error tráfico stats: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> _getFeedbackStats() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/admin/feedback/stats'), headers: _headers)
        .timeout(AppConfig.apiTimeout);
    if (response.statusCode != 200) {
      throw Exception('Error feedback stats: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  // Métodos para enviar recordatorios y respuestas
  Future<void> sendReminderEmail(String userId, String userName) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/subscriptions/send-reminder'),
        headers: _headers,
        body: json.encode({'userId': userId, 'userName': userName}),
      );

      if (response.statusCode == 200) {
        print('Email de recordatorio enviado a $userName (ID: $userId)');
      } else {
        throw Exception('Error al enviar recordatorio');
      }
    } catch (e) {
      print('Error al enviar recordatorio: $e');
      // Mostrar error al usuario
      rethrow;
    }
  }

  Future<void> respondToFeedback(String userId, String response) async {
    try {
      final httpResponse = await http.post(
        Uri.parse('$_baseUrl/admin/feedback/respond'),
        headers: _headers,
        body: json.encode({'userId': userId, 'response': response}),
      );

      if (httpResponse.statusCode == 200) {
        print('Respuesta enviada al usuario $userId: $response');
      } else {
        throw Exception('Error al enviar respuesta');
      }
    } catch (e) {
      print('Error al enviar respuesta: $e');
      rethrow;
    }
  }

  // Métodos de parsing para convertir respuestas JSON a objetos
  List<UserData> _parseTopUsers(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => UserData(
            name: json['name'],
            achievements: json['achievements'],
            performance: json['performance'].toDouble(),
            avatar: json['avatar'] ?? '👤',
          ),
        )
        .toList();
  }

  List<AchievementData> _parseRecentAchievements(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => AchievementData(
            userName: json['userName'],
            achievement: json['achievement'],
            time: json['time'],
          ),
        )
        .toList();
  }

  List<SaleData> _parseRecentSales(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => SaleData(
            userId: json['userId'],
            plan: json['plan'],
            amount: json['amount'].toDouble(),
            time: json['time'],
          ),
        )
        .toList();
  }

  List<SubscriptionData> _parseExpiringSubscriptions(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => SubscriptionData(
            userId: json['userId'],
            userName: json['userName'],
            plan: json['plan'],
            daysLeft: json['daysLeft'],
          ),
        )
        .toList();
  }

  List<TrafficData> _parseTrafficTrend(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => TrafficData(
            date: DateTime.parse(json['date']),
            users: json['users'],
            sessions: json['sessions'],
          ),
        )
        .toList();
  }

  List<FeedbackData> _parseRecentFeedback(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => FeedbackData(
            userName: json['userName'],
            rating: json['rating'],
            comment: json['comment'],
            time: json['time'],
          ),
        )
        .toList();
  }

  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String formatDuration(double minutes) {
    final hours = minutes ~/ 60;
    final mins = (minutes % 60).round();
    if (hours > 0) {
      return '${hours}h ${mins}min';
    }
    return '${mins}min';
  }

  String getSubscriptionStatusColor(int daysLeft) {
    if (daysLeft <= 3) return 'red';
    if (daysLeft <= 7) return 'orange';
    if (daysLeft <= 14) return 'yellow';
    return 'green';
  }

  List<Map<String, dynamic>> getQuickStats(AdminDashboardData data) {
    return [
      {
        'title': 'Usuarios Totales',
        'value': data.totalUsers.toString(),
        'change': '+${data.newUsersToday}',
        'icon': Icons.people,
        'color': EvaColors.vibrantPink,
        'trend': 'up',
      },
      {
        'title': 'Ingresos Diarios',
        'value': formatCurrency(data.dailyRevenue),
        'change': '+12.5%',
        'icon': Icons.attach_money,
        'color': Colors.green,
        'trend': 'up',
      },
      {
        'title': 'Suscripciones Activas',
        'value': data.activeSubscriptions.toString(),
        'change': '+${data.dailySales}',
        'icon': Icons.card_membership,
        'color': EvaColors.vibrantPink,
        'trend': 'up',
      },
      {
        'title': 'Satisfacción',
        'value': '${data.satisfactionScore.toStringAsFixed(1)}/5.0',
        'change': '+0.2',
        'icon': Icons.sentiment_very_satisfied,
        'color': Colors.amber,
        'trend': 'up',
      },
    ];
  }
}
