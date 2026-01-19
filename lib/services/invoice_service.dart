import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class InvoiceService {
  static const String baseUrl = 'http://localhost:5000/payments';
  // Para producción: 'https://tu-servicio.onrender.com/payments'

  String? jwtToken;

  InvoiceService({this.jwtToken});

  /// Obtener recibo de pago
  Future<Map<String, dynamic>> getPaymentReceipt({
    required String paymentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receipt/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener recibo: $e');
    }
  }

  /// Descargar PDF del recibo
  Future<File?> downloadReceiptPDF({
    required String paymentId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receipt/$paymentId/download'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/recibo_$paymentId.pdf');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al descargar recibo: $e');
    }
  }

  /// Obtener historial de recibos
  Future<List<Map<String, dynamic>>> getReceiptsHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receipts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['receipts'] ?? []);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }

  /// Enviar recibo por email
  Future<bool> sendReceiptByEmail({
    required String paymentId,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/receipt/$paymentId/send-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al enviar recibo: $e');
    }
  }
}

/// Modelo para un recibo
class Receipt {
  final String id;
  final String paymentId;
  final String plan;
  final String period;
  final double amount;
  final String currency;
  final DateTime paymentDate;
  final String paymentMethod; // 'paypal' | 'mercado_pago'
  final String status; // 'completed' | 'pending' | 'failed'
  final String? transactionId;

  Receipt({
    required this.id,
    required this.paymentId,
    required this.plan,
    required this.period,
    required this.amount,
    required this.currency,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['_id'] ?? '',
      paymentId: json['paymentId'] ?? '',
      plan: json['plan'] ?? '',
      period: json['subscriptionPeriod'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      paymentDate: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      paymentMethod: json['paymentMethod'] ?? 'unknown',
      status: json['status'] ?? 'pending',
      transactionId: json['transactionId'],
    );
  }

  /// Formato para mostrar
  String get formattedAmount {
    return '$amount ${currency == 'COP' ? '\$' : '\$'}';
  }

  String get formattedDate {
    return '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}';
  }

  String get paymentMethodLabel {
    if (paymentMethod == 'paypal') return 'PayPal';
    if (paymentMethod == 'mercado_pago') return 'Mercado Pago';
    return 'Desconocido';
  }

  String get statusLabel {
    if (status == 'completed') return '✅ Completado';
    if (status == 'pending') return '⏳ Pendiente';
    if (status == 'failed') return '❌ Fallido';
    return 'Desconocido';
  }
}
