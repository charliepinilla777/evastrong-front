import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/voice_coach_service.dart';

class LanguageProvider extends ChangeNotifier {
  static const _key = 'eva_language_code';

  Locale _locale = const Locale('es');
  Locale get locale => _locale;

  LanguageProvider() {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null && code != _locale.languageCode) {
        _locale = Locale(code);
        VoiceCoachService().setLanguage(code);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;
    _locale = locale;
    VoiceCoachService().setLanguage(locale.languageCode);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale.languageCode);
    } catch (_) {}
  }

  bool get isEnglish => _locale.languageCode == 'en';
}
