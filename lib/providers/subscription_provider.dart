import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  Map<String, dynamic>? _subscription;
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get subscription => _subscription;
  List<Map<String, dynamic>> get paymentHistory => _paymentHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isPremium => _subscription?['plan'] == 'premium' && _subscription?['status'] == 'active';
  bool get isActive => _subscription?['status'] == 'active';

  /// Obtener suscripción actual
  Future<void> getCurrentSubscription() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.getCurrentSubscription();
      if (result['subscription'] != null) {
        _subscription = result['subscription'];
      }
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener historial de pagos
  Future<void> getPaymentHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.getPaymentHistory();
      _paymentHistory = List<Map<String, dynamic>>.from(result['payments'] ?? []);
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crear preferencia de pago
  Future<Map<String, dynamic>?> createPaymentPreference({
    required String plan,
    required String period,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.createPaymentPreference(
        plan: plan,
        period: period,
      );
      _error = null;
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Cambiar plan
  Future<bool> changePlan(String newPlan) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.changePlan(newPlan);
      _subscription = result['subscription'];
      _error = null;
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

  /// Cancelar suscripción
  Future<bool> cancelSubscription({String? reason}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.cancelSubscription(reason: reason);
      _subscription = result['subscription'];
      _error = null;
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

  /// Renovar suscripción
  Future<bool> renewSubscription() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.renewSubscription();
      _subscription = result['subscription'];
      _error = null;
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

  /// Reembolsar pago
  Future<bool> refundPayment(String paymentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.refundPayment(paymentId);
      await getPaymentHistory();
      _error = null;
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

  /// Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
