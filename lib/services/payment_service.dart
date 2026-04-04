import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'api_service_v2.dart';

class PaymentService {
  // Usar configuración centralizada
  static String get baseUrl => AppConfig.paymentsUrl;

  String? jwtToken;

  PaymentService({this.jwtToken});

  /// Crear orden de pago con PayPal
  Future<Map<String, dynamic>> createPayPalOrder({
    required String plan, // 'basic' | 'premium'
    required String period, // 'monthly' | 'annual'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'plan': plan, 'period': period}),
      ).timeout(AppConfig.paymentTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error al crear orden PayPal: $e');
    }
  }

  /// Capturar pago en PayPal
  Future<Map<String, dynamic>> capturePayPalOrder({
    required String orderId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/capture-order/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      ).timeout(AppConfig.paymentTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error al capturar pago: $e');
    }
  }

  /// Crear preferencia de pago en Mercado Pago
  Future<Map<String, dynamic>> createMercadoPagoPreference({
    required String plan, // 'basic' | 'premium'
    required String period, // 'monthly' | 'annual'
    String currency = 'COP', // 'COP' | 'USD'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mercado-pago/create-preference'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'plan': plan,
          'period': period,
          'currency': currency,
        }),
      ).timeout(AppConfig.paymentTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error al crear preferencia Mercado Pago: $e');
    }
  }

  /// Obtener suscripción actual del usuario
  Future<Map<String, dynamic>> getSubscription() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      ).timeout(AppConfig.apiTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error al obtener suscripción: $e');
    }
  }

  /// Cancelar suscripción
  Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cancel-subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      ).timeout(AppConfig.paymentTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error al cancelar suscripción: $e');
    }
  }

  /// Obtener estado del pago en Mercado Pago
  Future<Map<String, dynamic>> getMercadoPagoPaymentStatus({
    required String paymentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mercado-pago/payment/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      ).timeout(AppConfig.paymentTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error al obtener estado de pago: $e');
    }
  }

  /// Crear sesión de pago con Wompi
  Future<Map<String, dynamic>> createWompiSession({
    required String plan,
    required String period,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wompi/create-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'plan': plan, 'period': period}),
      ).timeout(AppConfig.paymentTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error al crear sesión Wompi: $e');
    }
  }

  /// Verificar estado de transacción Wompi
  Future<Map<String, dynamic>> verifyWompiTransaction({
    required String reference,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wompi/transaction/$reference'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      ).timeout(AppConfig.paymentTimeout);

      ApiException.throwIfError(response.statusCode);
      return jsonDecode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw Exception('Error al verificar transacción Wompi: $e');
    }
  }
}
