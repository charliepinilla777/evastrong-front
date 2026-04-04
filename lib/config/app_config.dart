import 'package:flutter/foundation.dart';

/// Configuración centralizada de la aplicación
///
/// Este archivo contiene todas las URLs y configuraciones importantes
/// para facilitar el mantenimiento y cambios entre ambientes.
class AppConfig {
  // ========== AMBIENTE ==========
  /// `true` en flutter run (debug), `false` en flutter build --release
  static bool get isDebugMode => kDebugMode;

  // ========== URLs del BACKEND ==========
  // Desarrollo - Backend local
  static const String _backendDevUrl = String.fromEnvironment(
    'BACKEND_DEV_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  // Producción - Backend desplegado en Render
  static const String _backendProdUrl = String.fromEnvironment(
    'BACKEND_PROD_URL',
    defaultValue: 'https://evastrong-backend.onrender.com',
  );

  // URL actual según ambiente
  static String get backendUrl =>
      isDebugMode ? _backendDevUrl : _backendProdUrl;

  // ========== ENDPOINTS ESPECÍFICOS ==========
  // Pagos (usa el mismo backend pero con prefijo /payments)
  static String get paymentsUrl => '$backendUrl/payments';

  // Rutinas y recomendaciones
  static String get routinesUrl => '$backendUrl/routines';

  // Dietas y recetas
  static String get recipesUrl => '$backendUrl/recipes';

  // Planes semanales
  static String get plansUrl => '$backendUrl/plans';

  // Recomendaciones de dieta personalizadas
  static String get dietRecommendationsUrl => '$backendUrl/diet-recommendations';
  static String get routineRecommendationsUrl =>
      '$backendUrl/routine-recommendations';
  static String get exercisesUrl => '$backendUrl/exercises';

  // ========== TIMEOUTS ==========
  static const Duration apiTimeout = Duration(seconds: 20);
  static const Duration paymentTimeout = Duration(seconds: 45);
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // ========== NOMBRES DE APP ==========
  static const String appName = 'Eva Strong';
  static const String appVersion = '1.0.0';

  // ========== ESQUEMAS DE DEEP LINKING ==========
  static const String androidScheme = 'com.evastrong.app://';
  static const String iosScheme = 'com.evastrong.app://';

  // ========== CONFIGURACIÓN DE LOGS ==========
  static bool get enableApiLogs => isDebugMode;
  static const bool enableStorageLogs = false;

  // ========== SOCKET.IO ==========
  static String get socketUrl =>
      isDebugMode ? _backendDevUrl : _backendProdUrl;

  // ========== FEATURE FLAGS ==========
  static const bool enableOAuth = true;
  static const bool enablePayments = true;
  static const bool enableVideos = true;
  static const bool enableAnalytics = false;
}
