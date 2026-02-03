import 'dart:math';

/// Servicio para gestionar frases motivacionales aleatorias
class MotivationalPhrases {
  static const List<String> _phrases = [
    // Frases originales
    "¡Eres más fuerte de lo que crees!",
    "Cada paso cuenta, no te rindas.",
    "Tu única competencia es la que eras ayer.",
    "El dolor es temporal, el orgullo es para siempre.",
    "Transforma tu cuerpo, cambia tu vida.",
    "Sé la mujer que inspira a otras.",
    "Tu futuro yo te lo agradecerá.",
    "Disciplina es elegir entre lo que quieres ahora y lo que más quieres.",
    "No se trata de ser perfecta, se trata de ser mejor cada día.",
    "Tu cuerpo puede soportar casi cualquier cosa, es tu mente la que debes convencer.",

    // Nuevas 50 frases
    "¡Minutos mágicos al día! Constancia + tú = cuerpo de portada. ¡A brillar! ",
    "Tu sueño corporal espera: solo 5 min diarios. ¡Constancia es tu superpoder!",
    "Simplifica y conquista: minutos de ejercicio para el cuerpo que amas. ",
    "¡Hoy minutos, mañana wow! Dedícate y transforma con constancia pura.",
    "Cuerpo ideal en minutos: tu rutina diaria lo hace posible. ¡Tú lo logras!",
    "Constancia diaria = cambio real. ¡5 min para tu figura soñada!",
    "¡Mujer fuerte! Minutos al día te llevan al cuerpo perfecto. ¡Empieza!",
    "El camino fácil: dedicación mínima, resultados máximos. ¡Tu cuerpo on fire! ",
    "Sueña grande, actúa en minutos. Constancia = tu cuerpo ideal. ",
    "¡Transformación simple! 1 min/día + persistencia = victoria corporal.",
    "Tu cuerpo soñado no es un sueño: minutos diarios lo hacen real. ¡Go!",
    "Constancia en dosis pequeñas: el secreto de tu figura espectacular.",
    "¡5 min hoy cambian todo! Logra lo que deseas con pura dedicación.",
    "Mujeres como tú triunfan con minutos. ¡Cuerpo perfecto incoming!",
    "Dedica poco, gana mucho: constancia para tu mejor versión. ",
    "¡Minutos de poder! Construye tu cuerpo ideal paso a paso.",
    "Constancia diaria: tu boleto al cuerpo que siempre quisiste.",
    "Simplísimo: 5 min al día para brillar con confianza total.",
    "¡Tú puedes! Minutos + constancia = transformación de ensueño.",
    "Cuerpo soñado en modo fácil: dedica minutos y observa la magia.",
    "¡Persiste en minutos! Tu figura perfecta se acerca cada día.",
    "Constancia simple para resultados épicos. ¡Tu cuerpo te lo agradece!",
    "¡5 min de dedicación = cuerpo de diosa! Empieza tu reinado.",
    "Transforma sin excusas: minutos diarios para tu yo ideal.",
    "¡Mujer imparable! Constancia en minutos te da el control.",
    "El hack perfecto: minutos al día para el cuerpo que mereces.",
    "Sueño corporal activado: constancia + rutina simple = sí.",
    "¡Dedícate minutos y conquista! Tu figura wow está lista.",
    "Constancia diaria, cambios eternos. ¡Cuerpo soñado garantizado!",
    "¡Simplifica tu glow up! 5 min para resultados que inspiran.",
    "Tú + minutos + constancia = cuerpo de portada. ¡Hazlo tuyo!",
    "¡Poder en minutos! Logra tu ideal con dedicación fácil.",
    "Cuerpo perfecto: receta de minutos y un toque de persistencia.",
    "¡Hoy invierte minutos, mañana cosecha elogios! ",
    "Constancia en modo mini: máximo impacto en tu figura.",
    "¡Mujeres reales, resultados reales! Minutos para tu sueño.",
    "Transformación accesible: 5 min/día para brillar.",
    "¡Constancia es clave! Minutos que cambian tu silueta.",
    "Tu cuerpo soñado te llama: responde con minutos diarios.",
    "¡Fácil y efectivo! Dedicación mínima para máximo poder.",
    "Persiste en minutos: el camino a tu figura ideal.",
    "¡5 min de magia diaria = cuerpo que enamora! ",
    "Constancia simple: desbloquea tu potencial corporal.",
    "¡Tú lo logras! Minutos para un cambio imparable.",
    "Cuerpo de ensueño: invierte minutos, gana confianza.",
    "¡Dedicación diaria en dosis pequeñas = victoria grande!",
    "Simplifica tu éxito: constancia en minutos para wow.",
    "¡Mujer poderosa, minutos poderosos! Figura perfecta ahead.",
    "Transforma con facilidad: 5 min + tú = sueño realizado.",
    "¡Constancia en minutos! Tu cuerpo ideal es inevitable. ",
    "No necesitas horas en el gym. Minutos de dedicación = cuerpo de ensueño. ¡Siente el poder!",
    "¡Mujer poderosa! Con minutos al día y un poquito de constancia, conquista tu figura ideal.",
    "El secreto: minutos diarios. La magia: tu constancia. Resultado: el cuerpo que amas. ",
    "Simplifica tu camino al éxito: 5 min/día. ¡Tu sueño corporal se hace real con cada repetición!",
    "Tú decides: minutos hoy para un cuerpo wow mañana. ¡Constancia = victoria garantizada!",
    "¡Pequeños minutos, grandes cambios! Logra tu cuerpo soñado con la magia de la rutina diaria.",
  ];

  static final Random _random = Random();

  /// Obtener una frase aleatoria
  static String getRandomPhrase() {
    return _phrases[_random.nextInt(_phrases.length)];
  }

  /// Obtener múltiples frases aleatorias sin repetir
  static List<String> getRandomPhrases(int count) {
    final List<String> shuffled = List.from(_phrases)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Frases por categoría
  static const Map<String, List<String>> _categorizedPhrases = {
    'constancia': [
      "¡Solo 5 minutos al día y constancia! Tu cuerpo soñado está a un clic de distancia. 💪✨",
      "Constancia simple: 1 minuto diario para un cambio eterno. ¡Tu versión ideal te espera!",
      "El secreto: minutos diarios. La magia: tu constancia. Resultado: el cuerpo que amas. 🔥",
      "Tú decides: minutos hoy para un cuerpo wow mañana. ¡Constancia = victoria garantizada!",
      "¡Pequeños minutos, grandes cambios! Logra tu cuerpo soñado con la magia de la rutina diaria.",
    ],
    'transformacion': [
      "Transforma tu figura sin esfuerzo: minutos diarios + tú = el cuerpo que mereces. ¡Empieza ya!",
      "Sueña con ese cuerpo perfecto. Dedícale minutos hoy y hazlo realidad mañana. ¡Tú puedes!",
      "No necesitas horas en el gym. Minutos de dedicación = cuerpo de ensueño. ¡Siente el poder!",
      "Simplifica tu camino al éxito: 5 min/día. ¡Tu sueño corporal se hace real con cada repetición!",
    ],
    'poder': [
      "¡Mujer poderosa! Con minutos al día y un poquito de constancia, conquista tu figura ideal.",
    ],
  };

  /// Obtener frase por categoría
  static String? getPhraseByCategory(String category) {
    final phrases = _categorizedPhrases[category];
    if (phrases == null || phrases.isEmpty) return null;

    return phrases[_random.nextInt(phrases.length)];
  }

  /// Todas las categorías disponibles
  static List<String> get categories => _categorizedPhrases.keys.toList();
}
