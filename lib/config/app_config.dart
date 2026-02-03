/// Configuración centralizada de la aplicación
///
/// Este archivo contiene todas las URLs y configuraciones importantes
/// para facilitar el mantenimiento y cambios entre ambientes.
class AppConfig {
  // ========== AMBIENTE ==========
  static const bool isDebugMode =
      true; // Cambiar a true para desarrollo local

  // ========== URLs del BACKEND ==========
  // Desarrollo - Backend local
  static const String _backendDevUrl = 'http://localhost:5000';

  // Producción - Backend desplegado en Render
  static const String _backendProdUrl =
      'https://evastrong-backend.onrender.com';

  // URL actual según ambiente
  static String get backendUrl =>
      isDebugMode ? _backendDevUrl : _backendProdUrl;

  // ========== ENDPOINTS ESPECÍFICOS ==========
  // Pagos (usa el mismo backend pero con prefijo /payments)
  static String get paymentsUrl => '$backendUrl/payments';

  // Rutinas y recomendaciones
  static String get routinesUrl => '$backendUrl/routines';
  static String get routineRecommendationsUrl =>
      '$backendUrl/routine-recommendations';
  static String get exercisesUrl => '$backendUrl/exercises';

  // ========== TIMEOUTS ==========
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // ========== NOMBRES DE APP ==========
  static const String appName = 'Eva Strong';
  static const String appVersion = '1.0.0';

  // ========== ESQUEMAS DE DEEP LINKING ==========
  static const String androidScheme = 'com.evastrong.app://';
  static const String iosScheme = 'com.evastrong.app://';

  // ========== CONFIGURACIÓN DE LOGS ==========
  static const bool enableApiLogs = isDebugMode;
  static const bool enableStorageLogs = false;

  // ========== FEATURE FLAGS ==========
  static const bool enableOAuth = true;
  static const bool enablePayments = true;
  static const bool enableVideos = true;
  static const bool enableAnalytics = false;
}
