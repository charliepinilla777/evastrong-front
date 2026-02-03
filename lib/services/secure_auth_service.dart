import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

/// Servicio de autenticación seguro con refresh tokens y control de suscripciones
class SecureAuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrl = 'http://localhost:5000';

  // Tiempos de expiración
  static const Duration _accessTokenExpiry = Duration(minutes: 15);
  static const Duration _refreshTokenExpiry = Duration(days: 7);

  // Tokens en memoria
  static String? _accessToken;
  static String? _refreshToken;
  static DateTime? _tokenExpiry;
  static Timer? _refreshTimer;

  // Estado de suscripción
  static Map<String, dynamic>? _subscriptionInfo;
  static DateTime? _subscriptionLastCheck;
  static const Duration _subscriptionCheckInterval = Duration(minutes: 5);

  /// Login seguro con tokens
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'deviceInfo': _getDeviceInfo(),
          'ipAddress': await _getIpAddress(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storeTokens(data);
        _startTokenRefresh();
        await _loadSubscriptionInfo();

        return {
          'success': true,
          'user': data['user'],
          'subscription': data['subscription'],
        };
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['error'] ?? 'Error de login'};
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'error': 'Error de conexión'};
    }
  }

  /// Almacenar tokens de forma segura
  static Future<void> _storeTokens(Map<String, dynamic> data) async {
    _accessToken = data['accessToken'];
    _refreshToken = data['refreshToken'];

    // Calcular expiración del token desde el payload JWT
    try {
      final tokenData = JwtDecode.parseJwt(_accessToken!);
      _tokenExpiry = DateTime.fromMillisecondsSinceEpoch(
        tokenData['exp'] * 1000,
      );
    } catch (e) {
      // Si no se puede decodificar, usar tiempo por defecto
      _tokenExpiry = DateTime.now().add(_accessTokenExpiry);
    }

    // Almacenar en secure storage
    await _storage.write(key: 'access_token', value: _accessToken!);
    await _storage.write(key: 'refresh_token', value: _refreshToken!);
    await _storage.write(
      key: 'token_expiry',
      value: _tokenExpiry!.toIso8601String(),
    );

    print('Tokens almacenados securely');
  }

  /// Iniciar refresh automático de tokens
  static void _startTokenRefresh() {
    _refreshTimer?.cancel();

    if (_tokenExpiry == null) return;

    // Refrescar 2 minutos antes de expirar
    final refreshTime = _tokenExpiry!.subtract(const Duration(minutes: 2));
    final delay = refreshTime.difference(DateTime.now());

    if (delay.inMilliseconds > 0) {
      print('Token refresh programado en ${delay.inMinutes} minutos');
      _refreshTimer = Timer(delay, _refreshTokens);
    } else {
      // Si ya expiró o está por expirar, refrescar ahora
      _refreshTokens();
    }
  }

  /// Refrescar tokens automáticamente
  static Future<bool> _refreshTokens() async {
    try {
      print('Refrescando tokens...');

      final refreshToken =
          _refreshToken ?? await _storage.read(key: 'refresh_token');

      if (refreshToken == null) {
        print('No refresh token disponible');
        await logout();
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storeTokens(data);
        print('Tokens refrescados exitosamente');
        return true;
      } else {
        print('Error al refrescar tokens: ${response.statusCode}');
        await logout();
        return false;
      }
    } catch (e) {
      print('Token refresh error: $e');
      await logout();
      return false;
    }
  }

  /// Verificar si el token es válido
  static Future<bool> isTokenValid() async {
    if (_accessToken == null || _tokenExpiry == null) {
      await _loadTokens();
    }

    if (_tokenExpiry == null) return false;

    // Si el token está por expirar, intentar refrescar
    if (DateTime.now().isAfter(
      _tokenExpiry!.subtract(const Duration(minutes: 2)),
    )) {
      return await _refreshTokens();
    }

    return DateTime.now().isBefore(_tokenExpiry!);
  }

  /// Obtener headers autenticados
  static Future<Map<String, String>> getAuthHeaders() async {
    final isValid = await isTokenValid();
    if (!isValid) {
      throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
    }

    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
      'X-Device-Info': _getDeviceInfo(),
    };
  }

  /// Verificar suscripción activa
  static Future<bool> hasActiveSubscription() async {
    await _checkSubscriptionIfNeeded();
    return _subscriptionInfo?['status'] == 'active' &&
        _subscriptionInfo!['endDate'] != null &&
        DateTime.parse(_subscriptionInfo!['endDate']).isAfter(DateTime.now());
  }

  /// Verificar acceso a feature específico
  static Future<bool> hasAccessToFeature(String feature) async {
    await _checkSubscriptionIfNeeded();

    if (!await hasActiveSubscription()) return false;

    final features = _subscriptionInfo?['features'] as List<dynamic>?;
    if (features == null) return false;

    final featureConfig = features.firstWhere(
      (f) => f['name'] == feature,
      orElse: () => null,
    );

    return featureConfig != null && featureConfig['enabled'] == true;
  }

  /// Verificar nivel de suscripción
  static Future<String> getSubscriptionPlan() async {
    await _checkSubscriptionIfNeeded();
    return _subscriptionInfo?['plan'] ?? 'free';
  }

  /// Cargar información de suscripción
  static Future<void> _loadSubscriptionInfo() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscription/current'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        _subscriptionInfo = json.decode(response.body);
        _subscriptionLastCheck = DateTime.now();

        // Guardar en cache
        await _storage.write(
          key: 'subscription_info',
          value: json.encode(_subscriptionInfo),
        );
        await _storage.write(
          key: 'subscription_check',
          value: _subscriptionLastCheck!.toIso8601String(),
        );
      }
    } catch (e) {
      print('Error loading subscription info: $e');
      // Intentar cargar desde cache
      await _loadSubscriptionFromCache();
    }
  }

  /// Cargar suscripción desde cache
  static Future<void> _loadSubscriptionFromCache() async {
    try {
      final cachedInfo = await _storage.read(key: 'subscription_info');
      final lastCheck = await _storage.read(key: 'subscription_check');

      if (cachedInfo != null && lastCheck != null) {
        _subscriptionInfo = json.decode(cachedInfo);
        _subscriptionLastCheck = DateTime.parse(lastCheck);
      }
    } catch (e) {
      print('Error loading subscription from cache: $e');
    }
  }

  /// Verificar si es necesario actualizar la información de suscripción
  static Future<void> _checkSubscriptionIfNeeded() async {
    if (_subscriptionInfo == null) {
      await _loadSubscriptionFromCache();
    }

    if (_subscriptionLastCheck == null ||
        DateTime.now().difference(_subscriptionLastCheck!) >
            _subscriptionCheckInterval) {
      await _loadSubscriptionInfo();
    }
  }

  /// Logout seguro
  static Future<void> logout() async {
    print('Iniciando logout seguro...');

    _refreshTimer?.cancel();

    // Invalidar tokens en backend
    try {
      if (_accessToken != null) {
        await http.post(
          Uri.parse('$_baseUrl/api/auth/logout'),
          headers: await getAuthHeaders(),
        );
      }
    } catch (e) {
      print('Error en logout del backend: $e');
    }

    // Limpiar storage local
    await _storage.deleteAll();
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    _subscriptionInfo = null;
    _subscriptionLastCheck = null;

    print('Logout completado');
  }

  /// Cargar tokens desde storage
  static Future<void> _loadTokens() async {
    try {
      _accessToken = await _storage.read(key: 'access_token');
      _refreshToken = await _storage.read(key: 'refresh_token');

      final expiryStr = await _storage.read(key: 'token_expiry');
      if (expiryStr != null) {
        _tokenExpiry = DateTime.parse(expiryStr);
        _startTokenRefresh();
      }

      print('Tokens cargados desde secure storage');
    } catch (e) {
      print('Error loading tokens: $e');
    }
  }

  /// Obtener información del dispositivo
  static String _getDeviceInfo() {
    return 'Flutter App - ${DateTime.now().toIso8601String()}';
  }

  /// Obtener IP address (simulado)
  static Future<String> _getIpAddress() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.ipify.org?format=json'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'] ?? 'unknown';
      }
    } catch (e) {
      print('Error getting IP: $e');
    }
    return 'unknown';
  }

  /// Inicializar servicio (llamar al iniciar la app)
  static Future<void> initialize() async {
    await _loadTokens();
    await _loadSubscriptionFromCache();

    if (_accessToken != null) {
      print('Servicio de autenticación inicializado con token existente');
      _startTokenRefresh();
    } else {
      print('Servicio de autenticación inicializado sin token');
    }
  }

  /// Forzar refresh de suscripción
  static Future<void> refreshSubscription() async {
    await _loadSubscriptionInfo();
  }

  /// Obtener información detallada de suscripción
  static Map<String, dynamic>? get subscriptionInfo => _subscriptionInfo;

  /// Verificar si el usuario es admin
  static bool get isAdmin {
    if (_subscriptionInfo == null) return false;
    return _subscriptionInfo!['userRole'] == 'admin';
  }

  /// Tiempo restante de suscripción
  static Duration? get subscriptionTimeRemaining {
    if (_subscriptionInfo?['endDate'] == null) return null;

    final endDate = DateTime.parse(_subscriptionInfo!['endDate']);
    final remaining = endDate.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Formatear tiempo restante
  static String get subscriptionTimeRemainingFormatted {
    final remaining = subscriptionTimeRemaining;
    if (remaining == null) return 'N/A';

    if (remaining.inDays > 0) {
      return '${remaining.inDays} días';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} horas';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} minutos';
    } else {
      return 'Menos de 1 minuto';
    }
  }
}
