import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  late PaymentService _paymentService;
  
  // Estados
  bool isLoading = false;
  String? error;
  Map<String, dynamic>? currentSubscription;
  Map<String, dynamic>? lastPayment;

  PaymentProvider({String? jwtToken}) {
    _paymentService = PaymentService(jwtToken: jwtToken);
  }

  /// Actualizar JWT token
  void setJwtToken(String token) {
    _paymentService = PaymentService(jwtToken: token);
  }

  /// Crear orden PayPal
  Future<Map<String, dynamic>?> createPayPalOrder({
    required String plan,
    required String period,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await _paymentService.createPayPalOrder(
        plan: plan,
        period: period,
      );

      if (result['success'] == true) {
        lastPayment = result;
        isLoading = false;
        notifyListeners();
        return result;
      } else {
        throw Exception(result['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Capturar pago PayPal
  Future<Map<String, dynamic>?> capturePayPalOrder({
    required String orderId,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await _paymentService.capturePayPalOrder(
        orderId: orderId,
      );

      if (result['success'] == true) {
        lastPayment = result;
        currentSubscription = result['subscription'];
        isLoading = false;
        notifyListeners();
        return result;
      } else {
        throw Exception(result['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Crear preferencia Mercado Pago
  Future<Map<String, dynamic>?> createMercadoPagoPreference({
    required String plan,
    required String period,
    String currency = 'COP',
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await _paymentService.createMercadoPagoPreference(
        plan: plan,
        period: period,
        currency: currency,
      );

      if (result['success'] == true) {
        lastPayment = result;
        isLoading = false;
        notifyListeners();
        return result;
      } else {
        throw Exception(result['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Obtener suscripción actual
  Future<void> fetchSubscription() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await _paymentService.getSubscription();

      if (result['success'] == true) {
        currentSubscription = result['subscription'];
        isLoading = false;
        notifyListeners();
      } else {
        throw Exception(result['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  /// Cancelar suscripción
  Future<bool> cancelSubscription() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await _paymentService.cancelSubscription();

      if (result['success'] == true) {
        currentSubscription = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception(result['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Obtener estado de pago
  Future<Map<String, dynamic>?> getMercadoPagoPaymentStatus({
    required String paymentId,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final result = await _paymentService.getMercadoPagoPaymentStatus(
        paymentId: paymentId,
      );

      if (result['success'] == true) {
        isLoading = false;
        notifyListeners();
        return result['payment'];
      } else {
        throw Exception(result['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Limpiar errores
  void clearError() {
    error = null;
    notifyListeners();
  }

  /// Verificar si hay suscripción activa
  bool get hasActiveSubscription {
    return currentSubscription != null && 
           currentSubscription!['status'] == 'active';
  }

  /// Obtener plan actual
  String? get currentPlan {
    return currentSubscription?['plan'];
  }

  /// Obtener fecha de fin de suscripción
  String? get subscriptionEndDate {
    return currentSubscription?['endDate'];
  }
}
