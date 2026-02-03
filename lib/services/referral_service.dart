import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';

class ReferralService {
  // Usar configuración centralizada
  static String get baseUrl => AppConfig.paymentsUrl;

  String? jwtToken;

  ReferralService({this.jwtToken});

  /// Obtener código referral del usuario
  Future<Map<String, dynamic>> getMyReferralCode() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/my-code'),
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
      throw Exception('Error al obtener código: $e');
    }
  }

  /// Generar nuevo código referral
  Future<Map<String, dynamic>> generateNewReferralCode() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/referral/generate-code'),
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
      throw Exception('Error: $e');
    }
  }

  /// Canjear código referral
  Future<Map<String, dynamic>> redeemReferralCode({
    required String referralCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/referral/redeem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'referralCode': referralCode}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtener estadísticas de referrals
  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/stats'),
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
      throw Exception('Error: $e');
    }
  }

  /// Obtener lista de referrals realizados
  Future<List<Map<String, dynamic>>> getMyReferrals() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/my-referrals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['referrals'] ?? []);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtener historial de bonificaciones
  Future<List<Map<String, dynamic>>> getBonusHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/bonus-history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['bonuses'] ?? []);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtener saldo de referral disponible
  Future<Map<String, dynamic>> getReferralBalance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/balance'),
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
      throw Exception('Error: $e');
    }
  }

  /// Aplicar saldo de referral al pago
  Future<Map<String, dynamic>> applyReferralBalance({
    required double amountToApply,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/referral/apply-balance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'amount': amountToApply}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Obtener términos del programa de referrals
  Future<Map<String, dynamic>> getReferralTerms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/referral/terms'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

/// Modelo para un referral
class Referral {
  final String id;
  final String referrerUserId;
  final String referredUserId;
  final String referredEmail;
  final String referredName;
  final DateTime referralDate;
  final DateTime? conversionDate;
  final bool isConverted;
  final double bonusAmount;
  final String bonusCurrency;

  Referral({
    required this.id,
    required this.referrerUserId,
    required this.referredUserId,
    required this.referredEmail,
    required this.referredName,
    required this.referralDate,
    this.conversionDate,
    required this.isConverted,
    required this.bonusAmount,
    required this.bonusCurrency,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['_id'] ?? '',
      referrerUserId: json['referrerUserId'] ?? '',
      referredUserId: json['referredUserId'] ?? '',
      referredEmail: json['referredEmail'] ?? '',
      referredName: json['referredName'] ?? '',
      referralDate: DateTime.parse(
        json['referralDate'] ?? DateTime.now().toString(),
      ),
      conversionDate: json['conversionDate'] != null
          ? DateTime.parse(json['conversionDate'])
          : null,
      isConverted: json['isConverted'] ?? false,
      bonusAmount: (json['bonusAmount'] ?? 0).toDouble(),
      bonusCurrency: json['bonusCurrency'] ?? 'USD',
    );
  }

  String get statusLabel {
    if (isConverted) return '✅ Convertido';
    return '⏳ Pendiente';
  }

  String get formattedBonus {
    return '$bonusAmount $bonusCurrency';
  }
}

/// Modelo para estadísticas de referral
class ReferralStats {
  final int totalReferrals;
  final int convertedReferrals;
  final double totalBonusEarned;
  final String bonusCurrency;
  final double conversionRate;
  final double averageBonusPerReferral;

  ReferralStats({
    required this.totalReferrals,
    required this.convertedReferrals,
    required this.totalBonusEarned,
    required this.bonusCurrency,
    required this.conversionRate,
    required this.averageBonusPerReferral,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      totalReferrals: json['totalReferrals'] ?? 0,
      convertedReferrals: json['convertedReferrals'] ?? 0,
      totalBonusEarned: (json['totalBonusEarned'] ?? 0).toDouble(),
      bonusCurrency: json['bonusCurrency'] ?? 'USD',
      conversionRate: (json['conversionRate'] ?? 0).toDouble(),
      averageBonusPerReferral: (json['averageBonusPerReferral'] ?? 0)
          .toDouble(),
    );
  }
}
