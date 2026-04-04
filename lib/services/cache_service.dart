import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Caché local con patrón stale-while-revalidate.
/// TTL fresco: 6 horas. Después devuelve datos viejos y refresca en background.
class CacheService {
  static const Duration _freshTtl = Duration(hours: 6);

  // Instancia pre-cargada para evitar await en cada llamada
  static SharedPreferences? _prefs;

  /// Llama esto en main() antes de runApp() para tener la instancia lista.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static String _tsKey(String key) => '__ts_$key';

  // ── Escritura ──────────────────────────────────────────────────────────────

  static Future<void> set(String key, dynamic value) async {
    final prefs = await _getPrefs();
    await prefs.setString(key, jsonEncode(value));
    await prefs.setInt(_tsKey(key), DateTime.now().millisecondsSinceEpoch);
  }

  // ── Lectura ────────────────────────────────────────────────────────────────

  /// Devuelve `{data, isStale}` o `null` si no hay caché.
  static Future<_CacheResult?> get(String key) async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(key);
    if (raw == null) return null;

    final ts = prefs.getInt(_tsKey(key)) ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    final isStale = age > _freshTtl.inMilliseconds;

    return _CacheResult(data: jsonDecode(raw), isStale: isStale);
  }

  // ── Invalidación ──────────────────────────────────────────────────────────

  static Future<void> invalidate(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
    await prefs.remove(_tsKey(key));
  }

  static Future<void> invalidatePrefix(String prefix) async {
    final prefs = await _getPrefs();
    final keys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}

class _CacheResult {
  final dynamic data;
  final bool isStale;
  const _CacheResult({required this.data, required this.isStale});
}
