/// Instrucciones paso a paso para cada ejercicio.
/// Mapeadas por exerciseId, con fallback por tipo.
class ExerciseInstructionsService {

  // ─── Instrucciones por grupo de ejercicio ────────────────────────────────────

  static const List<String> _bridge = [
    'Recuéstate boca arriba con las rodillas dobladas y los pies apoyados en el suelo.',
    'Coloca los brazos a los costados del cuerpo con las palmas hacia abajo.',
    'Aprieta los glúteos y eleva las caderas hasta formar una línea recta de rodillas a hombros.',
    'Mantén arriba 1-2 segundos apretando bien, luego baja lentamente.',
  ];

  static const List<String> _donkeyKick = [
    'Colócate en cuadrupedia: manos bajo los hombros y rodillas bajo las caderas.',
    'Mantén la espalda recta como una tabla y el abdomen contraído.',
    'Extiende una pierna hacia atrás a la altura de la cadera sin arquear la espalda.',
    'Pulsa el talón hacia el techo apretando el glúteo. Repite del mismo lado.',
  ];

  static const List<String> _squat = [
    'Párate con pies al ancho de hombros y punta los pies ligeramente hacia afuera.',
    'Mantén el pecho erguido y los abdominales activados.',
    'Baja doblando rodillas y caderas como si fueras a sentarte, sin que las rodillas sobrepasen los dedos de los pies.',
    'Sube empujando con los talones y aprieta los glúteos al llegar arriba.',
  ];

  static const List<String> _sumoSquat = [
    'Párate con los pies más abiertos que el ancho de hombros, punta los pies 45° hacia afuera.',
    'Mantén el pecho erguido, los abdominales activos y la espalda recta.',
    'Baja doblando las rodillas hacia afuera (en dirección a los pies), sin que sobrepasen los dedos.',
    'Empuja con los talones para subir y aprieta glúteos e internos al llegar arriba.',
  ];

  static const List<String> _lunge = [
    'Da un paso grande hacia atrás con una pierna y baja la rodilla trasera casi al suelo.',
    'Mantén el torso erguido y la rodilla delantera alineada con el tobillo.',
    'La rodilla delantera no debe sobrepasar los dedos del pie.',
    'Empuja con el pie delantero para volver a la posición inicial. Alterna piernas.',
  ];

  static const List<String> _march = [
    'Párate derecha con los pies juntos y los hombros relajados.',
    'Eleva las rodillas alternando como si marcharas, al ritmo del temporizador.',
    'Balancea los brazos de forma natural para activar también el tren superior.',
    'Mantén el abdomen ligeramente contraído durante todo el movimiento.',
  ];

  static const List<String> _hipCircles = [
    'Párate con pies al ancho de hombros y manos en las caderas.',
    'Dibuja círculos lentos y amplios con las caderas, como si usaras un aro.',
    'Realiza la mitad del tiempo en sentido horario y la otra mitad en sentido antihorario.',
    'Mantén los hombros estables y solo mueve la zona de la cadera.',
  ];

  static const List<String> _armCircles = [
    'Párate con los pies al ancho de hombros y extiende los brazos a los lados.',
    'Realiza círculos lentos con los brazos hacia adelante durante la mitad del tiempo.',
    'Luego cambia y haz los círculos hacia atrás.',
    'Ve aumentando el tamaño de los círculos para calentar bien los hombros.',
  ];

  static const List<String> _jumpingJacks = [
    'Párate con pies juntos y brazos a los costados.',
    'Salta abriendo las piernas al ancho de hombros mientras subes los brazos por encima de la cabeza.',
    'Salta de regreso cerrando las piernas y bajando los brazos simultáneamente.',
    'Aterriza suavemente con las rodillas ligeramente flexionadas y mantén un ritmo constante.',
  ];

  static const List<String> _mountainClimber = [
    'Comienza en posición de plancha alta con los brazos extendidos y el cuerpo en línea recta.',
    'Activa el core para que la cadera no suba ni baje durante el ejercicio.',
    'Lleva una rodilla hacia el pecho de forma rápida y vuelve al inicio.',
    'Alterna las piernas en un movimiento de carrera continuo. Respira de forma constante.',
  ];

  static const List<String> _burpee = [
    'Párate con pies al ancho de hombros.',
    'Baja las manos al suelo y lleva los pies atrás a posición de plancha.',
    'Realiza una flexión (completa) o toca el pecho al suelo (modificado).',
    'Salta los pies hacia las manos, levántate y salta con los brazos arriba.',
  ];

  static const List<String> _wallPushUp = [
    'Párate frente a una pared, coloca las palmas a la altura del pecho, al ancho de los hombros.',
    'Da un paso atrás para inclinarte ligeramente hacia la pared.',
    'Dobla los codos llevando el pecho hacia la pared de forma controlada.',
    'Empuja de vuelta extendiendo los brazos. Mantén el cuerpo en línea recta.',
  ];

  static const List<String> _pushUp = [
    'Colócate en posición de plancha alta con las manos ligeramente más anchas que los hombros.',
    'Mantén el cuerpo en línea recta de cabeza a talones, el core activo.',
    'Baja doblando los codos hasta que el pecho casi toque el suelo.',
    'Empuja hacia arriba extendiendo los brazos. Inhala al bajar, exhala al subir.',
  ];

  static const List<String> _row = [
    'Inclínate hacia adelante a 45° con las rodillas ligeramente flexionadas y la espalda recta.',
    'Sujeta las mancuernas o banda con los brazos extendidos hacia el suelo.',
    'Lleva los codos hacia atrás doblando los brazos y acercando las pesas a la cintura.',
    'Aprieta los músculos de la espalda arriba y baja lentamente de forma controlada.',
  ];

  static const List<String> _lateralRaise = [
    'Párate o siéntate con una mancuerna en cada mano a los costados del cuerpo.',
    'Levanta los brazos hacia los lados a la altura de los hombros con los codos ligeramente doblados.',
    'Mantén 1 segundo arriba sin subir los hombros hacia las orejas.',
    'Baja de forma lenta y controlada. El movimiento debe ser fluido.',
  ];

  static const List<String> _sidePlank = [
    'Recuéstate de lado apoyada en un antebrazo directamente bajo el hombro.',
    'Apila los pies uno sobre otro o apoya la rodilla inferior para la versión modificada.',
    'Eleva la cadera formando una línea recta de cabeza a pies.',
    'Mantén el abdomen apretado y respira de forma constante durante el tiempo indicado.',
  ];

  static const List<String> _superman = [
    'Recuéstate boca abajo con los brazos extendidos frente a ti y las piernas juntas.',
    'Aprieta los glúteos y el core.',
    'Levanta simultáneamente brazos, pecho y piernas del suelo.',
    'Mantén la posición 2 segundos y baja lentamente. Mira hacia el suelo, no al frente.',
  ];

  static const List<String> _catCow = [
    'Colócate en cuadrupedia con manos bajo hombros y rodillas bajo caderas.',
    'Inhala: arquea la espalda bajando el abdomen y mirando al frente (postura vaca).',
    'Exhala: redondea la espalda hacia el techo como un gato, hundiendo el abdomen.',
    'Alterna suavemente entre las dos posturas al ritmo de tu respiración.',
  ];

  static const List<String> _childPose = [
    'Arrodíllate y siéntate sobre los talones con las rodillas juntas o ligeramente abiertas.',
    'Inclina el torso hacia adelante extendiendo los brazos frente a ti.',
    'Relaja la frente sobre el suelo y deja caer los hombros.',
    'Respira profundo hacia la espalda y mantén la postura todo el tiempo indicado.',
  ];

  static const List<String> _supineSpinalTwist = [
    'Recuéstate boca arriba con los brazos en cruz a los lados.',
    'Dobla una rodilla y llévala al lado contrario del cuerpo dejándola caer al suelo.',
    'Gira la cabeza en dirección opuesta a la rodilla para aumentar la torsión.',
    'Respira profundo y en cada exhalación profundiza suavemente el estiramiento.',
  ];

  static const List<String> _downwardDog = [
    'Comienza en cuadrupedia con manos ligeramente adelantadas de los hombros.',
    'Presiona las palmas y levanta las rodillas del suelo estirando las piernas.',
    'Forma una "V" invertida llevando las caderas hacia el techo.',
    'Presiona los talones hacia el suelo y relaja la cabeza entre los brazos.',
  ];

  static const List<String> _warrior = [
    'Da un paso grande hacia adelante con una pierna y gira el pie trasero 45°.',
    'Dobla la rodilla delantera hasta 90° alineada con el tobillo.',
    'Eleva los brazos por encima de la cabeza con las palmas enfrentadas.',
    'Mantén el torso erguido, los hombros lejos de las orejas y respira profundo.',
  ];

  static const List<String> _legsUpWall = [
    'Siéntate de lado junto a una pared y gira el cuerpo llevando las piernas hacia arriba.',
    'Extiende las piernas verticalmente apoyándolas en la pared.',
    'Relaja los brazos a los costados con las palmas hacia arriba.',
    'Cierra los ojos y respira profundo. Mantén la postura todo el tiempo indicado.',
  ];

  static const List<String> _savasana = [
    'Recuéstate boca arriba con piernas extendidas y brazos separados del cuerpo.',
    'Deja que los pies caigan naturalmente hacia afuera.',
    'Cierra los ojos y relaja completamente cada parte del cuerpo, de los pies a la cabeza.',
    'Respira de forma natural sin controlar. Simplemente descansa y observa.',
  ];

  static const List<String> _hamstringStretch = [
    'Siéntate en el suelo con una pierna extendida y la otra doblada.',
    'Mantén la espalda recta e inclínate hacia adelante desde la cadera.',
    'Llega hasta donde puedas sin doblar la rodilla ni redondear la espalda.',
    'Respira profundo y en cada exhalación avanza un poco más. Mantén y cambia de pierna.',
  ];

  static const List<String> _gluteStretch = [
    'Recuéstate boca arriba con las piernas dobladas.',
    'Cruza un tobillo sobre la rodilla contraria en forma de figura 4.',
    'Lleva ambas piernas hacia el pecho hasta sentir el estiramiento en el glúteo.',
    'Sostén con las manos detrás del muslo y respira profundo. Cambia de lado.',
  ];

  static const List<String> _quadStretch = [
    'Párate apoyada en una pared o silla si necesitas equilibrio.',
    'Dobla una rodilla llevando el talón hacia los glúteos y sostén el pie con la mano.',
    'Mantén las rodillas juntas y el torso erguido.',
    'Siente el estiramiento en la parte delantera del muslo. Mantén y cambia.',
  ];

  static const List<String> _chestStretch = [
    'Párate junto a una pared y apoya el antebrazo verticalmente en ella.',
    'Gira lentamente el cuerpo en dirección contraria al brazo apoyado.',
    'Siente el estiramiento en el pecho y el hombro anterior.',
    'Mantén la postura respirando profundo. Repite del otro lado.',
  ];

  static const List<String> _breathing = [
    'Siéntate cómodamente o recuéstate boca arriba con los ojos cerrados.',
    'Coloca una mano en el pecho y otra en el abdomen.',
    'Inhala lentamente por la nariz durante 4 tiempos, llenando primero el abdomen.',
    'Exhala por la boca durante 6-8 tiempos vaciando completamente los pulmones.',
  ];

  static const List<String> _deadlift = [
    'Párate con los pies al ancho de caderas, banda o pesas frente a ti.',
    'Mantén la espalda recta, el pecho erguido y una leve curva lumbar natural.',
    'Bisagra en la cadera llevando el torso hacia adelante, bajando las manos por las piernas.',
    'Aprieta glúteos e isquiotibiales para volver arriba. El movimiento viene de la cadera.',
  ];

  static const List<String> _plank = [
    'Comienza en posición de plancha alta con los brazos extendidos.',
    'Baja un brazo a la vez al antebrazo para quedar en plancha baja.',
    'Luego sube de nuevo un brazo a la vez a plancha alta.',
    'Alterna el brazo que baja primero y mantén la cadera completamente estable.',
  ];

  static const List<String> _pilatesHundred = [
    'Recuéstate boca arriba, lleva las piernas a 45° y el cuello y hombros levantados.',
    'Extiende los brazos paralelos al suelo a los costados del cuerpo.',
    'Bombea los brazos hacia arriba y abajo en movimientos pequeños y rápidos.',
    'Inhala 5 bombeos, exhala 5 bombeos. Completa 100 bombeos en total.',
  ];

  static const List<String> _rollUp = [
    'Recuéstate boca arriba con piernas extendidas y brazos por encima de la cabeza.',
    'Inhala para preparar; exhala y sube lentamente vértebra por vértebra.',
    'Al llegar sentada, inclínate suavemente hacia las piernas.',
    'Vuelve a bajar lentamente vértebra por vértebra. El movimiento es articulado, no brusco.',
  ];

  static const List<String> _pilatesScissors = [
    'Recuéstate boca arriba, levanta ambas piernas a 90° y sube el cuello y hombros.',
    'Lleva una pierna hacia el pecho sosteniendo el tobillo y aleja la otra a 45°.',
    'Alterna en un movimiento de tijera continuo.',
    'Mantén el lower back pegado al suelo y el core muy activo durante todo el ejercicio.',
  ];

  static const List<String> _teaser = [
    'Recuéstate boca arriba con rodillas dobladas o piernas extendidas (avanzado).',
    'Extiende los brazos hacia los pies.',
    'Sube simultáneamente el torso y las piernas formando una "V".',
    'Mantén el equilibrio en el cóccix 2 segundos y baja articuladamente.',
  ];

  static const List<String> _mermaid = [
    'Siéntate de lado con las piernas dobladas hacia un lado.',
    'Extiende el brazo de arriba por encima de la cabeza y alarga el lateral del cuerpo.',
    'Inclínate hacia el lado contrario sintiendo el estiramiento en el costado.',
    'Vuelve al centro y repite del mismo lado antes de cambiar.',
  ];

  static const List<String> _neckCircles = [
    'Siéntate o párate cómodamente con la espalda recta.',
    'Inclina la cabeza hacia la derecha con cuidado, llevando la oreja al hombro.',
    'Lleva el mentón al pecho y rueda hacia el lado izquierdo.',
    'Realiza el movimiento lento y suave. Nunca hagas círculos completos hacia atrás.',
  ];

  static const List<String> _rotationLunge = [
    'Da un paso adelante con una pierna y baja en zancada hasta que ambas rodillas formen 90°.',
    'Con los brazos extendidos al frente, gira el torso hacia el lado de la pierna delantera.',
    'Vuelve al centro y empuja con el pie delantero para regresar a la posición inicial.',
    'Alterna piernas en cada repetición manteniendo el core activo.',
  ];

  static const List<String> _bandWalk = [
    'Colócate de pie con la banda de resistencia en los tobillos o rodillas.',
    'Realiza pasos laterales pequeños manteniendo la tensión en la banda.',
    'Mantén la espalda recta, rodillas ligeramente dobladas y core activo.',
    'Avanza varios pasos hacia un lado y luego regresa al otro.',
  ];

  static const List<String> _boxJump = [
    'Párate frente a una superficie estable a una distancia cómoda.',
    'Flexiona ligeramente las rodillas y usa los brazos para tomar impulso.',
    'Salta aterrizando con ambos pies encima de la superficie, rodillas flexionadas.',
    'Baja de forma controlada (sin saltar hacia atrás) y repite.',
  ];

  // ─── Mapa exerciseId → instrucciones ────────────────────────────────────────

  static final Map<String, List<String>> _map = {
    // Glúteos - Puente
    'PUENTE_GLUTEOS_BASICO':             _bridge,
    'FICHA1_PUENTE_GLUTEOS':             _bridge,
    'PYOGA_PUENTE_SUAVE':                _bridge,
    'CAL_ACTIVACION_GLUTEO':             _bridge,
    'E360_CAL_ACTIVACION_GLUTEO_BANDA':  _bandWalk,

    // Glúteos - Patada
    'PATADA_GLUTEO_CUADRUPEDIA':         _donkeyKick,
    'FICHA1_PATADA_GLUTEOS_PULSADA':     _donkeyKick,

    // Glúteos - Puente unipodal
    'PUENTE_GLUTEOS_UNIPODAL': [
      'Recuéstate boca arriba con rodillas dobladas y levanta una pierna extendida.',
      'Aprieta el glúteo de la pierna de apoyo y eleva la cadera.',
      'Mantén la cadera nivelada, sin dejar caer el lado de la pierna levantada.',
      'Baja lentamente y repite del mismo lado antes de cambiar.',
    ],

    // Abducción lateral
    'ABDUCCION_LATERAL_TUMBADA': [
      'Recuéstate de lado con el cuerpo en línea recta y la cabeza apoyada en el brazo.',
      'Mantén el core activado y la cadera completamente estable.',
      'Levanta la pierna de arriba a la altura de la cadera con el pie en punta o flex.',
      'Baja lentamente sin dejar que la pierna toque a la otra. Controla el movimiento.',
    ],

    // Sentadillas
    'SENTADILLA_SUMO':                   _sumoSquat,
    'SENTADILLA_PLIE':                   _sumoSquat,
    'FICHA1_SENTADILLA_ELEVACION':       _squat,
    'E360_SENTADILLA_PRESS_BANDA':       _squat,
    'SENTADILLA_BRAZOS_ARRIBA':          _squat,
    'PHIIT_CAL_SENTADILLA_ACTIVACION':   _squat,
    'PFB_CAL_SENTADILLA_CALENTAMIENTO':  _squat,

    // Sentadilla búlgara
    'PFB_SENTADILLA_BULGARA': [
      'Párate de espaldas a una silla o banco y apoya el empeine del pie trasero en él.',
      'Da un paso adelante con el pie de apoyo y mantén el torso erguido.',
      'Baja doblando la rodilla delantera hasta 90°, sin que sobrepase el pie.',
      'Empuja con el talón delantero para volver arriba. Termina las repeticiones y cambia.',
    ],

    // Zancadas
    'PFB_ZANCADA_REVERSE':               _lunge,
    'E360_ESTOCADA_ROTACION':            _rotationLunge,

    // Sentadilla con salto
    'PHIIT_SENTADILLA_SALTO':            [
      'Párate en posición de sentadilla con pies al ancho de hombros.',
      'Baja en sentadilla profunda manteniendo el pecho erguido.',
      'Desde la posición baja, salta de forma explosiva elevando los brazos.',
      'Aterriza suavemente regresando directamente a la posición de sentadilla.',
    ],
    'EHIIT_CAL_SENTADILLA_EXPLOSIVA_SUAVE': _squat,

    // Peso muerto
    'E360_PESO_MUERTO_BANDA':            _deadlift,

    // Salto cajón
    'EHIIT_SALTO_CAJÓN':                _boxJump,

    // Marcha
    'CAL_MARCHA_SUAVE':                  _march,
    'FICHA1_CAL_MARCHA_SITIO':           _march,
    'FICHA5_CAL_MARCHA_BRAZOS':          _march,
    'FICHA6_CAL_MARCHA_LATERAL':         _march,
    'PHIIT_CAL_MARCHA_RAPIDA':           _march,
    'FICHA6_MARCHA_RODILLA_BAJA':        _march,
    'FICHA6_PASO_ADELANTE_ATRAS':        _march,
    'FICHA6_TOQUES_PUNTA':               _march,
    'EHIIT_CAL_CARRERA_SITIO':           [
      'Párate con los pies al ancho de caderas.',
      'Corre en el sitio levantando las rodillas a la altura de la cadera.',
      'Aumenta la velocidad progresivamente manteniendo los brazos activos.',
      'Aterriza suavemente en la parte delantera del pie para proteger las rodillas.',
    ],
    'EHIIT_SPRINT_SITIO': [
      'Párate con los pies al ancho de caderas y el cuerpo ligeramente inclinado hacia adelante.',
      'Corre en el sitio a máxima velocidad durante el intervalo marcado.',
      'Levanta bien las rodillas y usa los brazos con energía.',
      'Mantén la respiración constante y los abdominales activos.',
    ],

    // Movilidad
    'CAL_CIRCULOS_CADERA':               _hipCircles,
    'FICHA1_CAL_CIRCULOS_CADERA':        _hipCircles,
    'EHIIT_CAL_CIRCULOS_CADERAS':        _hipCircles,
    'PFB_CAL_ROTACION_CADERA':           _hipCircles,
    'E360_CAL_MOVILIDAD_CADERA':         _hipCircles,
    'FICHA5_CAL_CIRCULOS_BRAZOS':        _armCircles,
    'CAL_CIRCULOS_HOMBROS':              _armCircles,
    'FICHA6_CAL_ROTACION_TRONCO': [
      'Párate con pies al ancho de hombros y brazos extendidos al frente.',
      'Gira el torso hacia la derecha llevando los brazos en esa dirección.',
      'Vuelve al centro y gira hacia la izquierda de forma controlada.',
      'Mantén las caderas mirando al frente: el movimiento es solo del tronco.',
    ],
    'CAL_ROTACION_TRONCO': [
      'Párate con pies al ancho de hombros y brazos extendidos al frente.',
      'Gira el torso hacia la derecha llevando los brazos en esa dirección.',
      'Vuelve al centro y gira hacia la izquierda de forma controlada.',
      'Mantén las caderas mirando al frente: el movimiento es solo del tronco.',
    ],
    'PYOGA_CAL_CIRCULOS_CUELLO':         _neckCircles,
    'EPIL_CAL_CIRCULOS_PIERNA_TUMBADA': [
      'Recuéstate boca arriba con una pierna extendida en el suelo y la otra levantada a 90°.',
      'Dibuja círculos lentos y controlados con la pierna levantada.',
      'Mantén la pelvis completamente estable: no debe moverse con la pierna.',
      'Realiza la mitad de los círculos en cada dirección y cambia de pierna.',
    ],

    // Cardio / HIIT
    'PHIIT_JUMPING_JACKS':               _jumpingJacks,
    'PFB_CAL_JUMPING_JACKS':             _jumpingJacks,
    'E360_CAL_DINAMICO_COMPLETO':        _jumpingJacks,
    'PHIIT_CAL_SALTOS_ESTRELLA_SUAVE':   _jumpingJacks,
    'PHIIT_MOUNTAIN_CLIMBER':            _mountainClimber,
    'EHIIT_PLANCHA_RODILLA_PECHO':       _mountainClimber,
    'PHIIT_BURPEE_MODIFICADO':           _burpee,
    'EHIIT_BURPEE_COMPLETO':             _burpee,

    // Tren superior
    'FICHA5_FLEXIONES_PARED':            _wallPushUp,
    'FLEXIONES_MODIFICADAS':             _wallPushUp,
    'PFB_FLEXIONES_ESTANDAR':            _pushUp,
    'FICHA5_REMO_INCLINADO':             _row,
    'E360_REMO_BANDA':                   _row,
    'FICHA5_APERTURAS_CRUZ':             _lateralRaise,

    // Core
    'PFB_PLANCHA_LATERAL':               _sidePlank,
    'E360_PLANCHA_DINAMICA':             _plank,
    'PFB_SUPERMAN':                      _superman,
    'EPIL_SWAN_DIVE':                    _superman,
    'EPIL_THE_HUNDRED':                  _pilatesHundred,
    'EPIL_ROLL_UP':                      _rollUp,
    'EPIL_CAL_ROLL_DOWN':                _rollUp,
    'EPIL_TIJERAS':                      _pilatesScissors,
    'EPIL_SIDE_KICK': [
      'Recuéstate de lado con el cuerpo en línea recta y la cabeza apoyada en el brazo.',
      'Mantén el core activado y la cadera estable.',
      'Lleva la pierna de arriba hacia adelante y luego hacia atrás en un movimiento controlado.',
      'Mantén la pelvis fija: el movimiento es solo de la pierna.',
    ],
    'EPIL_TEASER_MOD':                   _teaser,
    'EPIL_GIRO_SIRENA':                  _mermaid,

    // Yoga
    'PYOGA_CAL_GATO_VACA':              _catCow,
    'PFB_ESTIR_ESPALDA_SUELO':           _catCow,
    'PYOGA_POSTURA_NINO':                _childPose,
    'EPIL_CHILDS_POSE':                  _childPose,
    'PYOGA_TORSION_SUPINA':              _supineSpinalTwist,
    'PYOGA_PERRO_BOCA_ABAJO_MOD':        _downwardDog,
    'PYOGA_GUERRERO_I':                  _warrior,
    'PYOGA_PIERNAS_PARED':               _legsUpWall,
    'PYOGA_SAVASANA':                    _savasana,

    // Estiramientos
    'FICHA1_ESTIR_ISQUIOS':              _hamstringStretch,
    'ESTIR_ISQUIOS_SUELO':               _hamstringStretch,
    'EHIIT_ESTIR_ISQUIO_PIE': [
      'Párate con los pies juntos y extiende una pierna al frente con el talón en el suelo.',
      'Apoya las manos en la pierna doblada de apoyo e inclínate levemente.',
      'Siente el estiramiento en la parte trasera del muslo.',
      'Mantén la postura respirando profundo y cambia de pierna.',
    ],
    'FICHA1_ESTIR_GLUTEOS':              _gluteStretch,
    'ESTIR_PIGEON_SUELO':                _gluteStretch,
    'PFB_ESTIR_CADERA':                  _gluteStretch,
    'EHIIT_ESTIR_FLEXORES_CADERA':       _gluteStretch,
    'PHIIT_ESTIR_CUADRICEPS':            _quadStretch,
    'FICHA6_ESTIR_PANTORRILLAS': [
      'Párate frente a una pared apoyando las manos en ella.',
      'Da un paso grande hacia atrás con una pierna, manteniéndola extendida.',
      'Presiona el talón trasero hacia el suelo y flexiona ligeramente la rodilla delantera.',
      'Siente el estiramiento en la pantorrilla trasera. Mantén y cambia.',
    ],
    'FICHA5_ESTIR_PECHO_PARED':          _chestStretch,
    'E360_ESTIR_TREN_SUPERIOR':          _chestStretch,
    'E360_ESTIR_TREN_INFERIOR': [
      'Siéntate en el suelo con ambas piernas extendidas al frente.',
      'Flexiona los pies (punta hacia ti) y mantén la espalda recta.',
      'Inclínate hacia adelante desde la cadera alcanzando los pies o espinillas.',
      'Mantén la postura sin rebotar y respira profundo hacia la espalda.',
    ],

    // Respiración
    'PYOGA_CAL_RESPIRACION':             _breathing,
    'PHIIT_RESPIRACION_ABDOMINAL':       _breathing,
    'RESPIRACION_CIERRE':                _breathing,
    'EPIL_CAL_RESPIRACION_PILATES':      _breathing,
  };

  // ─── Fallback por tipo ───────────────────────────────────────────────────────

  static const Map<String, List<String>> _typeFallback = {
    'fuerza': [
      'Colócate en la posición inicial correcta con la espalda recta y el core activo.',
      'Realiza el movimiento de forma lenta y controlada, sin usar impulso.',
      'Lleva el músculo al punto de mayor contracción y mantén 1 segundo.',
      'Regresa a la posición inicial de forma lenta. La calidad vale más que la velocidad.',
    ],
    'cardio_suave': [
      'Comienza a un ritmo cómodo que te permita hablar sin dificultad.',
      'Mantén los abdominales ligeramente activos durante todo el movimiento.',
      'Respira de forma constante: no aguantes la respiración.',
      'Si sientes demasiado esfuerzo, reduce el ritmo. Este es tu calentamiento.',
    ],
    'cardio_intenso': [
      'Realiza el movimiento a la máxima intensidad que puedas mantener con buena forma.',
      'Mantén el core activo para proteger la espalda durante el esfuerzo.',
      'Respira de forma rítmica: no aguantes la respiración.',
      'Si necesitas modificar para cuidar las articulaciones, ¡hazlo sin dudar!',
    ],
    'movilidad': [
      'Realiza el movimiento de forma lenta, suave y completamente controlada.',
      'No fuerces el rango de movimiento: llega hasta donde tu cuerpo te permita hoy.',
      'Usa la respiración: inhala para preparar y exhala para profundizar el movimiento.',
      'El objetivo es lubricar las articulaciones, no el dolor.',
    ],
    'flexibilidad': [
      'Entra en el estiramiento de forma suave, sin rebotes.',
      'Mantén la posición de manera estática durante el tiempo indicado.',
      'Respira profundo: en cada exhalación relaja el músculo y profundiza un poco más.',
      'Siente tensión, no dolor. Si duele, reduce la intensidad.',
    ],
    'equilibrio': [
      'Elige un punto fijo frente a ti para mantener la concentración y el equilibrio.',
      'Activa el core y los músculos del pie de apoyo para estabilizarte.',
      'Si necesitas apoyo, acércate a la pared o silla sin problema.',
      'El equilibrio mejora con la práctica. Cada intento cuenta.',
    ],
    'calentamiento': [
      'Muévete a un ritmo suave para elevar gradualmente la temperatura corporal.',
      'Respira de forma constante y relajada durante todo el movimiento.',
      'Siente cómo los músculos se despiertan progresivamente.',
      'Este es el momento de preparar tu cuerpo: sin carreras, sin prisas.',
    ],
    'enfriamiento': [
      'Realiza el movimiento de forma muy suave, aprovechando el calor muscular.',
      'Mantén cada posición con calma y respira profundo.',
      'Esta es tu recompensa por el esfuerzo: permítete descansar.',
      'Siente cómo el cuerpo se va relajando progresivamente.',
    ],
  };

  /// Retorna la lista de instrucciones para un exerciseId dado.
  static List<String> getInstructions(
    String exerciseId, {
    String exerciseType = '',
    String lang = 'es',
  }) {
    if (lang == 'en') {
      return _mapEn[exerciseId] ??
          _typeFallbackEn[exerciseType] ??
          _typeFallbackEn['fuerza']!;
    }
    return _map[exerciseId] ??
        _typeFallback[exerciseType] ??
        _typeFallback['fuerza']!;
  }

  /// Translates a Spanish exercise name to English.
  static String translateName(String name) =>
      _nameMap[name] ?? name;

  /// Translates a Spanish exercise shortDescription to English.
  static String translateShortDesc(String desc) =>
      _descMap[desc] ?? desc;

  // ─── English name map ────────────────────────────────────────────────────
  static const Map<String, String> _nameMap = {
    'Respiración Activadora':       'Activating Breath',
    'Crunches Quema Grasa':         'Fat-Burn Crunches',
    'Plancha Cintura de Sirena':    'Mermaid Side Plank',
    'Estiramiento Abdominal':       'Abdominal Stretch',
    'Activación Glútea':            'Glute Activation',
    'Sentadillas Brasileñas':       'Brazilian Squats',
    'Hip Thrust Explosivo':         'Explosive Hip Thrust',
    'Patada de Burro':              'Donkey Kick',
    'Estiramiento Glúteo Profundo': 'Deep Glute Stretch',
    'Cardio Activador':             'Cardio Activation',
    'Lunges Anti-Celulitis':        'Anti-Cellulite Lunges',
    'Puente Glúteo Pulsante':       'Pulsing Glute Bridge',
    'Masaje Circulatorio':          'Circulatory Massage',
    // Additional seed names
    'Sentadilla Sumo':              'Sumo Squat',
    'Peso Muerto Rumano':           'Romanian Deadlift',
    'Abducción de Cadera':          'Hip Abduction',
    'Marcha con Rodillas Altas':    'High Knee March',
    'Flexiones Modificadas':        'Modified Push-ups',
    'Plancha Dinámica':             'Dynamic Plank',
    'Crunch Bicicleta':             'Bicycle Crunch',
    'Superman':                     'Superman',
    'Gato-Vaca':                    'Cat-Cow',
    'Perro Boca Abajo':             'Downward Dog',
    'Guerrero I':                   'Warrior I',
    'Torsión Supina':               'Supine Spinal Twist',
    'Piernas en la Pared':          'Legs Up the Wall',
    'Estiramiento de Cuádriceps':   'Quad Stretch',
    'Estiramiento de Pecho':        'Chest Stretch',
    'Respiración Final':            'Final Breathing',
    'Zancada Alternada':            'Alternating Lunge',
    'Sentadilla con Pausa':         'Pause Squat',
    'Hip Thrust':                   'Hip Thrust',
    'Patada Lateral':               'Side Kick',
    'Extensión de Glúteo':          'Glute Extension',
    'Circles de Cadera':            'Hip Circles',
    'Abdominales en V':             'V-Abs',
    'Plancha con Toque de Hombro':  'Shoulder-Tap Plank',
    'Sentadilla Isométrica':        'Isometric Squat Hold',
    'Curl de Bíceps':               'Bicep Curl',
    'Press de Tríceps':             'Tricep Press',
    'Remo con Banda':               'Band Row',
    'Apertura de Hombros':          'Shoulder Opener',
    'Rotaciones de Cintura':        'Waist Rotations',
    'Twists Rusas':                 'Russian Twists',
    'Plancha Lateral de Sirena':    'Mermaid Side Plank',
    'Estiramiento Lateral':         'Side Stretch',
    'Círculos de Brazos':           'Arm Circles',
    'Curl de Bíceps Femenino':      'Bicep Curl',
    'Tríceps Adiós Flacidez':       'Tricep Kickback',
    'Estiramiento de Brazos':       'Arm Stretch',
    'Saltos Activadores':           'Activation Jumps',
    'Burpees Modificados':          'Modified Burpees',
    'Mountain Climbers Explosivos': 'Mountain Climbers',
    'Recuperación Activa':          'Active Recovery',
    'Respiración Consciente':       'Mindful Breathing',
    'Estiramiento de Isquiotibiales': 'Hamstring Stretch',
    'Apertura de Caderas':          'Hip Opener',
    'Postura del Niño':             'Child\'s Pose',
    // Cool-down / DB names
    'Enfriamiento y estiramientos': 'Cool-down & Stretching',
    'Estiramiento final':           'Final Stretch',
    'Vuelta a la calma':            'Cool-down',
    // Common DB names
    'Calentamiento general':        'General Warm-up',
    'Marcha suave en el sitio':     'Gentle March in Place',
    'Movilidad de hombros y cadera':'Shoulder & Hip Mobility',
    'Sentadilla media':             'Half Squat',
    'Puente de glúteos':            'Glute Bridge',
    'Plancha apoyando rodillas':    'Modified Plank',
    'Paso lateral dinámico':        'Dynamic Side Step',
    'Elevación de talones':         'Calf Raise',
    'Movilidad de hombros':         'Shoulder Mobility',
    'Estocada con giro':            'Rotation Lunge',
    'Sentadilla sumo':              'Sumo Squat',
    'Peso muerto rumano':           'Romanian Deadlift',
    'Marcha con rodillas altas':    'High Knee March',
    'Círculos de caderas':          'Hip Circles',
    'Flexiones de pared':           'Wall Push-ups',
    'Remo con banda':               'Band Row',
    'Plancha':                      'Plank',
    'Zancada alternada':            'Alternating Lunge',
    'Abdominales clásicos':         'Classic Crunches',
    'Plancha lateral':              'Side Plank',
    'Extensión de espalda':         'Back Extension',
    'Perro boca abajo':             'Downward Dog',
    'Guerrero I':                   'Warrior I',
    'Torsión supina':               'Supine Twist',
    'Piernas en la pared':          'Legs Up the Wall',
    'Savasana':                     'Savasana',
  };

  static const Map<String, String> _descMap = {
    'Activa tu metabolismo con respiración profunda':     'Activate your metabolism with deep breathing',
    'Abdominales tradicionales con técnica correcta':     'Classic crunches with correct technique',
    'Alarga y define la cintura':                         'Lengthens and defines the waist',
    'Despierta tus glúteos antes del entrenamiento':      'Wake up your glutes before the workout',
    'El secreto de las brasileñas para glúteos perfectos':'The Brazilian secret for perfect glutes',
    'Máxima activación glútea':                           'Maximum glute activation',
    'Aísla y define cada glúteo':                         'Isolates and defines each glute',
    'Activación profunda contra la celulitis':            'Deep activation against cellulite',
    'Eleva el ritmo cardíaco':                            'Raises your heart rate',
    'Estimula drenaje linfático':                         'Stimulates lymphatic drainage',
    'Fortalece todo el core':                             'Strengthens the entire core',
    'Tonifica los costados':                              'Tones the sides',
    'Define oblicuos y reduce cintura':                   'Defines obliques and reduces waist',
    'Calienta hombros y brazos':                          'Warms up shoulders and arms',
    'Define bíceps sin agrandar':                         'Defines biceps without bulk',
    'Elimina la flacidez bajo el brazo':                  'Eliminates underarm flabbiness',
    'Relaja los músculos trabajados':                     'Relaxes the muscles worked',
    'Máxima quema de calorías':                           'Maximum calorie burn',
    'Máxima quema de calorías en poco tiempo':            'Maximum calorie burn in a short time',
    'Normaliza ritmo cardíaco':                           'Normalizes heart rate',
    'Alarga la parte posterior de las piernas':           'Lengthens the back of the legs',
    'Libera tensión en caderas':                          'Releases hip tension',
    'Relaja y alarga músculos':                           'Relaxes and lengthens muscles',
    'Relajación profunda':                                'Deep relaxation',
    'Prepara cuerpo y mente':                             'Prepares body and mind',
    'Activa la circulación en todo el cuerpo':            'Activates circulation throughout the body',
    'Calienta la zona de trabajo':                        'Warms up the target area',
    'Previene dolor y mejora recuperación':               'Prevents pain and improves recovery',
    'Quema grasa abdominal':                              'Burns abdominal fat',
    'Movilidad articular y activación muscular':          'Joint mobility and muscle activation',
    'Estiramientos suaves para recuperación':             'Gentle stretches for recovery',
    'Estiramiento y recuperación':                        'Stretching and recovery',
    'Relaja el cuerpo después del entrenamiento':         'Relax your body after training',
    'Normaliza el ritmo cardíaco':                        'Normalizes your heart rate',
    'Recuperación y flexibilidad':                        'Recovery and flexibility',
    'Caminar en el mismo lugar moviendo brazos.':         'Walk in place moving arms.',
    'Círculos de hombros y cadera a ritmo suave.':        'Shoulder and hip circles at a slow pace.',
    'Flexiona rodillas sin bajar demasiado, espalda recta.': 'Bend knees without going too low, back straight.',
    'Tumbada boca arriba, eleva caderas apretando glúteos.': 'Lying on your back, lift hips squeezing glutes.',
    'Apoya antebrazos y rodillas, mantiene abdomen firme.':  'Rest forearms and knees, keep abs firm.',
    'Paso a un lado y al otro moviendo brazos.':          'Step side to side swinging arms.',
    'De pie, sube y baja talones, sujetándose si hace falta.': 'Standing, rise and lower heels, hold support if needed.',
  };

  // ─── English instruction lists ───────────────────────────────────────────
  static const List<String> _bridgeEn = [
    'Lie on your back with knees bent and feet flat on the floor.',
    'Place your arms at your sides with palms facing down.',
    'Squeeze your glutes and lift your hips until your body forms a straight line from knees to shoulders.',
    'Hold at the top for 1–2 seconds squeezing hard, then slowly lower back down.',
  ];
  static const List<String> _donkeyKickEn = [
    'Start on all fours: hands under shoulders, knees under hips.',
    'Keep your back flat like a table and your abs engaged.',
    'Extend one leg straight back to hip height without arching your back.',
    'Pulse the heel toward the ceiling squeezing your glute. Repeat on the same side.',
  ];
  static const List<String> _squatEn = [
    'Stand with feet shoulder-width apart and toes slightly turned out.',
    'Keep your chest tall and core engaged.',
    'Lower down bending knees and hips as if sitting, keeping knees behind toes.',
    'Drive through your heels to stand and squeeze your glutes at the top.',
  ];
  static const List<String> _sumoSquatEn = [
    'Stand with feet wider than shoulder-width, toes turned out 45°.',
    'Keep chest tall, core active, and back straight.',
    'Lower down bending knees outward (in line with toes) without them passing the toes.',
    'Push through heels to rise and squeeze glutes and inner thighs at the top.',
  ];
  static const List<String> _lungeEn = [
    'Step one foot back and lower the back knee toward the floor.',
    'Keep your torso upright and front knee aligned over your ankle.',
    'Front knee should not pass your toes.',
    'Push through your front foot to return to start. Alternate legs.',
  ];
  static const List<String> _marchEn = [
    'Stand tall with feet together and shoulders relaxed.',
    'Lift your knees alternately as if marching, keeping pace with the timer.',
    'Swing your arms naturally to activate the upper body too.',
    'Keep your abs lightly engaged throughout the movement.',
  ];
  static const List<String> _hipCirclesEn = [
    'Stand with feet shoulder-width apart and hands on hips.',
    'Draw slow, wide circles with your hips, as if using a hula hoop.',
    'Spend half the time clockwise and the other half counterclockwise.',
    'Keep your shoulders stable — only your hips should move.',
  ];
  static const List<String> _armCirclesEn = [
    'Stand with feet shoulder-width apart and arms extended to the sides.',
    'Make slow circles forward for half the time.',
    'Then reverse direction for the remaining time.',
    'Gradually increase circle size to fully warm up your shoulders.',
  ];
  static const List<String> _jumpingJacksEn = [
    'Stand with feet together and arms at your sides.',
    'Jump, spreading your legs to shoulder-width while raising arms overhead.',
    'Jump back to start, bringing feet together and arms down simultaneously.',
    'Land softly with knees slightly bent and maintain a steady rhythm.',
  ];
  static const List<String> _mountainClimberEn = [
    'Start in a high plank with arms extended and body in a straight line.',
    'Engage your core to keep hips from rising or sagging.',
    'Drive one knee quickly toward your chest, then return to start.',
    'Alternate legs in a running motion. Breathe steadily throughout.',
  ];
  static const List<String> _burpeeEn = [
    'Stand with feet shoulder-width apart.',
    'Place hands on the floor and jump feet back to a plank position.',
    'Do a push-up (full) or lower chest to the floor (modified).',
    'Jump feet toward hands, stand up, and jump with arms overhead.',
  ];
  static const List<String> _wallPushUpEn = [
    'Stand facing a wall, palms at chest height, shoulder-width apart.',
    'Step back slightly to lean toward the wall.',
    'Bend elbows and bring your chest toward the wall in a controlled motion.',
    'Push back to the start extending your arms. Keep your body in a straight line.',
  ];
  static const List<String> _pushUpEn = [
    'Start in a high plank with hands slightly wider than your shoulders.',
    'Keep your body in a straight line from head to heels, core engaged.',
    'Lower by bending elbows until your chest nearly touches the floor.',
    'Push back up extending your arms. Inhale down, exhale up.',
  ];
  static const List<String> _rowEn = [
    'Hinge forward at 45° with knees slightly bent and back flat.',
    'Hold weights or a band with arms extended toward the floor.',
    'Pull elbows back, drawing the weight toward your waist.',
    'Squeeze your back muscles at the top, then lower slowly and controlled.',
  ];
  static const List<String> _lateralRaiseEn = [
    'Stand or sit with a dumbbell in each hand at your sides.',
    'Raise arms out to the sides to shoulder height with elbows slightly bent.',
    'Hold 1 second at the top without shrugging your shoulders.',
    'Lower slowly and controlled. Keep the movement fluid.',
  ];
  static const List<String> _sidePlankEn = [
    'Lie on your side propped on your forearm directly under your shoulder.',
    'Stack your feet or rest the bottom knee down for a modified version.',
    'Lift your hips to form a straight line from head to feet.',
    'Keep your abs tight and breathe steadily throughout.',
  ];
  static const List<String> _supermanEn = [
    'Lie face down with arms extended in front of you and legs together.',
    'Squeeze your glutes and core.',
    'Simultaneously lift your arms, chest, and legs off the floor.',
    'Hold 2 seconds and lower slowly. Keep your gaze down, not forward.',
  ];
  static const List<String> _catCowEn = [
    'Start on all fours with hands under shoulders and knees under hips.',
    'Inhale: arch your back, lower your belly, and look forward (cow).',
    'Exhale: round your back toward the ceiling like a cat, drawing in your abs.',
    'Flow gently between the two positions with your breathing.',
  ];
  static const List<String> _childPoseEn = [
    'Kneel and sit back on your heels with knees together or slightly apart.',
    'Lean your torso forward, extending arms in front of you.',
    'Rest your forehead on the floor and let your shoulders drop.',
    'Breathe deeply into your back and hold for the full time indicated.',
  ];
  static const List<String> _supineSpinalTwistEn = [
    'Lie on your back with arms extended to the sides.',
    'Bend one knee and let it drop across your body to the floor.',
    'Turn your head in the opposite direction of the knee.',
    'Breathe deeply and on each exhale gently deepen the stretch.',
  ];
  static const List<String> _downwardDogEn = [
    'Start on all fours with hands slightly in front of your shoulders.',
    'Press your palms and lift your knees to straighten your legs.',
    'Form an inverted "V" by pushing your hips toward the ceiling.',
    'Press your heels toward the floor and relax your head between your arms.',
  ];
  static const List<String> _warriorEn = [
    'Step one foot far forward and turn the back foot out 45°.',
    'Bend your front knee to 90°, aligned over the ankle.',
    'Raise arms overhead with palms facing each other.',
    'Keep your torso upright, shoulders away from ears, and breathe deeply.',
  ];
  static const List<String> _legsUpWallEn = [
    'Sit sideways next to a wall and swing your legs up against it.',
    'Extend your legs vertically resting them on the wall.',
    'Relax your arms at your sides with palms facing up.',
    'Close your eyes and breathe deeply. Hold for the full time indicated.',
  ];
  static const List<String> _savasanaEn = [
    'Lie on your back with legs extended and arms slightly away from your body.',
    'Let your feet fall naturally outward.',
    'Close your eyes and fully relax each part of your body from feet to head.',
    'Breathe naturally without controlling it. Simply rest and observe.',
  ];
  static const List<String> _hamstringStretchEn = [
    'Sit on the floor with one leg extended and the other bent.',
    'Keep your back straight and hinge forward from your hips.',
    'Reach as far as you can without bending the knee or rounding your back.',
    'Breathe deeply and advance slightly with each exhale. Hold and switch legs.',
  ];
  static const List<String> _gluteStretchEn = [
    'Lie on your back with knees bent.',
    'Cross one ankle over the opposite knee in a figure-4 shape.',
    'Draw both legs toward your chest until you feel the stretch in your glute.',
    'Hold with hands behind the thigh and breathe deeply. Switch sides.',
  ];
  static const List<String> _quadStretchEn = [
    'Stand near a wall or chair for balance if needed.',
    'Bend one knee bringing your heel toward your glutes and hold your foot.',
    'Keep knees together and your torso upright.',
    'Feel the stretch in the front of your thigh. Hold and switch sides.',
  ];
  static const List<String> _chestStretchEn = [
    'Stand next to a wall and rest your forearm vertically against it.',
    'Slowly rotate your body away from the supported arm.',
    'Feel the stretch in your chest and front shoulder.',
    'Hold while breathing deeply. Repeat on the other side.',
  ];
  static const List<String> _breathingEn = [
    'Sit comfortably or lie on your back with eyes closed.',
    'Place one hand on your chest and the other on your abdomen.',
    'Slowly inhale through your nose for 4 counts, filling your belly first.',
    'Exhale through your mouth for 6–8 counts, fully emptying your lungs.',
  ];
  static const List<String> _deadliftEn = [
    'Stand with feet hip-width apart, band or weights in front of you.',
    'Keep your back straight, chest tall, and a natural lumbar curve.',
    'Hinge at the hips, lowering your torso forward with hands sliding down your legs.',
    'Squeeze glutes and hamstrings to stand back up. The movement comes from the hips.',
  ];
  static const List<String> _plankEn = [
    'Start in a high plank with arms extended.',
    'Lower one arm at a time to your forearm for a low plank.',
    'Then press back up one arm at a time to a high plank.',
    'Alternate which arm goes down first and keep your hips completely still.',
  ];
  static const List<String> _pilatesHundredEn = [
    'Lie on your back, lift legs to 45°, and raise neck and shoulders off the floor.',
    'Extend arms parallel to the floor beside your body.',
    'Pump arms up and down in small, rapid movements.',
    'Inhale for 5 pumps, exhale for 5 pumps. Complete 100 pumps total.',
  ];
  static const List<String> _rollUpEn = [
    'Lie on your back with legs extended and arms overhead.',
    'Inhale to prepare; exhale and slowly roll up one vertebra at a time.',
    'Once seated, gently reach toward your legs.',
    'Slowly roll back down one vertebra at a time. The movement is articulated, not abrupt.',
  ];
  static const List<String> _pilatesScissorsEn = [
    'Lie on your back, raise both legs to 90°, and lift neck and shoulders.',
    'Bring one leg toward your chest holding the ankle and lower the other to 45°.',
    'Alternate in a continuous scissor motion.',
    'Keep your lower back pressed to the floor and core very active throughout.',
  ];
  static const List<String> _teaserEn = [
    'Lie on your back with knees bent or legs extended (advanced).',
    'Extend your arms toward your feet.',
    'Simultaneously raise torso and legs into a "V" shape.',
    'Balance on your tailbone for 2 seconds, then lower with control.',
  ];
  static const List<String> _mermaidEn = [
    'Sit sideways with legs folded to one side.',
    'Extend the top arm overhead and lengthen the side of your body.',
    'Lean toward the opposite side feeling the stretch along your flank.',
    'Return to center and repeat on the same side before switching.',
  ];
  static const List<String> _neckCirclesEn = [
    'Sit or stand comfortably with your spine straight.',
    'Gently tilt your head to the right, bringing your ear toward your shoulder.',
    'Roll your chin to your chest and over to the left.',
    'Keep the movement slow and smooth. Never do full circles dropping the head back.',
  ];
  static const List<String> _rotationLungeEn = [
    'Step one foot forward into a lunge lowering until both knees reach 90°.',
    'With arms extended in front, rotate your torso toward the front leg.',
    'Return to center and push off the front foot back to start.',
    'Alternate legs each rep, keeping your core active throughout.',
  ];
  static const List<String> _bandWalkEn = [
    'Stand with a resistance band around your ankles or just above your knees.',
    'Take small steps sideways keeping tension on the band.',
    'Keep back straight, knees slightly bent, and core engaged.',
    'Walk several steps in one direction, then return the other way.',
  ];
  static const List<String> _boxJumpEn = [
    'Stand in front of a stable surface at a comfortable distance.',
    'Slightly bend your knees and use your arms for momentum.',
    'Jump, landing with both feet on the surface, knees bent.',
    'Step down in a controlled way (do not jump backward) and repeat.',
  ];

  // ─── English exerciseId map ───────────────────────────────────────────────
  static final Map<String, List<String>> _mapEn = {
    'PUENTE_GLUTEOS':            _bridgeEn,
    'FICHA1_PUENTE_GLUTEOS':     _bridgeEn,
    'FICHA2_PUENTE_GLUTEOS':     _bridgeEn,
    'FICHA3_PUENTE_GLUTEOS':     _bridgeEn,
    'FICHA4_PUENTE_GLUTEOS':     _bridgeEn,
    'FICHA5_PUENTE_GLUTEOS':     _bridgeEn,
    'FICHA6_PUENTE_GLUTEOS':     _bridgeEn,
    'PGLUT_PUENTE':              _bridgeEn,
    'PGLUT_HIP_THRUST':          _bridgeEn,
    'FICHA1_PATADA_BURRO':       _donkeyKickEn,
    'FICHA2_PATADA_BURRO':       _donkeyKickEn,
    'FICHA3_PATADA_BURRO':       _donkeyKickEn,
    'PGLUT_PATADA_BURRO':        _donkeyKickEn,
    'SENTADILLA_MEDIA':          _squatEn,
    'FICHA1_SENTADILLA':         _squatEn,
    'FICHA2_SENTADILLA':         _squatEn,
    'FICHA3_SENTADILLA':         _squatEn,
    'FICHA4_SENTADILLA':         _squatEn,
    'FICHA5_SENTADILLA':         _squatEn,
    'FICHA6_SENTADILLA':         _squatEn,
    'PGLUT_SENTADILLA_SUMO':     _sumoSquatEn,
    'ESTOCADA_SENTADILLA_SUMO':  _sumoSquatEn,
    'FICHA1_ESTOCADA':           _lungeEn,
    'FICHA2_ESTOCADA':           _lungeEn,
    'FICHA3_ESTOCADA':           _lungeEn,
    'FICHA4_ESTOCADA':           _lungeEn,
    'CAL_MARCHA_SUAVE':          _marchEn,
    'CAL_MARCHA_RODILLAS':       _marchEn,
    'E360_CAL_MARCHA_RODILLAS':  _marchEn,
    'PHIIT_CAL_MARCHA_ACTIVA':   _marchEn,
    'CAL_MOV_ART':               _hipCirclesEn,
    'CAL_CIRCULOS_CADERAS':      _hipCirclesEn,
    'CAL_CIRCULOS_BRAZOS':       _armCirclesEn,
    'PGLUT_CAL_CIRCULOS_BRAZOS': _armCirclesEn,
    'PHIIT_JUMPING_JACKS':       _jumpingJacksEn,
    'PFB_CAL_JUMPING_JACKS':     _jumpingJacksEn,
    'E360_CAL_DINAMICO_COMPLETO':_jumpingJacksEn,
    'PHIIT_CAL_SALTOS_ESTRELLA_SUAVE': _jumpingJacksEn,
    'PHIIT_MOUNTAIN_CLIMBER':    _mountainClimberEn,
    'EHIIT_PLANCHA_RODILLA_PECHO':_mountainClimberEn,
    'PHIIT_BURPEE_MODIFICADO':   _burpeeEn,
    'EHIIT_BURPEE_COMPLETO':     _burpeeEn,
    'FICHA5_FLEXIONES_PARED':    _wallPushUpEn,
    'FLEXIONES_MODIFICADAS':     _wallPushUpEn,
    'PFB_FLEXIONES_ESTANDAR':    _pushUpEn,
    'FICHA5_REMO_INCLINADO':     _rowEn,
    'E360_REMO_BANDA':           _rowEn,
    'FICHA5_APERTURAS_CRUZ':     _lateralRaiseEn,
    'PFB_PLANCHA_LATERAL':       _sidePlankEn,
    'E360_PLANCHA_DINAMICA':     _plankEn,
    'PFB_SUPERMAN':              _supermanEn,
    'EPIL_SWAN_DIVE':            _supermanEn,
    'EPIL_THE_HUNDRED':          _pilatesHundredEn,
    'EPIL_ROLL_UP':              _rollUpEn,
    'EPIL_CAL_ROLL_DOWN':        _rollUpEn,
    'EPIL_TIJERAS':              _pilatesScissorsEn,
    'EPIL_TEASER_MOD':           _teaserEn,
    'EPIL_GIRO_SIRENA':          _mermaidEn,
    'PYOGA_CAL_GATO_VACA':       _catCowEn,
    'PFB_ESTIR_ESPALDA_SUELO':   _catCowEn,
    'PYOGA_POSTURA_NINO':        _childPoseEn,
    'EPIL_CHILDS_POSE':          _childPoseEn,
    'PYOGA_TORSION_SUPINA':      _supineSpinalTwistEn,
    'PYOGA_PERRO_BOCA_ABAJO_MOD':_downwardDogEn,
    'PYOGA_GUERRERO_I':          _warriorEn,
    'PYOGA_PIERNAS_PARED':       _legsUpWallEn,
    'PYOGA_SAVASANA':            _savasanaEn,
    'FICHA1_ESTIR_ISQUIOS':      _hamstringStretchEn,
    'ESTIR_ISQUIOS_SUELO':       _hamstringStretchEn,
    'FICHA1_ESTIR_GLUTEOS':      _gluteStretchEn,
    'ESTIR_PIGEON_SUELO':        _gluteStretchEn,
    'PFB_ESTIR_CADERA':          _gluteStretchEn,
    'EHIIT_ESTIR_FLEXORES_CADERA':_gluteStretchEn,
    'PHIIT_ESTIR_CUADRICEPS':    _quadStretchEn,
    'FICHA5_ESTIR_PECHO_PARED':  _chestStretchEn,
    'E360_ESTIR_TREN_SUPERIOR':  _chestStretchEn,
    'PYOGA_CAL_RESPIRACION':     _breathingEn,
    'PHIIT_RESPIRACION_ABDOMINAL':_breathingEn,
    'RESPIRACION_CIERRE':        _breathingEn,
    'EPIL_CAL_RESPIRACION_PILATES':_breathingEn,
    'PYOGA_CAL_CIRCULOS_CUELLO': _neckCirclesEn,
  };

  // ─── English type fallback ────────────────────────────────────────────────
  static const Map<String, List<String>> _typeFallbackEn = {
    'fuerza': [
      'Set up in the correct starting position with your back straight and core engaged.',
      'Perform the movement slowly and controlled, without using momentum.',
      'Bring the muscle to its peak contraction and hold for 1 second.',
      'Return to the starting position slowly. Quality is more important than speed.',
    ],
    'cardio_suave': [
      'Start at a comfortable pace that lets you speak without difficulty.',
      'Keep your abs lightly engaged throughout the movement.',
      'Breathe steadily — do not hold your breath.',
      'If it feels too hard, slow down. This is your warm-up.',
    ],
    'cardio_intenso': [
      'Move at the highest intensity you can maintain with good form.',
      'Keep your core engaged to protect your back under effort.',
      'Breathe rhythmically — do not hold your breath.',
      'If you need to modify to protect your joints, do it without hesitation!',
    ],
    'movilidad': [
      'Move slowly, smoothly, and with complete control.',
      'Do not force your range of motion — go as far as your body allows today.',
      'Use your breath: inhale to prepare and exhale to deepen the movement.',
      'The goal is to lubricate the joints, not to feel pain.',
    ],
    'flexibilidad': [
      'Enter the stretch gently, without bouncing.',
      'Hold the position statically for the indicated time.',
      'Breathe deeply — with each exhale, relax the muscle and go a little deeper.',
      'Feel tension, not pain. If it hurts, reduce the intensity.',
    ],
    'equilibrio': [
      'Pick a fixed point in front of you to maintain focus and balance.',
      'Engage your core and the muscles of the supporting foot to stabilize.',
      'If you need support, move near a wall or chair — no problem.',
      'Balance improves with practice. Every attempt counts.',
    ],
    'calentamiento': [
      'Move at a gentle pace to gradually raise your core temperature.',
      'Breathe steadily and relaxed throughout.',
      'Feel your muscles progressively waking up.',
      'This is the time to prepare your body — no rushing.',
    ],
    'enfriamiento': [
      'Move very gently, taking advantage of the warmth in your muscles.',
      'Hold each position calmly and breathe deeply.',
      'This is your reward for the effort — allow yourself to rest.',
      'Feel your body gradually relaxing.',
    ],
  };
}
