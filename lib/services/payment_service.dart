import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

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
    if (jwtToken == null || jwtToken!.isEmpty) {
      throw Exception('Token JWT no inicializado. Por favor, inicia sesión.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/create-order'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
            body: jsonEncode({'plan': plan, 'period': period}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado al crear orden PayPal');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear orden PayPal: $e');
    }
  }

  /// Capturar pago en PayPal
  Future<Map<String, dynamic>> capturePayPalOrder({
    required String orderId,
  }) async {
    if (jwtToken == null || jwtToken!.isEmpty) {
      throw Exception('Token JWT no inicializado. Por favor, inicia sesión.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/capture-order/$orderId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado al capturar pago');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al capturar pago: $e');
    }
  }

  /// Crear preferencia de pago en Mercado Pago
  Future<Map<String, dynamic>> createMercadoPagoPreference({
    required String plan, // 'basic' | 'premium'
    required String period, // 'monthly' | 'annual'
    String currency = 'COP', // 'COP' | 'USD'
  }) async {
    if (jwtToken == null || jwtToken!.isEmpty) {
      throw Exception('Token JWT no inicializado. Por favor, inicia sesión.');
    }

    try {
      final response = await http
          .post(
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
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado al crear preferencia');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al crear preferencia Mercado Pago: $e');
    }
  }

  /// Obtener suscripción actual del usuario
  Future<Map<String, dynamic>> getSubscription() async {
    if (jwtToken == null || jwtToken!.isEmpty) {
      throw Exception('Token JWT no inicializado. Por favor, inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/subscription'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado al obtener suscripción');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener suscripción: $e');
    }
  }

  /// Cancelar suscripción
  Future<Map<String, dynamic>> cancelSubscription() async {
    if (jwtToken == null || jwtToken!.isEmpty) {
      throw Exception('Token JWT no inicializado. Por favor, inicia sesión.');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/cancel-subscription'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado al cancelar suscripción');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al cancelar suscripción: $e');
    }
  }

  /// Obtener estado del pago en Mercado Pago
  Future<Map<String, dynamic>> getMercadoPagoPaymentStatus({
    required String paymentId,
  }) async {
    if (jwtToken == null || jwtToken!.isEmpty) {
      throw Exception('Token JWT no inicializado. Por favor, inicia sesión.');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/mercado-pago/payment/$paymentId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $jwtToken',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Tiempo de espera agotado al obtener estado de pago');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener estado de pago: $e');
    }
  }
}
