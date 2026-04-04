/// Servicio de GIFs para ejercicios.
/// Fuente: Wikimedia Commons (dominio público, sin hotlink protection).
class ExerciseGifService {
  static const String _wm = 'https://upload.wikimedia.org/wikipedia/commons';

  // ─── GIFs confirmados y funcionales ─────────────────────────────────────────
  static const String _bridge      = '$_wm/8/8e/Bridge_amp.GIF';
  static const String _squat       = '$_wm/e/e6/Squats.gif';
  static const String _squat2      = '$_wm/4/4f/Squats_wbs.gif';
  static const String _squat3      = '$_wm/e/ed/Agachamento.gif';
  static const String _jumpJacks   = '$_wm/a/a4/Jumpingjacks_wbs.gif';
  static const String _jumpJacks2  = '$_wm/a/ac/Jumpingjacks.gif';
  static const String _pushUp      = '$_wm/d/d4/Pushups_wbs.gif';
  static const String _pushUp2     = '$_wm/8/8f/Pushups.gif';
  static const String _burpee      = '$_wm/0/04/Burpees_WBS.gif';
  static const String _burpee2     = '$_wm/a/ac/Burpees.gif';
  static const String _deadlift    = '$_wm/c/cb/Man_Lifting_Barbell_Deadlift_GIF_Animation_Loop.gif';
  static const String _plankPush   = '$_wm/b/b8/Liegestuetz02_ani_fcm.gif';

  // ─── Mapa exerciseId → GIF ───────────────────────────────────────────────────
  static const Map<String, String> _gifMap = {
    // ── Glúteos y piernas ─────────────────────────────────────────────────
    'PUENTE_GLUTEOS_BASICO':              _bridge,
    'FICHA1_PUENTE_GLUTEOS':             _bridge,
    'PYOGA_PUENTE_SUAVE':                _bridge,
    'PUENTE_GLUTEOS_UNIPODAL':           _bridge,
    'PATADA_GLUTEO_CUADRUPEDIA':         _squat3,
    'FICHA1_PATADA_GLUTEOS_PULSADA':     _squat3,
    'SENTADILLA_SUMO':                   _squat2,
    'SENTADILLA_PLIE':                   _squat2,
    'FICHA1_SENTADILLA_ELEVACION':       _squat,
    'PFB_SENTADILLA_BULGARA':            _squat3,
    'PFB_ZANCADA_REVERSE':               _squat,
    'ABDUCCION_LATERAL_TUMBADA':         _bridge,
    'CAL_ACTIVACION_GLUTEO':             _bridge,
    'E360_CAL_ACTIVACION_GLUTEO_BANDA':  _bridge,
    'E360_PESO_MUERTO_BANDA':            _deadlift,
    'E360_SENTADILLA_PRESS_BANDA':       _squat2,
    'EHIIT_SALTO_CAJÓN':                _squat,
    'SENTADILLA_BRAZOS_ARRIBA':          _squat,

    // ── Calentamiento / Marcha ────────────────────────────────────────────
    'CAL_MARCHA_SUAVE':                  _jumpJacks,
    'FICHA1_CAL_MARCHA_SITIO':           _jumpJacks,
    'FICHA5_CAL_MARCHA_BRAZOS':          _jumpJacks,
    'FICHA6_CAL_MARCHA_LATERAL':         _jumpJacks2,
    'PHIIT_CAL_MARCHA_RAPIDA':           _jumpJacks,
    'EHIIT_CAL_CARRERA_SITIO':           _jumpJacks2,
    'EHIIT_SPRINT_SITIO':                _jumpJacks2,
    'FICHA6_MARCHA_RODILLA_BAJA':        _jumpJacks,
    'FICHA6_PASO_ADELANTE_ATRAS':        _jumpJacks,
    'FICHA6_TOQUES_PUNTA':               _jumpJacks,

    // ── Movilidad y círculos ──────────────────────────────────────────────
    'CAL_CIRCULOS_CADERA':               _jumpJacks2,
    'FICHA1_CAL_CIRCULOS_CADERA':        _jumpJacks2,
    'EHIIT_CAL_CIRCULOS_CADERAS':        _jumpJacks2,
    'PFB_CAL_ROTACION_CADERA':           _jumpJacks2,
    'E360_CAL_MOVILIDAD_CADERA':         _jumpJacks2,
    'FICHA5_CAL_CIRCULOS_BRAZOS':        _jumpJacks,
    'CAL_CIRCULOS_HOMBROS':              _jumpJacks,
    'FICHA6_CAL_ROTACION_TRONCO':        _jumpJacks,
    'CAL_ROTACION_TRONCO':               _jumpJacks,
    'PYOGA_CAL_CIRCULOS_CUELLO':         _jumpJacks,
    'EPIL_CAL_CIRCULOS_PIERNA_TUMBADA':  _bridge,

    // ── Cardio intenso / HIIT ────────────────────────────────────────────
    'PHIIT_CAL_SALTOS_ESTRELLA_SUAVE':   _jumpJacks,
    'PHIIT_JUMPING_JACKS':               _jumpJacks,
    'PFB_CAL_JUMPING_JACKS':             _jumpJacks2,
    'E360_CAL_DINAMICO_COMPLETO':        _jumpJacks,
    'PHIIT_SENTADILLA_SALTO':            _squat,
    'EHIIT_CAL_SENTADILLA_EXPLOSIVA_SUAVE': _squat2,
    'PHIIT_MOUNTAIN_CLIMBER':            _burpee,
    'EHIIT_PLANCHA_RODILLA_PECHO':       _burpee2,
    'PHIIT_BURPEE_MODIFICADO':           _burpee,
    'EHIIT_BURPEE_COMPLETO':             _burpee2,
    'PHIIT_CAL_SENTADILLA_ACTIVACION':   _squat,
    'PFB_CAL_SENTADILLA_CALENTAMIENTO':  _squat,

    // ── Tren superior ────────────────────────────────────────────────────
    'FICHA5_FLEXIONES_PARED':            _pushUp,
    'FLEXIONES_MODIFICADAS':             _pushUp,
    'PFB_FLEXIONES_ESTANDAR':            _pushUp2,
    'FICHA5_REMO_INCLINADO':             _deadlift,
    'E360_REMO_BANDA':                   _deadlift,
    'FICHA5_APERTURAS_CRUZ':             _pushUp,

    // ── Core y estabilidad ───────────────────────────────────────────────
    'PFB_PLANCHA_LATERAL':               _plankPush,
    'E360_PLANCHA_DINAMICA':             _plankPush,
    'PFB_SUPERMAN':                      _bridge,
    'EPIL_SWAN_DIVE':                    _bridge,
    'EPIL_THE_HUNDRED':                  _bridge,
    'EPIL_ROLL_UP':                      _bridge,
    'EPIL_CAL_ROLL_DOWN':                _bridge,
    'EPIL_TIJERAS':                      _bridge,
    'EPIL_SIDE_KICK':                    _bridge,
    'EPIL_TEASER_MOD':                   _bridge,
    'EPIL_GIRO_SIRENA':                  _bridge,
    'E360_ESTOCADA_ROTACION':            _squat3,

    // ── Yoga y estiramiento suave ─────────────────────────────────────────
    'PYOGA_CAL_GATO_VACA':              _bridge,
    'PFB_ESTIR_ESPALDA_SUELO':           _bridge,
    'PYOGA_POSTURA_NINO':                _bridge,
    'EPIL_CHILDS_POSE':                  _bridge,
    'PYOGA_TORSION_SUPINA':              _bridge,
    'PYOGA_PERRO_BOCA_ABAJO_MOD':        _pushUp,
    'PYOGA_GUERRERO_I':                  _squat3,
    'PYOGA_PIERNAS_PARED':               _bridge,
    'PYOGA_SAVASANA':                    _bridge,

    // ── Estiramientos ────────────────────────────────────────────────────
    'FICHA1_ESTIR_ISQUIOS':              _bridge,
    'ESTIR_ISQUIOS_SUELO':               _bridge,
    'EHIIT_ESTIR_ISQUIO_PIE':            _squat3,
    'FICHA1_ESTIR_GLUTEOS':              _bridge,
    'ESTIR_PIGEON_SUELO':                _bridge,
    'PHIIT_ESTIR_CUADRICEPS':            _squat3,
    'PFB_ESTIR_CADERA':                  _bridge,
    'EHIIT_ESTIR_FLEXORES_CADERA':       _bridge,
    'FICHA5_ESTIR_PECHO_PARED':          _pushUp,
    'FICHA6_ESTIR_PANTORRILLAS':         _squat3,
    'E360_ESTIR_TREN_INFERIOR':          _bridge,
    'E360_ESTIR_TREN_SUPERIOR':          _pushUp,

    // ── Respiración y cierre ─────────────────────────────────────────────
    'PYOGA_CAL_RESPIRACION':             _bridge,
    'PHIIT_RESPIRACION_ABDOMINAL':       _bridge,
    'RESPIRACION_CIERRE':                _bridge,
    'EPIL_CAL_RESPIRACION_PILATES':      _bridge,
  };

  // ─── Fallback por tipo de ejercicio ──────────────────────────────────────────
  static const Map<String, String> _typeFallback = {
    'fuerza':         _squat,
    'cardio_suave':   _jumpJacks,
    'cardio_intenso': _burpee,
    'movilidad':      _jumpJacks2,
    'flexibilidad':   _bridge,
    'equilibrio':     _bridge,
    'calentamiento':  _jumpJacks,
    'enfriamiento':   _bridge,
    'general':        _squat,
    'gluteos':        _bridge,
    'cardio':         _jumpJacks2,
    'pilates':        _bridge,
    'yoga':           _bridge,
    'hiit':           _burpee,
  };

  /// Devuelve la URL del GIF. Busca por exerciseId, luego por tipo.
  static String? getGifUrl(String exerciseId, {String exerciseType = ''}) {
    return _gifMap[exerciseId] ?? _typeFallback[exerciseType];
  }

  static bool hasVideo(String? videoUrl) =>
      videoUrl != null && videoUrl.isNotEmpty;
}
