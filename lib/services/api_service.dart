import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000'; // Cambiar en producción
  static String? _token;

  // Setter para el token
  static void setToken(String token) {
    _token = token;
  }

  // Getter para el token
  static String? getToken() {
    return _token;
  }

  // Headers con autenticación
  static Map<String, String> _getHeaders({bool requireAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (requireAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ========== AUTENTICACIÓN ==========

  /// Registro con email y contraseña
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Login con email y contraseña
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verificar token
  static Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: {..._getHeaders(), 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Token inválido');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Renovar token
  static Future<Map<String, dynamic>> refreshToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {..._getHeaders(), 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return data;
      } else {
        throw Exception('No se pudo renovar el token');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _getHeaders(requireAuth: true),
      );
      _token = null;
    } catch (e) {
      _token = null;
      rethrow;
    }
  }

  // ========== USUARIOS ==========

  /// Obtener perfil del usuario
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener perfil');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar perfil
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    int? age,
    String? gender,
    String? fitnessLevel,
    List<String>? goals,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (age != null) body['age'] = age;
      if (gender != null) body['gender'] = gender;
      if (fitnessLevel != null) body['fitnessLevel'] = fitnessLevel;
      if (goals != null) body['goals'] = goals;

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: _getHeaders(requireAuth: true),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar perfil');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar contraseña
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/change-password'),
        headers: _getHeaders(requireAuth: true),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ========== PAGOS ==========

  /// Crear preferencia de pago
  static Future<Map<String, dynamic>> createPaymentPreference({
    required String plan,
    required String period,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/create-preference'),
        headers: _getHeaders(requireAuth: true),
        body: jsonEncode({
          'plan': plan,
          'period': period,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear preferencia de pago');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener historial de pagos
  static Future<Map<String, dynamic>> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/history'),
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener historial');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reembolsar pago
  static Future<Map<String, dynamic>> refundPayment(String paymentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/$paymentId/refund'),
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al reembolsar');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ========== SUSCRIPCIONES ==========

  /// Obtener suscripción actual
  static Future<Map<String, dynamic>> getCurrentSubscription() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/current'),
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener suscripción');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar plan de suscripción
  static Future<Map<String, dynamic>> changePlan(String newPlan) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/change-plan'),
        headers: _getHeaders(requireAuth: true),
        body: jsonEncode({'newPlan': newPlan}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cancelar suscripción
  static Future<Map<String, dynamic>> cancelSubscription({String? reason}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/cancel'),
        headers: _getHeaders(requireAuth: true),
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Renovar suscripción
  static Future<Map<String, dynamic>> renewSubscription() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/renew'),
        headers: _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al renovar');
      }
    } catch (e) {
      rethrow;
    }
  }
}
