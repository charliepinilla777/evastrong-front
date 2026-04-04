import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenamiento seguro de datos sensibles
/// Usa encriptación nativa del dispositivo
class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  // Cache en memoria: garantiza UNA sola lectura al keystore por sesión
  static bool _tokenLoaded = false;
  static String? _cachedToken;
  static Completer<String?>? _tokenCompleter;

  // Instancia singleton
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
  );

  /// Guardar token de acceso
  static Future<void> saveToken(String token) async {
    _cachedToken = token;
    _tokenLoaded = true;
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Obtener token de acceso.
  /// Si hay múltiples llamadas concurrentes, solo UNA lee del keystore.
  static Future<String?> getToken() async {
    // Ya cargado: devolver del cache inmediatamente
    if (_tokenLoaded) return _cachedToken;

    // Lectura en progreso: esperar el mismo Completer
    if (_tokenCompleter != null) return _tokenCompleter!.future;

    // Primera llamada: leer del keystore
    _tokenCompleter = Completer<String?>();
    try {
      final token = await _storage
          .read(key: _tokenKey)
          .timeout(const Duration(seconds: 5));
      _cachedToken = token;
      _tokenLoaded = true;
      _tokenCompleter!.complete(token);
      _tokenCompleter = null;
      return token;
    } catch (_) {
      _tokenLoaded = true;
      _tokenCompleter!.complete(null);
      _tokenCompleter = null;
      return null;
    }
  }

  /// Guardar refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Obtener refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Guardar ID del usuario
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Obtener ID del usuario
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Guardar email del usuario
  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  /// Obtener email del usuario
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Limpiar todos los datos guardados (también limpia el cache)
  static Future<void> clearAll() async {
    _cachedToken = null;
    _tokenLoaded = false;
    _tokenCompleter = null;
    await _storage.deleteAll();
  }

  /// Verificar si hay sesión activa
  static Future<bool> hasValidSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
