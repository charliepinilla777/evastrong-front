import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
      final result = await ApiService.register(
        email: email,
        password: password,
        name: name,
      );

      _token = result['token'];
      _user = result['user'];
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      _token = result['token'];
      _user = result['user'];
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await ApiService.logout();
      _token = null;
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Obtener perfil
  Future<bool> getProfile() async {
    if (_token == null) return false;

    try {
      final result = await ApiService.getProfile();
      _user = result['user'];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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
      final result = await ApiService.updateProfile(
        name: name,
        phone: phone,
        age: age,
        gender: gender,
        fitnessLevel: fitnessLevel,
        goals: goals,
      );

      _user = result['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
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
      await ApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verificar si el token es válido
  Future<bool> verifyToken() async {
    if (_token == null) return false;

    try {
      await ApiService.verifyToken(_token!);
      return true;
    } catch (e) {
      _token = null;
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  /// Renovar token
  Future<bool> refreshToken() async {
    if (_token == null) return false;

    try {
      final result = await ApiService.refreshToken(_token!);
      _token = result['token'];
      notifyListeners();
      return true;
    } catch (e) {
      _token = null;
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  /// Establecer usuario y token (para OAuth)
  void setUserAndToken(String token, Map<String, dynamic> user) {
    _token = token;
    _user = user;
    _isLoggedIn = true;
    ApiService.setToken(token);
    notifyListeners();
  }

  /// Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
