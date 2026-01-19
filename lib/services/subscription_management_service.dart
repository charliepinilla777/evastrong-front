import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionManagementService {
  static const String baseUrl = 'http://localhost:5000/payments';
  // Para producción: 'https://tu-servicio.onrender.com/payments'

  String? jwtToken;

  SubscriptionManagementService({this.jwtToken});

  /// Cambiar plan (upgrade o downgrade)
  Future<Map<String, dynamic>> changePlan({
    required String newPlan, // 'basic' | 'premium'
    required String? prorationStrategy, // 'immediate' | 'at_period_end'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-plan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'newPlan': newPlan,
          'prorationStrategy': prorationStrategy ?? 'immediate',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al cambiar plan: $e');
    }
  }

  /// Cambiar período de suscripción
  Future<Map<String, dynamic>> changeBillingPeriod({
    required String newPeriod, // 'monthly' | 'annual'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-billing-period'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'newPeriod': newPeriod,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al cambiar período: $e');
    }
  }

  /// Obtener detalles de cambio de plan (costo adicional/devolución)
  Future<Map<String, dynamic>> getPlanChangeDetails({
    required String newPlan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/plan-change-details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'newPlan': newPlan,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtener historial de cambios de plan
  Future<List<Map<String, dynamic>>> getPlanChangeHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plan-change-history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['history'] ?? []);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Pausar suscripción
  Future<Map<String, dynamic>> pauseSubscription({
    required int daysToResume, // Cuántos días pausar
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pause-subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'resumeDate': DateTime.now().add(Duration(days: daysToResume)).toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Reanudar suscripción pausada
  Future<Map<String, dynamic>> resumeSubscription() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resume-subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtener opciones de cambio de plan disponibles
  Future<Map<String, dynamic>> getAvailablePlanChanges() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/available-plan-changes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
