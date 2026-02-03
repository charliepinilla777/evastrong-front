import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';
import '../config/app_config.dart';

/// Excepciones personalizadas para la API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  ApiException({required this.message, this.statusCode, this.code});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'No autorizado'})
    : super(statusCode: 401, code: 'UNAUTHORIZED');
}

class TokenExpiredException extends ApiException {
  TokenExpiredException({super.message = 'Token expirado'})
    : super(statusCode: 401, code: 'TOKEN_EXPIRED');
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Error de conexión'})
    : super(code: 'NETWORK_ERROR');
}

class ServerException extends ApiException {
  ServerException({required super.message, super.statusCode})
    : super(code: 'SERVER_ERROR');
}

/// Servicio API mejorado con refresh token automático
class ApiServiceV2 {
  // Usar configuración centralizada
  static String get _baseUrl => AppConfig.backendUrl;

  // Timeouts
  static Duration get _timeout => AppConfig.apiTimeout;
  static const int _maxRetries = 3;
  static const int _retryDelayMs = 1000;

  // Headers predeterminados
  static Map<String, String> _getHeaders({bool requireAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'EvaStrong/1.0',
    };
    return headers;
  }

  /// Realizar request con manejo de errores y retry automático
  static Future<http.Response> _makeRequest(
    Future<http.Response> Function() request, {
    bool requireAuth = false,
    int retryCount = 0,
  }) async {
    try {
      final response = await request().timeout(_timeout);

      // Si requiere autenticación y recibe 401, intentar refresh
      if (requireAuth && response.statusCode == 401 && retryCount < 1) {
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          return _makeRequest(
            request,
            requireAuth: requireAuth,
            retryCount: retryCount + 1,
          );
        }
      }

      return response;
    } on http.ClientException catch (e) {
      // Error de conexión
      if (retryCount < _maxRetries) {
        await Future.delayed(
          Duration(milliseconds: _retryDelayMs * (retryCount + 1)),
        );
        return _makeRequest(
          request,
          requireAuth: requireAuth,
          retryCount: retryCount + 1,
        );
      }
      throw NetworkException(
        message: 'No se pudo conectar al servidor: ${e.message}',
      );
    } on TimeoutException catch (_) {
      throw NetworkException(
        message: 'Tiempo de espera agotado. Intenta de nuevo.',
      );
    }
  }

  /// Procesar respuesta y manejar errores
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      switch (response.statusCode) {
        case 200:
        case 201:
          return data;

        case 400:
          throw ApiException(
            message: data['message'] ?? 'Solicitud inválida',
            statusCode: 400,
            code: 'BAD_REQUEST',
          );

        case 401:
          throw UnauthorizedException(
            message:
                data['message'] ??
                'Sesión expirada. Por favor inicia sesión nuevamente.',
          );

        case 403:
          throw ApiException(
            message: data['message'] ?? 'No tienes permiso para acceder a esto',
            statusCode: 403,
            code: 'FORBIDDEN',
          );

        case 404:
          throw ApiException(
            message: data['message'] ?? 'Recurso no encontrado',
            statusCode: 404,
            code: 'NOT_FOUND',
          );

        case 429:
          throw ApiException(
            message: 'Demasiadas solicitudes. Intenta más tarde.',
            statusCode: 429,
            code: 'RATE_LIMITED',
          );

        case 500:
        case 502:
        case 503:
          throw ServerException(
            message:
                data['message'] ?? 'Error del servidor. Intenta más tarde.',
            statusCode: response.statusCode,
          );

        default:
          throw ApiException(
            message: data['message'] ?? 'Error desconocido',
            statusCode: response.statusCode,
          );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Error al procesar respuesta: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Refresh token automático
  static Future<bool> _refreshTokenIfNeeded() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return false;

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/refresh'),
            headers: _getHeaders(requireAuth: true)
              ..['Authorization'] = 'Bearer $token',
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['token'];
        await SecureStorageService.saveToken(newToken);
        return true;
      }

      // Si no se puede renovar, limpiar sesión
      await SecureStorageService.clearAll();
      return false;
    } catch (e) {
      debugPrint('Error al renovar token: $e');
      await SecureStorageService.clearAll();
      return false;
    }
  }

  // ========== AUTENTICACIÓN ==========

  /// Registro con email y contraseña
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw ApiException(message: 'Por favor completa todos los campos');
    }

    if (password.length < 8) {
      throw ApiException(
        message: 'La contraseña debe tener al menos 8 caracteres',
      );
    }

    try {
      final response = await _makeRequest(
        () => http.post(
          Uri.parse('$_baseUrl/auth/register'),
          headers: _getHeaders(),
          body: jsonEncode({
            'email': email.toLowerCase().trim(),
            'password': password,
            'name': name.trim(),
          }),
        ),
      );

      final data = _handleResponse(response);

      // Guardar token de forma segura
      if (data['token'] != null) {
        await SecureStorageService.saveToken(data['token']);
        if (data['user']?['_id'] != null) {
          await SecureStorageService.saveUserId(data['user']['_id']);
        }
        await SecureStorageService.saveUserEmail(email);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Login con email y contraseña
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw ApiException(message: 'Por favor completa todos los campos');
    }

    try {
      final response = await _makeRequest(
        () => http.post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: _getHeaders(),
          body: jsonEncode({
            'email': email.toLowerCase().trim(),
            'password': password,
          }),
        ),
      );

      final data = _handleResponse(response);

      // Guardar token de forma segura
      if (data['token'] != null) {
        await SecureStorageService.saveToken(data['token']);
        if (data['user']?['_id'] != null) {
          await SecureStorageService.saveUserId(data['user']['_id']);
        }
        await SecureStorageService.saveUserEmail(email);
      }

      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  static Future<void> logout() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token != null) {
        await http
            .post(
              Uri.parse('$_baseUrl/auth/logout'),
              headers: _getHeaders(requireAuth: true)
                ..['Authorization'] = 'Bearer $token',
            )
            .timeout(_timeout);
      }
    } finally {
      await SecureStorageService.clearAll();
    }
  }

  /// Verificar token
  static Future<Map<String, dynamic>> verifyToken() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException(message: 'No hay sesión activa');
    }

    try {
      final response = await _makeRequest(
        () => http.get(
          Uri.parse('$_baseUrl/auth/verify'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // ========== USUARIOS ==========

  /// Obtener perfil del usuario
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    try {
      final response = await _makeRequest(
        () => http.get(
          Uri.parse('$_baseUrl/users/profile'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
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
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (age != null) body['age'] = age;
    if (gender != null) body['gender'] = gender;
    if (fitnessLevel != null) body['fitnessLevel'] = fitnessLevel;
    if (goals != null) body['goals'] = goals;

    try {
      final response = await _makeRequest(
        () => http.put(
          Uri.parse('$_baseUrl/users/profile'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
          body: jsonEncode(body),
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar contraseña
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    if (newPassword.length < 8) {
      throw ApiException(
        message: 'La nueva contraseña debe tener al menos 8 caracteres',
      );
    }

    try {
      final response = await _makeRequest(
        () => http.post(
          Uri.parse('$_baseUrl/users/change-password'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
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
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    try {
      final response = await _makeRequest(
        () => http.post(
          Uri.parse('$_baseUrl/payments/create-preference'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
          body: jsonEncode({'plan': plan, 'period': period}),
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener historial de pagos
  static Future<Map<String, dynamic>> getPaymentHistory() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    try {
      final response = await _makeRequest(
        () => http.get(
          Uri.parse('$_baseUrl/payments/history'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // ========== SUSCRIPCIONES ==========

  /// Obtener suscripción actual
  static Future<Map<String, dynamic>> getCurrentSubscription() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    try {
      final response = await _makeRequest(
        () => http.get(
          Uri.parse('$_baseUrl/subscriptions/current'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Cambiar plan de suscripción
  static Future<Map<String, dynamic>> changePlan(String newPlan) async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    try {
      final response = await _makeRequest(
        () => http.post(
          Uri.parse('$_baseUrl/subscriptions/change-plan'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
          body: jsonEncode({'newPlan': newPlan}),
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Cancelar suscripción
  static Future<Map<String, dynamic>> cancelSubscription({
    String? reason,
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw UnauthorizedException();
    }

    try {
      final response = await _makeRequest(
        () => http.post(
          Uri.parse('$_baseUrl/subscriptions/cancel'),
          headers: _getHeaders(requireAuth: true)
            ..['Authorization'] = 'Bearer $token',
          body: jsonEncode({'reason': reason}),
        ),
        requireAuth: true,
      );

      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener estado de suscripción
  static Future<Map<String, dynamic>> getSubscriptionStatus(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/subscriptions/current'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Timeout al obtener suscripción');
            },
          );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'subscription': jsonDecode(response.body),
        };
      }
      return {'success': false, 'error': 'Error obteniendo suscripción'};
    } on TimeoutException catch (e) {
      return {'success': false, 'error': 'Timeout: ${e.toString()}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Obtener rol del usuario
  static Future<Map<String, dynamic>> getUserRole(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/role'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Timeout al obtener rol');
            },
          );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': jsonDecode(response.body),
        };
      }
      return {'success': false, 'error': 'Error obteniendo rol'};
    } on TimeoutException catch (e) {
      return {'success': false, 'error': 'Timeout: ${e.toString()}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
