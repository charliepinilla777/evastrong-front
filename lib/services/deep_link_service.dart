import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();

  factory DeepLinkService() {
    return _instance;
  }

  DeepLinkService._internal();

  StreamSubscription? _deepLinkSubscription;
  final deepLinkStream = StreamController<String>.broadcast();

  /// Inicializar deep links
  void init() {
    _deepLinkSubscription = uriLinkStream.listen(
      (String? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  /// Procesar deep link
  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    debugPrint('Deep link recibido: $link');

    // Ejemplos de rutas:
    // evastrong://payment/success?orderId=123&paymentId=456
    // evastrong://payment/cancel
    // evastrong://payment/pending
    // evastrong://referral/code/ABC123

    if (uri.host == 'payment') {
      final path = uri.path;
      if (path == '/success') {
        final orderId = uri.queryParameters['orderId'];
        final paymentId = uri.queryParameters['paymentId'];
        deepLinkStream.add('payment_success:$orderId:$paymentId');
      } else if (path == '/cancel') {
        deepLinkStream.add('payment_cancel');
      } else if (path == '/pending') {
        deepLinkStream.add('payment_pending');
      }
    } else if (uri.host == 'referral') {
      final code = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      if (code != null) {
        deepLinkStream.add('referral_code:$code');
      }
    }
  }

  /// Escuchar cambios en deep links
  Stream<String> get onDeepLink => deepLinkStream.stream;

  /// Limpiar recursos
  void dispose() {
    _deepLinkSubscription?.cancel();
    deepLinkStream.close();
  }
}
