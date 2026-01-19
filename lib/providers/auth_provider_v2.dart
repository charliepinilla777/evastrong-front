import 'package:flutter/material.dart';
import '../services/api_service_v2.dart';
import '../services/secure_storage_service.dart';

class AuthProviderV2 extends ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitializing = true;

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
        await verifyToken();
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
      return true;
    } on UnauthorizedException catch (e) {
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
  }

  /// Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
