import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'secure_storage_service.dart';
import 'api_service_v2.dart';

/// Modelo de estado de prueba
class TrialStatus {
  final bool active;
  final String plan;
  final int daysRemaining;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool hasAccess;
  final bool trialExpired;
  final bool needsSubscription;

  TrialStatus({
    required this.active,
    required this.plan,
    required this.daysRemaining,
    this.startDate,
    this.endDate,
    required this.hasAccess,
    required this.trialExpired,
    required this.needsSubscription,
  });

  factory TrialStatus.fromJson(Map<String, dynamic> json) {
    final trial = json['trial'] as Map<String, dynamic>;
    return TrialStatus(
      active: trial['active'] ?? false,
      plan: trial['plan'] ?? 'free',
      daysRemaining: trial['daysRemaining'] ?? 0,
      startDate: trial['startDate'] != null
          ? DateTime.parse(trial['startDate'])
          : null,
      endDate:
          trial['endDate'] != null ? DateTime.parse(trial['endDate']) : null,
      hasAccess: trial['hasAccess'] ?? false,
      trialExpired: trial['trialExpired'] ?? false,
      needsSubscription: trial['needsSubscription'] ?? false,
    );
  }

  bool get isTrialActive => active && !trialExpired;
  bool get isPremiumOrBasic => plan == 'premium' || plan == 'basic';
}

/// Servicio para gestionar el período de prueba
class TrialService {
  static final String _baseUrl = AppConfig.backendUrl;

  /// Obtener estado del período de prueba
  static Future<TrialStatus> getTrialStatus() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(Uri.parse('$_baseUrl/trial/status'), headers: headers)
          .timeout(const Duration(seconds: 30));

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return TrialStatus.fromJson(data);
      } else {
        throw ApiException(
          message: data['message'] ?? 'Error al obtener estado de prueba',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Expirar prueba manualmente (solo para testing)
  static Future<void> expireTrial() async {
    try {
      final token = await SecureStorageService.getToken();
      if (token == null) {
        throw UnauthorizedException();
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http
          .post(Uri.parse('$_baseUrl/trial/expire'), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw ApiException(
          message: data['message'] ?? 'Error al expirar prueba',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verificar si el usuario puede acceder a contenido premium
  static Future<bool> canAccessPremiumContent() async {
    try {
      final status = await getTrialStatus();
      return status.hasAccess;
    } catch (e) {
      // En caso de error, denegar acceso por seguridad
      return false;
    }
  }

  /// Obtener mensaje de estado para mostrar al usuario
  static String getStatusMessage(TrialStatus status) {
    if (status.isPremiumOrBasic) {
      return 'Suscripción ${status.plan.toUpperCase()} activa';
    } else if (status.isTrialActive) {
      return 'Prueba gratis: ${status.daysRemaining} ${status.daysRemaining == 1 ? 'día' : 'días'} restantes';
    } else if (status.trialExpired) {
      return 'Tu período de prueba ha expirado';
    } else {
      return 'Sin suscripción activa';
    }
  }

  /// Determinar si debe mostrar banner de suscripción
  static bool shouldShowSubscriptionBanner(TrialStatus status) {
    // Mostrar banner si:
    // - La prueba está por expirar (2 días o menos)
    // - La prueba expiró
    // - No tiene suscripción activa
    return (status.isTrialActive && status.daysRemaining <= 2) ||
        status.trialExpired ||
        status.needsSubscription;
  }
}
