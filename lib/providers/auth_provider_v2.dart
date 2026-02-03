import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import '../services/api_service_v2.dart';
import '../services/secure_storage_service.dart';

class AuthProviderV2 extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitializing = true;
  Timer? _tokenRefreshTimer;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitializing => _isInitializing;

  /// Inicializar: Verificar si existe sesión guardada
  Future<void> initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final hasValidSession = await SecureStorageService.hasValidSession();
      if (hasValidSession) {
        // Intentar verificar que el token siga siendo válido
        final isValid = await verifyToken();
        if (isValid) {
          // Programar refresh automático
          await _scheduleTokenRefresh();
        }
      } else {
        _isLoggedIn = false;
      }
    } catch (e) {
      debugPrint('Error inicializando auth: $e');
      _isLoggedIn = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Registrarse
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiServiceV2.register(
        email: email,
        password: password,
        name: name,
      );

      _user = result['user'];
      _isLoggedIn = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error inesperado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Iniciar sesión
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiServiceV2.login(
        email: email,
        password: password,
      );

      _user = result['user'];
      _isLoggedIn = true;
      _error = null;
      _isLoading = false;
      notifyListeners();
      
      // Programar refresh automático del token
      await _scheduleTokenRefresh();
      
      return true;
    } on UnauthorizedException {
      _error = 'Email o contraseña incorrectos';
      _isLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error inesperado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await ApiServiceV2.logout();
      _user = null;
      _isLoggedIn = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error en logout: $e');
      // Limpiar aunque haya error
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  /// Obtener perfil
  Future<bool> getProfile() async {
    try {
      final result = await ApiServiceV2.getProfile();
      _user = result['user'];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al obtener perfil';
      notifyListeners();
      return false;
    }
  }

  /// Actualizar perfil
  Future<bool> updateProfile({
    String? name,
    String? phone,
    int? age,
    String? gender,
    String? fitnessLevel,
    List<String>? goals,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiServiceV2.updateProfile(
        name: name,
        phone: phone,
        age: age,
        gender: gender,
        fitnessLevel: fitnessLevel,
        goals: goals,
      );

      _user = result['user'];
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al actualizar perfil';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cambiar contraseña
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiServiceV2.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error al cambiar contraseña';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verificar si el token es válido
  Future<bool> verifyToken() async {
    try {
      await ApiServiceV2.verifyToken();
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } on UnauthorizedException {
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      debugPrint('Error verificando token: ${e.message}');
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error inesperado verificando token: $e');
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  /// Establecer usuario y token (para OAuth)
  Future<void> setUserAndToken(String token, Map<String, dynamic> user) async {
    await SecureStorageService.saveToken(token);
    if (user['_id'] != null) {
      await SecureStorageService.saveUserId(user['_id']);
    }
    if (user['email'] != null) {
      await SecureStorageService.saveUserEmail(user['email']);
    }
    
    _user = user;
    _isLoggedIn = true;
    _error = null;
    notifyListeners();
    
    // Programar refresh automático del token
    await _scheduleTokenRefresh();
  }

  /// Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Programar refresh automático de token
  Future<void> _scheduleTokenRefresh() async {
    _tokenRefreshTimer?.cancel();
    
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) return;

      // Decodificar JWT para obtener expiration time
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Token JWT inválido');
        return;
      }

      // Decodificar payload (segunda parte)
      final decoded = _decodeJwt(parts[1]);
      
      if (decoded == null || !decoded.containsKey('exp')) {
        debugPrint('No se pudo extraer expiración del token');
        return;
      }

      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        (decoded['exp'] as int) * 1000,
      );

      final now = DateTime.now();
      final timeUntilExpiry = expiresAt.difference(now);
      
      // Refrescar 5 minutos antes de que expire
      final refreshTime = timeUntilExpiry - const Duration(minutes: 5);

      if (refreshTime.isNegative) {
        // Token ya expirado o vence muy pronto
        debugPrint('Token vence muy pronto o ya expiró');
        await logout();
      } else {
        // Programar refresh en el tiempo calculado
        debugPrint(
          'Token refresh programado en ${refreshTime.inMinutes} minutos',
        );
        _tokenRefreshTimer = Timer(refreshTime, _refreshToken);
      }
    } catch (e) {
      debugPrint('Error programando token refresh: $e');
    }
  }

  /// Refrescar token
  Future<void> _refreshToken() async {
    try {
      debugPrint('Intentando refrescar token...');
      final result = await ApiServiceV2.refreshToken();
      
      if (result['token'] != null) {
        await SecureStorageService.saveToken(result['token']);
        
        if (result['user'] != null) {
          _user = result['user'];
        }
        
        notifyListeners();
        debugPrint('Token refrescado exitosamente');
        
        // Programar siguiente refresh
        await _scheduleTokenRefresh();
      }
    } catch (e) {
      debugPrint('Error refrescando token: $e');
      // Si falla el refresh, desconectar usuario
      await logout();
    }
  }

  /// Decodificar payload de JWT
  Map<String, dynamic>? _decodeJwt(String payload) {
    try {
      // Agregar padding si es necesario
      final int padLength = 4 - (payload.length % 4);
      final String paddedPayload = padLength == 4 
          ? payload 
          : payload + ('=' * padLength);
      
      final decodedBytes = base64Url.decode(paddedPayload);
      final decoded = utf8.decode(decodedBytes);
      
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decodificando JWT: $e');
      return null;
    }
  }

  /// Limpiar timer al dispose
  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    super.dispose();
  }
