import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service_v2.dart';

class AccessControlService {
  static const _storage = FlutterSecureStorage();
  static const _userRoleKey = 'user_role';
  static const _subscriptionPlanKey = 'subscription_plan';

  /// Verifica si el usuario tiene una suscripción válida
  static Future<bool> hasValidSubscription() async {
    try {
      final plan = await _storage.read(key: _subscriptionPlanKey);
      
      // Planes permitidos para acceso
      const allowedPlans = ['basic', 'premium', 'elite'];
      
      return plan != null && allowedPlans.contains(plan);
    } catch (e) {
      debugPrint('Error verificando suscripción: $e');
      return false;
    }
  }

  /// Obtiene el plan de suscripción actual
  static Future<String?> getSubscriptionPlan() async {
    try {
      return await _storage.read(key: _subscriptionPlanKey);
    } catch (e) {
      debugPrint('Error obteniendo plan: $e');
      return null;
    }
  }

  /// Verifica si el usuario es administrador
  static Future<bool> isAdmin() async {
    try {
      final role = await _storage.read(key: _userRoleKey);
      return role == 'admin';
    } catch (e) {
      debugPrint('Error verificando admin: $e');
      return false;
    }
  }

  /// Obtiene el rol del usuario
  static Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _userRoleKey);
    } catch (e) {
      debugPrint('Error obteniendo rol: $e');
      return null;
    }
  }

  /// Actualiza la información de suscripción desde el backend
  static Future<bool> refreshSubscriptionInfo(String token) async {
    try {
      final response = await ApiServiceV2.getSubscriptionStatus(token);
      
      if (response['success'] == true) {
        final plan = response['subscription']['plan'] ?? 'free';
        await _storage.write(key: _subscriptionPlanKey, value: plan);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error actualizando suscripción: $e');
      return false;
    }
  }

  /// Actualiza la información de rol desde el backend
  static Future<bool> refreshUserRole(String token) async {
    try {
      final response = await ApiServiceV2.getUserRole(token);
      
      if (response['success'] == true) {
        final role = response['user']['role'] ?? 'user';
        await _storage.write(key: _userRoleKey, value: role);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error actualizando rol: $e');
      return false;
    }
  }

  /// Limpia toda la información de acceso
  static Future<void> clearAccessInfo() async {
    try {
      await _storage.delete(key: _userRoleKey);
      await _storage.delete(key: _subscriptionPlanKey);
    } catch (e) {
      debugPrint('Error limpiando acceso: $e');
    }
  }
}
