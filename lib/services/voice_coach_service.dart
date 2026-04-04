import 'package:flutter_tts/flutter_tts.dart';

/// Servicio de voz entrenadora. Habla en español o inglés según el idioma de la app.
class VoiceCoachService {
  static final VoiceCoachService _instance = VoiceCoachService._internal();
  factory VoiceCoachService() => _instance;
  VoiceCoachService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _muted = false;
  bool _isEnglish = false;

  bool get isMuted => _muted;

  // ─── Inicialización ────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage(_isEnglish ? 'en-US' : 'es-MX');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.05);
      _initialized = true;
    } catch (_) {}
  }

  /// Call this when the app language changes.
  Future<void> setLanguage(String langCode) async {
    _isEnglish = langCode == 'en';
    try {
      await _tts.setLanguage(_isEnglish ? 'en-US' : 'es-MX');
    } catch (_) {}
  }

  void toggleMute() => _muted = !_muted;

  // ─── API pública ───────────────────────────────────────────────────────────

  Future<void> speak(String text) async {
    if (_muted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try { await _tts.stop(); } catch (_) {}
  }

  Future<void> dispose() async {
    try { await _tts.stop(); } catch (_) {}
  }

  // ─── Frases de entrenadora ────────────────────────────────────────────────

  String phaseStart(String phase) {
    if (_isEnglish) {
      switch (phase) {
        case 'calentamiento': return 'Let\'s start the warm-up! Activate your body gently.';
        case 'principal': return 'Excellent! Now the main workout. Let\'s give it everything!';
        case 'enfriamiento': return 'You did it! Now the cool-down. Breathe deep and stretch.';
        default: return 'Let\'s go!';
      }
    }
    switch (phase) {
      case 'calentamiento': return '¡Comenzamos el calentamiento! Activa tu cuerpo suavemente.';
      case 'principal': return '¡Excelente! Ahora la parte principal. Vamos con todo.';
      case 'enfriamiento': return '¡Lo lograste! Ahora el enfriamiento. Respira profundo y estira.';
      default: return '¡Vamos!';
    }
  }

  String exerciseStart(String exerciseName, String? reps) {
    final repsText = (reps != null && reps.isNotEmpty) ? ' $reps.' : '.';
    return _isEnglish
        ? '$exerciseName.$repsText Let\'s go!'
        : '$exerciseName.$repsText ¡Comencemos!';
  }

  String setStart(int currentSet, int totalSets, String? reps) {
    final repsText = (reps != null && reps.isNotEmpty) ? ' $reps.' : '.';
    if (_isEnglish) {
      if (totalSets == 1) return 'Go!$repsText';
      if (currentSet == 1) return 'Set one of $totalSets.$repsText Let\'s go!';
      if (currentSet == totalSets) return 'Last set! Set $currentSet of $totalSets.$repsText Give it everything!';
      return 'Set $currentSet of $totalSets.$repsText Keep going!';
    }
    if (totalSets == 1) return '¡Vamos!$repsText';
    if (currentSet == 1) return 'Serie uno de $totalSets.$repsText ¡Comencemos!';
    if (currentSet == totalSets) return '¡Última serie! Serie $currentSet de $totalSets.$repsText ¡Todo lo que tienes!';
    return 'Serie $currentSet de $totalSets.$repsText ¡Sigue así!';
  }

  String countdown(int seconds) {
    if (_isEnglish) {
      switch (seconds) {
        case 3: return 'Three!';
        case 2: return 'Two!';
        case 1: return 'One!';
        default: return '';
      }
    }
    switch (seconds) {
      case 3: return '¡Tres!';
      case 2: return '¡Dos!';
      case 1: return '¡Uno!';
      default: return '';
    }
  }

  String setRest(int restSeconds, int nextSet, int totalSets) => _isEnglish
      ? 'Great job! Rest $restSeconds seconds. Get ready for set $nextSet.'
      : '¡Muy bien! Descansa $restSeconds segundos. Prepárate para la serie $nextSet.';

  String setRestEnding() => _isEnglish ? 'Get ready!' : '¡Prepárate!';

  String exerciseRest(int restSeconds) => _isEnglish
      ? 'Exercise done! Rest $restSeconds seconds.'
      : '¡Ejercicio completado! Descansa $restSeconds segundos.';

  String phaseTransition(String nextPhase) {
    if (_isEnglish) {
      if (nextPhase == 'principal') return 'Warm-up complete! Get ready for the main workout.';
      if (nextPhase == 'enfriamiento') return 'Main workout done! Time to cool down.';
      return 'Section complete!';
    }
    if (nextPhase == 'principal') return '¡Calentamiento completado! Prepárate para la parte principal.';
    if (nextPhase == 'enfriamiento') return '¡Parte principal completada! Ahora a enfriar.';
    return '¡Sección completada!';
  }

  String midExercise(int setNumber) {
    if (_isEnglish) {
      switch (setNumber % 3) {
        case 0: return 'That\'s it! Feel the burn!';
        case 1: return 'You\'ve got this! Keep your form!';
        default: return 'Amazing! Keep pushing!';
      }
    }
    switch (setNumber % 3) {
      case 0: return '¡Eso es! ¡Siente el trabajo!';
      case 1: return '¡Tú puedes! ¡Mantén la forma!';
      default: return '¡Increíble! ¡Sigue empujando!';
    }
  }

  String completion(int durationMinutes) => _isEnglish
      ? 'Congratulations! You completed $durationMinutes minutes of training. '
        'You\'re amazing! Rest well and come back tomorrow stronger.'
      : '¡Felicitaciones! Completaste $durationMinutes minutos de entrenamiento. '
        '¡Eres increíble! Descansa bien y vuelve mañana más fuerte.';
}
