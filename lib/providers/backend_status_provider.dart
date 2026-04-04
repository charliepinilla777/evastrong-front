import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

enum BackendStatus { checking, online, waking, offline }

class BackendStatusProvider extends ChangeNotifier {
  BackendStatus _status = BackendStatus.checking;
  BackendStatus get status => _status;

  bool get isOnline => _status == BackendStatus.online;
  bool get isVisible =>
      _status == BackendStatus.checking ||
      _status == BackendStatus.waking ||
      _status == BackendStatus.offline;

  // Muestra el banner después de 3s sin respuesta
  static const _showBannerAfter = Duration(seconds: 3);
  // Timeout total del warmup
  static const _totalTimeout = Duration(seconds: 55);

  Future<void> warmup() async {
    _status = BackendStatus.checking;
    notifyListeners();

    // Timer que muestra "despertando" si tarda más de 3s
    final bannerTimer = Timer(_showBannerAfter, () {
      if (_status == BackendStatus.checking) {
        _status = BackendStatus.waking;
        notifyListeners();
      }
    });

    try {
      await http
          .get(Uri.parse('${AppConfig.backendUrl}/health'))
          .timeout(_totalTimeout);
      bannerTimer.cancel();
      _status = BackendStatus.online;
    } catch (_) {
      bannerTimer.cancel();
      _status = BackendStatus.offline;
    }
    notifyListeners();

    // Si quedó offline, reintenta silenciosamente cada 30s
    if (_status == BackendStatus.offline) {
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    Timer(AppConfig.apiTimeout, () async {
      if (_status != BackendStatus.offline) return;
      try {
        await http
            .get(Uri.parse('${AppConfig.backendUrl}/health'))
            .timeout(const Duration(seconds: 15));
        _status = BackendStatus.online;
        notifyListeners();
      } catch (_) {
        _scheduleRetry(); // sigue reintentando
      }
    });
  }
}
