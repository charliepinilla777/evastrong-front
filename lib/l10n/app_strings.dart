import 'package:flutter/material.dart';

/// Cadenas traducibles. Uso: AppStrings.of(context).home
class AppStrings {
  final bool _en;
  AppStrings._(this._en);

  factory AppStrings.of(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return AppStrings._(lang == 'en');
  }

  String t(String es, String en) => _en ? en : es;
  String get languageCode => _en ? 'en' : 'es';

  // ── Drawer / Navegación ──────────────────────────────────────────────────
  String get home         => t('Inicio', 'Home');
  String get routines     => t('Rutinas', 'Routines');
  String get diets        => t('Dietas & Recetas', 'Diets & Recipes');
  String get contact      => t('Contacto', 'Contact');
  String get achievements => t('Logros', 'Achievements');
  String get chat         => t('Chat', 'Chat');
  String get profile      => t('Perfil', 'Profile');
  String get feedback     => t('Déjanos tus comentarios', 'Share your feedback');
  String get settings     => t('Configuración', 'Settings');

  // ── Tabs inferiores ──────────────────────────────────────────────────────
  String get tabHome     => t('Inicio', 'Home');
  String get tabRoutines => t('Rutinas', 'Routines');
  String get tabDiets    => t('Dietas', 'Diets');
  String get tabContact  => t('Contacto', 'Contact');

  // ── Configuración ────────────────────────────────────────────────────────
  String get settingsTitle    => t('Configuración', 'Settings');
  String get languageSection  => t('Idioma', 'Language');
  String get languageSubtitle => t('Elige el idioma de la aplicación', 'Choose the app language');
  String get langSpanish      => t('Español', 'Spanish');
  String get langEnglish      => t('Inglés', 'English');
  String get languageChanged  => t('Idioma cambiado a Inglés', 'Language changed to Spanish');

  // ── Común ────────────────────────────────────────────────────────────────
  String get save         => t('Guardar Cambios', 'Save Changes');
  String get cancel       => t('Cancelar', 'Cancel');
  String get close        => t('Cerrar', 'Close');
  String get retry        => t('Reintentar', 'Retry');
  String get loading      => t('Cargando...', 'Loading...');
  String get error        => t('Error', 'Error');
  String get noConnection => t('Sin conexión', 'No connection');
  String get viewPlans    => t('Ver Planes', 'View Plans');
  String get begin        => t('Comenzar', 'Begin');
  String get finish       => t('Finalizar', 'Finish');
  String get repeat       => t('Repetir', 'Repeat');
  String get exit         => t('Salir', 'Exit');
  String get demonstration => t('Demostración', 'Demonstration');
  String get notNow       => t('Ahora no', 'Not now');
  String get seeAll       => t('Ver todo', 'See all');
  String get seeArrow     => t('Ver →', 'See →');
  String get description  => t('Descripción', 'Description');
  String get featured     => t('⭐ Destacada', '⭐ Featured');
  String get noRecipesInCategory => t('No hay recetas en esta categoría', 'No recipes in this category');

  // ── Home screen ──────────────────────────────────────────────────────────
  String get appName           => t('Eva Strong', 'Eva Strong');
  String get motivationalTitle => t('EVA EVOLUCIONA', 'EVA EVOLVES');
  String get homeTagline => t(
    'Evastrong: transforma tu cuerpo con minutos al día,\ncuida tu salud y enamórate de\nla mujer fuerte que ya eres.',
    'Evastrong: transform your body in minutes a day,\ntake care of your health and fall in love with\nthe strong woman you already are.',
  );
  String get contactSubtitle => t('Síguenos en nuestras redes', 'Follow us on social media');
  String get subscriptionTitle => t('Elige tu Plan', 'Choose your Plan');
  String get trainBtn          => t('Entrenar', 'Train');
  String get achievementsBtn   => t('Logros', 'Achievements');
  String get serverWaking      => t('☕ Despertando el servidor, un momento...', '☕ Waking up the server, just a moment...');
  String get serverOffline     => t('😔 Sin conexión al servidor. Mostrando datos guardados.', '😔 Server unreachable. Showing saved data.');

  // ── Saludo (rutinas) ─────────────────────────────────────────────────────
  String get goodMorning   => t('Buenos días', 'Good morning');
  String get goodAfternoon => t('Buenas tardes', 'Good afternoon');
  String get goodEvening   => t('Buenas noches', 'Good evening');
  String get thisWeek      => t('Esta semana', 'This week');
  String get yourProfile   => t('Tu Perfil', 'Your Profile');
  String get noActiveStreak => t('Sin racha activa', 'No active streak');
  String streakDays(int n) =>
      t('$n día${n == 1 ? '' : 's'} seguidos', '$n day${n == 1 ? '' : 's'} in a row');
  String daysTrainedThisWeek(int n) =>
      t('$n de 7 días entrenados esta semana', '$n out of 7 days trained this week');
  String cycleLabel(int current, int total) =>
      t('Ciclo $current/$total', 'Cycle $current/$total');
  String goalLabel(int mins) => t('Meta: $mins min', 'Goal: $mins min');
  String intervalLabel(int current, int total) =>
      t('$current / $total intervalos', '$current / $total intervals');

  // ── Rutinas tabs ─────────────────────────────────────────────────────────
  String get tabForYou    => t('Para Ti', 'For You');
  String get tabAll       => t('Todas', 'All');
  String get tabFavorites => t('Favoritas', 'Favorites');
  String get tabHistory   => t('Historial', 'History');
  String get tabExplore   => t('Explorar', 'Explore');

  String get myRoutines        => t('Mis Rutinas', 'My Routines');
  String get forYou            => t('Para Ti', 'For You');
  String get all               => t('Todas', 'All');
  String get favorites         => t('Favoritas', 'Favorites');
  String get history           => t('Historial', 'History');
  String get explore           => t('Explorar', 'Explore');
  String get startRoutine      => t('¡Empezar rutina!', 'Start workout!');
  String get iAmReady          => t('¡Estoy lista, vamos!', 'I\'m ready, let\'s go!');
  String get noPersonalized    => t('Sin rutina personalizada', 'No personalized routine');
  String get noPersonalizedSub => t('Configura tu perfil para obtener\nuna recomendación a tu medida.', 'Set up your profile to get\na personalized recommendation.');
  String get setupProfile      => t('Configurar Perfil', 'Set up Profile');
  String get updateRoutine     => t('Actualizar Rutina', 'Update Routine');
  String get warmup            => t('Calentamiento', 'Warm-up');
  String get mainBlock         => t('Principal', 'Main');
  String get cooldown          => t('Enfriamiento', 'Cool-down');
  String get readyMsg          => t(
    'Antes de empezar tu rutina, prepara tu espacio, pon tu cuerpo en modo cuidado y no en modo exigencia: despeja el suelo, ten agua a mano, una toalla lista… y recuerda que aquí no estás sola, cada minuto que te regalas te acerca al cuerpo, la energía y la confianza que quieres ver en el espejo!',
    'Before starting your workout, prepare your space and set your body to self-care mode: clear the floor, have water nearby, a towel ready… and remember you\'re not alone, every minute you give yourself brings you closer to the body, energy and confidence you want!',
  );
  String get errorLoadingData    => t('Error al cargar datos', 'Error loading data');
  String get routineUpdated      => t('Rutina actualizada', 'Routine updated');
  String get favoritesUpdateError => t('Error al actualizar favoritos', 'Error updating favorites');

  // ── Frases motivacionales ─────────────────────────────────────────────────
  List<String> get motivationalQuotesEs => const [
    '"Cada rep te acerca más a la versión de ti que mereces ser."',
    '"No se trata de ser perfecta, se trata de ser constante."',
    '"Tu cuerpo puede hacerlo. Es tu mente la que necesitas convencer."',
    '"El sudor de hoy es el brillo de mañana."',
    '"Una hora de ejercicio es solo el 4% de tu día. Vale la pena."',
    '"Fuerza no es solo física. Es decidir levantarte y hacerlo."',
    '"El único mal entrenamiento es el que no hiciste."',
    '"Eres más fuerte de lo que crees y más capaz de lo que imaginas."',
    '"Cada mañana traes contigo la oportunidad de ser mejor."',
    '"Tu futuro yo te agradecerá el esfuerzo de hoy."',
    '"No te compares con nadie. Tu única competencia eres tú."',
    '"La disciplina es elegirte a ti misma, una y otra vez."',
    '"Pequeños pasos todos los días crean grandes cambios."',
    '"Tu cuerpo es tu hogar. Cuídalo con amor y movimiento."',
  ];

  List<String> get motivationalQuotesEn => const [
    '"Every rep brings you closer to the version of yourself you deserve to be."',
    '"It\'s not about being perfect, it\'s about being consistent."',
    '"Your body can do it. It\'s your mind you need to convince."',
    '"Today\'s sweat is tomorrow\'s shine."',
    '"One hour of exercise is just 4% of your day. It\'s worth it."',
    '"Strength is not just physical. It\'s deciding to get up and do it."',
    '"The only bad workout is the one you didn\'t do."',
    '"You are stronger than you think and more capable than you imagine."',
    '"Every morning you bring with you the opportunity to be better."',
    '"Your future self will thank you for the effort you put in today."',
    '"Don\'t compare yourself to anyone. Your only competition is you."',
    '"Discipline is choosing yourself, over and over again."',
    '"Small steps every day create big changes."',
    '"Your body is your home. Take care of it with love and movement."',
  ];

  List<String> get dailyQuotes => _en ? motivationalQuotesEn : motivationalQuotesEs;

  // ── Días de semana (corto) ────────────────────────────────────────────────
  List<String> get weekdayLabelsShort => _en
      ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
      : const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  // ── Ejecución de rutina ──────────────────────────────────────────────────
  String get tapToPause      => t('Toca para pausar', 'Tap to pause');
  String get tapToResume     => t('Toca para reanudar', 'Tap to resume');
  String get resting         => t('Descansando...', 'Resting...');
  String get rest            => t('Descansa', 'Rest');
  String get skipExercise    => t('Saltar ejercicio', 'Skip exercise');
  String get nextExercise    => t('Siguiente ejercicio', 'Next exercise');
  String get howToDo         => t('Cómo hacerlo', 'How to do it');
  String get series          => t('SERIE', 'SET');
  // Trainer motivational messages during execution
  String get trainerSet1     => t('¡Comenzamos! Mantén buena postura', 'Let\'s go! Keep good posture');
  String get trainerLastSet  => t('¡Última serie! Todo lo que tienes 🔥', 'Last set! Give it everything 🔥');
  String get trainerSet2of3  => t('¡Muy bien! Sigue el ritmo, ya vas', 'Great! Keep the rhythm, you\'ve got this');
  String get trainerGeneric  => t('¡Fantástico! Ya casi terminas este ejercicio', 'Fantastic! Almost done with this one');
  String get trainerSetRest  => t('¡Bien hecho! Recupera el aliento...', 'Well done! Catch your breath...');
  String get trainerExRest   => t('¡Perfecto! Descansa antes del siguiente ejercicio', 'Perfect! Rest before the next exercise');
  // Zone labels — handles both snake_case backend keys and capitalized Spanish DB values
  String exerciseZone(String zone) {
    switch (zone.toLowerCase()) {
      case 'cuerpo_entero':
      case 'cuerpo_completo':
      case 'cuerpo completo':
      case 'full_body':
      case 'full body':           return t('Cuerpo completo', 'Full body');
      case 'piernas_gluteos':
      case 'gluteos_piernas':
      case 'piernas y glúteos':
      case 'glúteos y piernas':
      case 'glúteos y muslos':
      case 'legs & glutes':       return t('Piernas y glúteos', 'Legs & glutes');
      case 'glúteos':             return t('Glúteos', 'Glutes');
      case 'core':
      case 'core completo':
      case 'core y piernas':      return 'Core';
      case 'tren_superior':
      case 'brazos y hombros':
      case 'brazos completos':    return t('Tren superior', 'Upper body');
      case 'tren_inferior':       return t('Tren inferior', 'Lower body');
      case 'espalda':
      case 'espalda y caderas':   return t('Espalda', 'Back');
      case 'pecho':               return t('Pecho', 'Chest');
      case 'hombros':             return t('Hombros', 'Shoulders');
      case 'brazos':
      case 'bíceps':
      case 'tríceps':             return t('Brazos', 'Arms');
      case 'pantorrillas':        return t('Pantorrillas', 'Calves');
      case 'abdomen':
      case 'abdomen superior':    return t('Abdomen', 'Abs');
      case 'cintura y oblicuos':
      case 'oblicuos y cintura':
      case 'oblicuos':            return t('Oblicuos', 'Obliques');
      case 'caderas':             return t('Caderas', 'Hips');
      case 'piernas':             return t('Piernas', 'Legs');
      case 'respiración':         return t('Respiración', 'Breathing');
      default:                    return zone.replaceAll('_', ' ');
    }
  }
  String get congratulations => t('¡Felicitaciones!', 'Congratulations!');
  String get routineComplete => t('¡Rutina completada!', 'Workout complete!');
  String get restartRoutine  => t('Volver a empezar', 'Restart');
  String get backToRoutines  => t('Volver a rutinas', 'Back to routines');
  String get enableVoice     => t('Activar voz', 'Enable voice');
  String get muteVoice       => t('Silenciar voz', 'Mute voice');
  String get noExercises     => t('No hay ejercicios disponibles', 'No exercises available');
  String get exitRoutineTitle => t('¿Salir de la rutina?', 'Exit workout?');
  String get exitRoutineBody  => t('Perderás el progreso actual.', 'You will lose your current progress.');
  String get youDidIt         => t('¡Lo lograste!', 'You did it!');
  String minutesCompleted(int mins) => t('$mins minutos completados', '$mins minutes completed');
  String get dailyGoal       => t('Meta diaria', 'Daily goal');
  String get phaseMainTitle  => t('Parte Principal', 'Main Workout');
  String get phaseMainSubtitle => t('¡Comienza el entrenamiento!', 'Let\'s get started!');
  String get phaseCooldownTitle => t('Enfriamiento', 'Cool-down');
  String get phaseCooldownSubtitle => t('Estiramientos y relajación', 'Stretching and relaxation');
  String get phaseWarmupName   => t('Calentamiento', 'Warm-up');
  String get phaseMainName     => t('Parte Principal', 'Main Workout');
  String get phaseCooldownName => t('Enfriamiento', 'Cool-down');
  String get phaseWarmupLegend   => t('Calentamiento', 'Warm-up');
  String get phaseMainLegend     => t('Principal', 'Main');
  String get phaseCooldownLegend => t('Enfriamiento', 'Cool-down');
  String phaseSegmentLabel(String phase) {
    switch (phase) {
      case 'calentamiento': return t('Calentamiento', 'Warm-up');
      case 'principal':     return t('Ejercicio principal', 'Main exercise');
      case 'enfriamiento':  return t('Estiramiento y enfriamiento', 'Stretching & cool-down');
      default:              return phase;
    }
  }
  String phaseDisplayName(String phase) {
    switch (phase) {
      case 'calentamiento': return t('Calentamiento', 'Warm-up');
      case 'principal':     return t('Parte Principal', 'Main Workout');
      case 'enfriamiento':  return t('Enfriamiento', 'Cool-down');
      default:              return phase;
    }
  }
  String setLabel(int current, int total) =>
      t('Serie $current de $total', 'Set $current of $total');

  // ── Plan Semanal (DietPlansScreen) ──────────────────────────────────────
  String get weeklyPlanScreenSubtitle => t(
    '7 días de alimentación diseñados para tus objetivos',
    '7 days of nutrition designed for your goals',
  );
  String get planHowToUseTitle => t('Cómo usar el plan', 'How to use the plan');
  String get planHowToUseDesc  => t(
    'Cada día tiene un enfoque diferente. Sigue el orden de las comidas y ajusta las porciones a tu hambre.',
    'Each day has a different focus. Follow the meal order and adjust your portions to your hunger.',
  );
  String get comingSoon        => t('Próximamente', 'Coming soon');
  String get comingSoonEllipsis => t('Próximamente...', 'Coming soon...');
  String get plansOnTheWay     => t('Los planes están en camino 💪', 'Plans are on the way 💪');
  String get checkBackSoon     => t('Vuelve pronto', 'Check back soon');
  String get dayBadge          => t('DÍA', 'DAY');
  String dayLabel(int n)       => t('Día $n', 'Day $n');
  String mealsCount(int a, int total) => t('$a/$total comidas', '$a/$total meals');

  String planThemeLabel(String theme) {
    switch (theme) {
      case 'perdida_peso':    return t('Pérdida de peso',    'Weight loss');
      case 'gluteos_piernas': return t('Cola y piernas',     'Glutes & legs');
      case 'piel_radiante':   return t('Piel radiante',      'Radiant skin');
      case 'saciedad':        return t('Saciedad alta',      'High satiety');
      case 'gluteos_heavy':   return t('Glúteos heavy',      'Heavy glutes');
      case 'bienestar':       return t('Bienestar general',  'General wellness');
      case 'equilibrado':     return t('Mix equilibrado',    'Balanced mix');
      default:                return theme;
    }
  }

  String pendingDayLabel(int day) {
    switch (day) {
      case 2: return t('Cola/piernas — más carbos',     'Glutes/legs — more carbs');
      case 3: return t('Piel radiante y ojeras',         'Radiant skin & dark circles');
      case 4: return t('Pérdida de peso + saciedad',     'Weight loss + satiety');
      case 5: return t('Glúteos heavy',                  'Heavy glutes');
      case 6: return t('Piel y bienestar general',       'Skin & general wellness');
      case 7: return t('Mix equilibrado',                'Balanced mix');
      default: return comingSoonEllipsis;
    }
  }

  // ── Rutinas (snackbars / acciones) ───────────────────────────────────────
  String get routineGeneratedSuccess => t('¡Rutina generada exitosamente!', 'Routine generated successfully!');

  // ── Logros (adicionales) ─────────────────────────────────────────────────
  String achievementUnlocked(String names) =>
      t('🎉 ¡Nuevo logro desbloqueado! $names', '🎉 New achievement unlocked! $names');
  String get trophiesWaiting => t('¡Tus trofeos te esperan!', 'Your trophies await!');
  String get completeToUnlockMsg => t(
    'Completa rutinas para desbloquear logros y acumular XP.',
    'Complete routines to unlock achievements and accumulate XP.',
  );

  // ── Suscripción — cancelación ─────────────────────────────────────────────
  String get cancelSubscriptionTitle    => t('Cancelar Suscripción', 'Cancel Subscription');
  String get cancelSubscriptionConfirm  => t(
    '¿Estás seguro de que quieres cancelar tu suscripción? Perderás acceso a todas las características premium.',
    'Are you sure you want to cancel your subscription? You will lose access to all premium features.',
  );
  String get keepSubscription           => t('No, mantener suscripción', 'No, keep subscription');
  String get yesCancelSubscription      => t('Sí, cancelar', 'Yes, cancel');
  String get subscriptionCancelledOk    => t('Suscripción cancelada exitosamente', 'Subscription cancelled successfully');

  // ── Ejecución de rutina (adicional) ──────────────────────────────────────
  String get viewDemo => t('Ver demostración', 'View demonstration');

  // ── Wearables ─────────────────────────────────────────────────────────────
  String get wearablesTitle         => t('Wearables', 'Wearables');
  String get wearableConnected      => t('Conectado', 'Connected');
  String get wearableNotConnected   => t('No Conectado', 'Not Connected');
  String get wearableConnect        => t('Conectar', 'Connect');
  String get wearableCurrentData    => t('Datos Actuales', 'Current Data');
  String get wearableSteps          => t('Pasos', 'Steps');
  String get wearableHeartRate      => t('FC', 'HR');
  String get wearableActiveMinutes  => t('Min. Activos', 'Active Min.');
  String get wearableDistance       => t('Distancia', 'Distance');
  String get wearableSleep          => t('Sueño', 'Sleep');
  String get wearableWeight         => t('Peso', 'Weight');
  String get wearableBMI            => t('IMC', 'BMI');
  String wearableBMICategory(String cat) => t('Categoría IMC: $cat', 'BMI Category: $cat');
  String get wearableDailyGoals     => t('Metas Diarias', 'Daily Goals');
  String get editGoalsTitle         => t('Editar Metas', 'Edit Goals');
  String get editGoalsComingSoon    => t('Función de edición de metas próximamente...', 'Goal editing feature coming soon...');
  String get wearableAvailableDevices => t('Dispositivos Disponibles', 'Available Devices');
  String get wearableScan           => t('Escanear', 'Scan');
  String get wearableNoDevices      => t('No se encontraron dispositivos', 'No devices found');
  String wearableBattery(int level, String status) => t('Batería: $level% ($status)', 'Battery: $level% ($status)');
  String get wearableSupportedMetrics => t('Métricas Soportadas', 'Supported Metrics');
  String get wearableConnectedOk    => t('Dispositivo conectado exitosamente', 'Device connected successfully');
  String get wearableConnectError   => t('Error al conectar dispositivo', 'Error connecting device');
  String get wearableDisconnected   => t('Dispositivo desconectado', 'Device disconnected');
  String get wearableDataSynced     => t('Datos sincronizados', 'Data synced');
  String wearableConnectingTo(String name) => t('Conectando a $name...', 'Connecting to $name...');

  // ── Contacto — redes sociales ─────────────────────────────────────────────
  String get instagramSubtitle => t('@evastrong · Síguenos',           '@evastrong · Follow us');
  String get facebookSubtitle  => t('EvaStrong · Síguenos',            'EvaStrong · Follow us');
  String get pinterestSubtitle => t('@evastrong · Inspírate',          '@evastrong · Get inspired');
  String get emailSubtitle     => t('soporte@evastrong.app · Escríbenos', 'soporte@evastrong.app · Write to us');
  String get emailLabel        => t('Correo', 'Email');

  // ── Descripción home ──────────────────────────────────────────────────────
  String get aboutAppTagline => t(
    'Evastrong es la app de acondicionamiento físico creada para mujeres reales, de todas las edades y de cualquier estado físico, que quieren resultados de verdad sin complicarse la vida.',
    'EvaStrong is the fitness app created for real women of all ages and fitness levels who want real results without overcomplicating their lives.',
  );
  String get aboutAppNutrition => t(
    'En Evastrong encuentras un plan alimenticio completo y fácil de seguir, con recetas pensadas para verte y sentirte mejor por dentro y por fuera. Cada menú está diseñado para acompañar tus objetivos: bajar grasa, tonificar, ganar energía y cuidar tu salud a largo plazo.',
    'In EvaStrong you\'ll find a complete and easy-to-follow nutrition plan, with recipes designed to help you look and feel your best inside and out. Every menu is tailored to your goals: burn fat, tone up, boost energy, and take care of your long-term health.',
  );
  String get aboutAppRoutines => t(
    'Nuestras rutinas están diseñadas por expertos en entrenamiento femenino, adaptadas para principiantes, intermedias y avanzadas, para que puedas entrenar segura desde casa y avanzar a tu ritmo. Combina sesiones cortas y efectivas que encajan en tu día, con programas estructurados que te llevan paso a paso a un cuerpo más firme, más fuerte y más definido en poco tiempo.',
    'Our routines are designed by female training experts, adapted for beginners, intermediate, and advanced levels, so you can train safely from home and progress at your own pace. Combine short, effective sessions that fit your day with structured programs that take you step by step to a firmer, stronger, and more defined body.',
  );
  String get aboutAppLifestyle => t(
    'Con Evastrong no solo sigues ejercicios: construyes un estilo de vida saludable, con guía clara, motivación constante y herramientas pensadas para ayudarte a cumplir lo que te prometes frente al espejo.',
    'With EvaStrong you\'re not just following exercises: you\'re building a healthy lifestyle, with clear guidance, constant motivation, and tools designed to help you keep the promises you make to yourself.',
  );

  // ── Carrusel home ─────────────────────────────────────────────────────────
  List<String> get carouselTexts => _en
      ? const [
          'Transform your body, transform your life',
          'Every rep brings you closer to your best self',
          'Strength, discipline and consistency',
          'You can. You will. You\'ll make it happen',
          'The change starts today',
        ]
      : const [
          'Transforma tu cuerpo, transforma tu vida',
          'Cada rep te acerca a tu mejor versión',
          'Fuerza, disciplina y constancia',
          'Tú puedes. Tú lo harás. Tú lo lograrás',
          'El cambio empieza hoy',
        ];

  // Carrusel secundario (_AutoCarousel)
  List<String> get autoCarouselTexts => _en
      ? const [
          '💪 Transform your body, transform your life',
          '🔥 Today\'s pain is tomorrow\'s strength',
          '🌟 Every rep brings you closer to your best self',
          '⚡ Don\'t give up, the best is yet to come',
          '🏆 Champions are made when no one is watching',
        ]
      : const [
          '💪 Transforma tu cuerpo, transforma tu vida',
          '🔥 El dolor de hoy es la fuerza del mañana',
          '🌟 Cada repetición te acerca a tu mejor versión',
          '⚡ No te rindas, lo mejor está por venir',
          '🏆 Los campeones se hacen cuando nadie está mirando',
        ];

  // ── Acciones rápidas (home) ───────────────────────────────────────────────
  String get actionTrain          => t('Entrenar', 'Train');
  String get actionAchievements   => t('Logros', 'Achievements');

  // ── Galería / Media ───────────────────────────────────────────────────────
  String get mediaTitle           => t('Fotos & Videos', 'Photos & Videos');
  String get mediaViewAll         => t('Ver todo', 'View all');
  String get mediaFeaturedVideos  => t('Videos Destacados', 'Featured Videos');
  String get subscribeTitle       => t('¡SUSCRÍBETE YA!', 'SUBSCRIBE NOW!');
  String get subscribeSubtitle    => t('Cambia tu vida hoy', 'Change your life today');

  // Fotos de galería — captions
  String get photoStrengthCaption    => t('Entrenamiento de fuerza', 'Strength training');
  String get photoCardioCaption      => t('Cardio intenso', 'Intense cardio');
  String get photoYogaCaption        => t('Yoga y flexibilidad', 'Yoga & flexibility');
  String get photoToningCaption      => t('Tonificación total', 'Full body toning');
  String get photoResultsCaption     => t('Resultados reales', 'Real results');

  // Videos de galería — títulos y subtítulos
  String get videoGlutesTitle        => t('Rutina Glúteos', 'Glutes Routine');
  String get videoGlutesSubtitle     => t('15 min • Principiante', '15 min • Beginner');
  String get videoCardioTitle        => t('Cardio Express', 'Express Cardio');
  String get videoCardioSubtitle     => t('20 min • Intermedio', '20 min • Intermediate');

  // ── Planes de suscripción ─────────────────────────────────────────────────
  String get plansTitle         => t('Elige tu Plan', 'Choose Your Plan');
  String get plansSubtitle      => t('Comienza hoy tu transformación', 'Start your transformation today');
  String get planMostPopular    => t('⭐ MÁS POPULAR', '⭐ MOST POPULAR');
  String get planUsdPerMonth    => t('USD / mes', 'USD / mo');
  String get planButtonPopular  => t('¡Quiero Transformarme!', 'I Want to Transform!');
  String get planButtonDefault  => t('Empezar Ahora', 'Start Now');

  // Plan Básico / Basic
  String get planBasicName        => t('Básico', 'Basic');
  String get planBasicTagline     => t('Empieza a Brillar', 'Start Shining');
  String get planBasicDescription => t('Para mujeres que quieren comenzar sin sentirse abrumadas.', 'For women who want to start without feeling overwhelmed.');
  String get planBasicQuote       => t('"Tu nuevo comienzo: pocos minutos al día,\nmucha más seguridad frente al espejo."', '"Your new beginning: just a few minutes a day,\nso much more confidence in the mirror."');
  String get planBasicHook        => t('Ideal si quieres crear hábito y empezar a\namar el ejercicio sin presión.', 'Perfect if you want to build a habit and start\nloving exercise without pressure.');
  List<String> get planBasicFeatures => _en
      ? const [
          'Essential routines: slim down, tone up, and fight sagging',
          'Step-by-step guided videos to train at home',
          'Healthy recipes: easy breakfasts and snacks',
          'Mini nutrition tips and daily habits',
          'Basic progress and calorie tracking',
        ]
      : const [
          'Rutinas esenciales: adelgazar, tonificar y combatir flacidez',
          'Videos guiados paso a paso para entrenar en casa',
          'Recetas saludables: desayunos y snacks fáciles',
          'Mini tips de nutrición y hábitos diarios',
          'Seguimiento básico de progreso y calorías',
        ];

  // Plan Premium
  String get planPremiumName        => t('Premium', 'Premium');
  String get planPremiumTagline     => t('Transformación Total', 'Total Transformation');
  String get planPremiumDescription => t('Para mujeres decididas a cambiar su cuerpo y su estilo de vida.', 'For women committed to changing their body and lifestyle.');
  String get planPremiumQuote       => t('"Del \'algún día\' al \'lo estoy logrando\':\ntu cuerpo cambia cuando tu rutina también lo hace."', '"From \'someday\' to \'I\'m doing it\':\nyour body changes when your routine does too."');
  String get planPremiumHook        => t('Resultados visibles en pocas semanas\ncon una guía clara y femenina.', 'Visible results in just a few weeks\nwith clear, women-focused guidance.');
  List<String> get planPremiumFeatures => _en
      ? const [
          'Everything in the Basic Plan, plus:',
          'Glutes, legs, abs, back, full body, and more levels',
          '4, 8, and 12-week programs by specific goal',
          'Expanded recipe book: fitness breakfasts, lunches & dinners',
          'Weekly diet guides with macros by goal',
          'Women\'s group community to keep you motivated every day',
        ]
      : const [
          'Todo lo del Plan Básico, más:',
          'Glúteos, piernas, abdomen, espalda, full body y más niveles',
          'Programas de 4, 8 y 12 semanas por objetivo concreto',
          'Recetario ampliado: desayunos, almuerzos y cenas fitness',
          'Guías de dieta semanales con macros por objetivo',
          'Comunidad grupal de mujeres para motivarte cada día',
        ];

  // Plan Elite
  String get planEliteName        => t('Elite', 'Elite');
  String get planEliteTagline     => t('Cuerpo de Sueño, Sin Excusas', 'Dream Body, No Excuses');
  String get planEliteDescription => t('Para la mujer que quiere acceso total y acelerar resultados.', 'For the woman who wants full access and faster results.');
  String get planEliteQuote       => t('"Tu cuerpo, tu proyecto más importante:\naquí tienes al equipo completo trabajando contigo."', '"Your body, your most important project:\nhere you have the full team working with you."');
  String get planEliteHook        => t('Acceso total, resultados máximos,\nacompañamiento real.', 'Full access, maximum results,\nreal support.');
  List<String> get planEliteFeatures => _en
      ? const [
          'Everything in the Premium Plan, plus:',
          'Unlimited access: all routines and special programs',
          'Complete premium recipe library (skin, glutes, energy)',
          'Personalized nutrition coaching based on your progress',
          'Monthly custom training + diet plan made for you',
          'Priority support and early access to new challenges',
        ]
      : const [
          'Todo lo del Plan Premium, más:',
          'Acceso ilimitado: todas las rutinas y programas especiales',
          'Biblioteca completa de recetas premium (piel, glúteos, energía)',
          'Asesoría nutricional personalizada según tu progreso',
          'Plan mensual entrenamiento + dieta hecho a tu medida',
          'Prioridad en soporte y acceso anticipado a nuevos retos',
        ];

  // ── Dietas & Recetas ─────────────────────────────────────────────────────
  String get dietTitle      => t('Dietas & Recetas', 'Diets & Recipes');
  String get dietSubtitle   => t('Recetas saludables diseñadas para tu objetivo', 'Healthy recipes designed for your goals');
  String get breakfast      => t('Desayuno', 'Breakfast');
  String get lunch          => t('Almuerzo', 'Lunch');
  String get dinner         => t('Cena', 'Dinner');
  String get snack          => t('Snack', 'Snack');
  String get smoothie       => t('Batidos', 'Smoothies');
  String get calories       => t('Calorías', 'Calories');
  String get protein        => t('Proteína', 'Protein');
  String get carbs          => t('Carbos', 'Carbs');
  String get fat            => t('Grasa', 'Fat');
  String get ingredients    => t('Ingredientes', 'Ingredients');
  String get preparation    => t('Preparación', 'Preparation');
  String get weeklyPlan     => t('Plan Semanal', 'Weekly Plan');
  String get recipesForYou  => t('Recetas diseñadas para ti', 'Recipes designed for you');
  String get configProfileForDiet => t('Configura tu perfil físico para recibir recomendaciones personalizadas', 'Set up your physical profile to receive personalized recommendations');
  String get justForYou     => t('Solo para ti ✨', 'Just for you ✨');
  String get lockedRecipe   => t('Receta bloqueada', 'Locked recipe');
  String get lockedPremiumMsg => t('Esta receta está disponible en el plan Premium. ¡Suscríbete para acceder a todas las recetas y rutinas!', 'This recipe is available on the Premium plan. Subscribe to unlock all recipes and workouts!');
  String get lockedBasicMsg   => t('Esta receta está disponible en el plan Basic o Premium.', 'This recipe is available on the Basic or Premium plan.');
  String get weeklyPlanBanner => t('Plan semanal completo', 'Full weekly plan');
  String get weeklyPlanSub    => t('7 días · Pérdida de peso · Glúteos · Piel radiante', '7 days · Weight loss · Glutes · Radiant skin');
  String get prepTime    => t('Prep', 'Prep');
  String get cookTime    => t('Cocción', 'Cook');
  String get totalTime   => t('Total', 'Total');
  String get dietErrorMsg  => t('No se pudieron cargar las recetas. Verifica tu conexión.', 'Could not load recipes. Check your connection.');
  String get planErrorMsg  => t('No se pudieron cargar los planes.', 'Could not load plans.');
  String get kCalTotal     => t('kcal totales', 'total kcal');
  String get mealsLabel    => t('comidas', 'meals');
  String get postWorkout   => t('post-entreno', 'post-workout');
  String get yes           => t('Sí', 'Yes');
  String get no            => t('No', 'No');
  String get optionalLabel => t('opcional', 'optional');
  String get lockedMeal    => t('Comida bloqueada', 'Locked meal');
  String get mealLockedPremiumMsg => t('Esta comida está disponible en el plan Premium.', 'This meal is available on the Premium plan.');
  String get mealLockedBasicMsg   => t('Esta comida está disponible en el plan Basic o Premium.', 'This meal is available on the Basic or Premium plan.');

  String dietCategory(String key) {
    switch (key) {
      case 'todos':     return t('Todos', 'All');
      case 'desayuno':  return t('Desayuno', 'Breakfast');
      case 'almuerzo':  return t('Almuerzo', 'Lunch');
      case 'cena':      return t('Cena', 'Dinner');
      case 'merienda':  return t('Merienda', 'Snack');
      case 'snack':     return t('Snack', 'Snack');
      case 'batido':    return t('Batidos', 'Smoothies');
      case 'bebida':    return t('Bebidas', 'Drinks');
      default:          return key;
    }
  }

  String dietCategoryLabel(String cat) {
    switch (cat) {
      case 'desayuno': return t('Desayuno', 'Breakfast');
      case 'almuerzo': return t('Almuerzo', 'Lunch');
      case 'cena':     return t('Cena', 'Dinner');
      case 'merienda': return t('Merienda', 'Snack');
      case 'snack':    return t('Snack', 'Snack');
      case 'batido':   return t('Batido', 'Smoothie');
      case 'bebida':   return t('Bebida', 'Drink');
      default:         return cat;
    }
  }

  // ── Pagos ────────────────────────────────────────────────────────────────
  String get subscriptionPlans  => t('Planes de Suscripción', 'Subscription Plans');
  String get choosePlan         => t('Elige tu plan perfecto', 'Choose your perfect plan');
  String get choosePlanSub      => t('Acceso a entrenamientos ilimitados y contenido exclusivo', 'Unlimited workouts and exclusive content');
  String get monthly            => t('Mensual', 'Monthly');
  String get annual             => t('Anual', 'Annual');
  String get currency           => t('Moneda', 'Currency');
  String get period             => t('Período', 'Period');
  String get activeSubscription => t('Suscripción Activa', 'Active Subscription');
  String get plan               => t('Plan', 'Plan');
  String get expiration         => t('Vencimiento', 'Expires');
  String get mostPopular        => t('Más Popular', 'Most Popular');
  String get perMonth           => t('mes', 'mo');
  String get perYear            => t('año', 'yr');
  String get errorLoadingSub    => t('Error al cargar suscripción', 'Error loading subscription');

  // Plan features
  List<String> get basicFeatures => _en ? [
    'Access to 50+ workouts',
    'Progress tracking',
    'Exclusive community',
    'Email support',
  ] : [
    'Acceso a 50+ entrenamientos',
    'Seguimiento de progreso',
    'Comunidad exclusiva',
    'Soporte por email',
  ];

  List<String> get premiumFeatures => _en ? [
    'Access to 500+ workouts',
    'Personalized meal plans',
    'Personal trainer support',
    'All basic features',
    'Priority support 24/7',
  ] : [
    'Acceso a 500+ entrenamientos',
    'Planes de alimentación personalizados',
    'Soporte de entrenador personal',
    'Todas las funciones básicas',
    'Soporte prioritario 24/7',
  ];

  List<String> get eliteFeatures => _en ? [
    '1-on-1 sessions with trainer',
    'Customized meal plan',
    'Weekly video calls',
    'All premium features',
    'Exclusive content',
  ] : [
    'Sesiones 1 a 1 con entrenadora',
    'Plan alimenticio personalizado',
    'Videollamadas semanales',
    'Todas las funciones premium',
    'Contenido exclusivo',
  ];

  // ── Pagos (adicionales) ──────────────────────────────────────────────────
  String get copCurrency       => t('💰 Pesos Colombianos (COP)', '💰 Colombian Pesos (COP)');
  String get usdCurrency       => t('💵 Dólares (USD)', '💵 US Dollars (USD)');
  String planLabel(String plan) => '${t('Plan', 'Plan')}: ${plan.toUpperCase()}';
  String expirationLabel(String date) => '${t('Vencimiento', 'Expires')}: $date';

  String get paypalPending      => t('Pago PayPal pendiente', 'Pending PayPal payment');
  String get paypalPendingMsg   => t(
    'Si ya completaste el pago en PayPal, toca el botón para confirmar tu suscripción.',
    'If you completed the PayPal payment, tap the button to confirm your subscription.',
  );
  String get iAlreadyPaid       => t('Ya completé el pago', 'I already paid');
  String get subscriptionActivated => t('¡Suscripción activada exitosamente!', 'Subscription activated successfully!');
  String get completePayPalReturn  => t(
    'Completa el pago en PayPal y regresa aquí para confirmarlo',
    'Complete the payment in PayPal and return here to confirm it',
  );
  String get wompiPending       => t('Pago Wompi pendiente', 'Pending Wompi payment');
  String get wompiPendingMsg    => t(
    'Si ya completaste el pago en Wompi (PSE, Nequi, tarjeta), toca el botón para verificar tu suscripción.',
    'If you completed the Wompi payment (PSE, Nequi, card), tap the button to verify your subscription.',
  );
  String get verifyPayment      => t('Verificar pago', 'Verify payment');
  String get wompiActivated     => t('¡Suscripción activada exitosamente con Wompi!', 'Subscription activated successfully with Wompi!');
  String get paymentPending     => t('El pago aún está en proceso. Intenta en unos segundos.', 'Payment is still being processed. Try again in a few seconds.');
  String get paymentNotApproved => t('El pago no fue aprobado. Intenta de nuevo.', 'Payment was not approved. Please try again.');
  String get completeWompiReturn => t(
    'Completa el pago en Wompi (PSE, Nequi, tarjeta) y regresa aquí para verificarlo',
    'Complete the Wompi payment (PSE, Nequi, card) and return here to verify it',
  );
  String get openMercadoPago    => t('Abre Mercado Pago para completar el pago', 'Open Mercado Pago to complete the payment');

  // ── Logros ───────────────────────────────────────────────────────────────
  String get allAchievements  => t('Todos', 'All');
  String get unlocked         => t('Desbloqueados', 'Unlocked');
  String get progress         => t('Progreso', 'Progress');
  String get points           => t('Puntos', 'Points');
  String get newAchievement   => t('¡Nuevo logro desbloqueado!', 'New achievement unlocked!');
  String get noAchievementsYet => t('¡Aún no tienes logros desbloqueados!', 'No achievements unlocked yet!');
  String get noAchievementsSub => t('Completa rutinas y alcanza tus metas para empezar a ganar logros.', 'Complete workouts and reach your goals to start earning achievements.');
  String get achievementsTitle => t('Logros', 'Achievements');
  String get pts               => t('pts', 'pts');
  String unlockedOn(String date) => t('Desbloqueado el $date', 'Unlocked on $date');

  // ── Perfil ───────────────────────────────────────────────────────────────
  String get myProfile         => t('Mi Perfil', 'My Profile');
  String get personalInfo      => t('Información Personal', 'Personal Information');
  String get name              => t('Nombre', 'Name');
  String get age               => t('Edad', 'Age');
  String get performance       => t('Desempeño', 'Performance');
  String get tapToChangePhoto  => t('Toca para cambiar tu foto', 'Tap to change your photo');
  String get gallery           => t('Galería', 'Gallery');
  String get camera            => t('Cámara', 'Camera');
  String get selectPhoto       => t('Seleccionar Foto', 'Select Photo');
  String get profilePhotoUpdated => t('Foto de perfil actualizada', 'Profile photo updated');
  String get pleaseEnterName   => t('Por favor ingresa tu nombre', 'Please enter your name');
  String get invalidAge        => t('Por favor ingresa una edad válida (13-120)', 'Please enter a valid age (13-120)');
  String get invalidPerformance => t('Por favor ingresa un desempeño válido (0-100)', 'Please enter a valid performance (0-100)');
  String get profileUpdated    => t('Perfil actualizado correctamente', 'Profile updated successfully');
  String get nameHintFull      => t('Tu nombre completo', 'Your full name');
  String get ageHint           => t('Tu edad', 'Your age');
  String get performanceHint   => t('Tu nivel de desempeño (0-100)', 'Your performance level (0-100)');
  String performanceLevelLabel(String level) => t('Nivel de Desempeño: $level', 'Performance Level: $level');

  // ── Chat ─────────────────────────────────────────────────────────────────
  String participantsCount(int n) => t('$n participantes', '$n participants');
  String get myChats       => t('Mis Chats', 'My Chats');
  String get groupRooms    => t('Salas Grupales', 'Group Rooms');
  String get createGroup   => t('Crear grupo', 'Create group');
  String get noConversationsYet => t('No tienes conversaciones aún', 'No conversations yet');
  String get goToGroupRooms => t('Ve a "Salas Grupales" para unirte a una', 'Go to "Group Rooms" to join one');
  String get noGroupRoomsAvailable => t('No hay salas grupales disponibles', 'No group rooms available');
  String get defaultGroupName => t('Grupo', 'Group');
  String get noMessagesYet => t('Sin mensajes aún', 'No messages yet');
  String get typeMessage   => t('Escribe un mensaje...', 'Type a message...');
  String get justNow       => t('Ahora', 'Now');
  String minutesAgo(int m) => t('${m}m', '${m}m');
  String hoursAgo(int h)   => t('${h}h', '${h}h');
  String daysAgo(int d)    => t('${d}d', '${d}d');
  String minsAgoLong(int m) => t('Hace ${m} min', '${m} min ago');
  String hoursAgoLong(int h) => t('Hace ${h} h', '${h} h ago');

  // ── Comunidad ─────────────────────────────────────────────────────────────
  String get communityTitle     => t('Comunidad', 'Community');
  String get communityTabFeed   => t('Feed', 'Feed');
  String get communityTabGroups => t('Grupos', 'Groups');
  String get communityTabChallenges => t('Retos', 'Challenges');
  String membersCount(int n)    => t('$n miembros', '$n members');
  String get joinedLabel        => t('Unido', 'Joined');
  String get joinLabel          => t('Unirse', 'Join');
  String difficultyLabel(String d) => t('Dificultad: $d', 'Difficulty: $d');
  String participantsLabel(int n) => t('$n participantes', '$n participants');
  String daysLeftLabel(int n)   => t('$n días', '$n days');
  String commentsCount(int n)   => t('Comentarios ($n)', 'Comments ($n)');
  String get commentsComingSoon => t('Función de comentarios próximamente...', 'Comments feature coming soon...');
  String get shareComingSoon    => t('Compartir próximamente...', 'Share feature coming soon...');
  String get createPost         => t('Crear Publicación', 'Create Post');
  String get whatToShare        => t('¿Qué quieres compartir?', 'What do you want to share?');
  String get publish            => t('Publicar', 'Publish');
  String daysAgoLong(int d)     => t('Hace $d días', '$d days ago');

  // Grupos de comunidad (demo)
  String get groupBeginners         => t('Principiantes Eva Strong', 'Eva Strong Beginners');
  String get groupBeginnersDesc     => t('Para quienes empiezan su transformación', 'For those starting their transformation');
  String get groupMorningRoutines   => t('Rutinas Matutinas', 'Morning Routines');
  String get groupMorningDesc       => t('Grupo para madrugadores motivados', 'Group for motivated early risers');
  String get groupStrongMoms        => t('Mamás Fuertes', 'Strong Moms');
  String get groupStrongMomsDesc    => t('Apoyo y motivación para mamás fitness', 'Support and motivation for fitness moms');
  String get groupAthletes          => t('Atletas Eva Strong', 'Eva Strong Athletes');
  String get groupAthletesDesc      => t('Para los más dedicados', 'For the most dedicated');

  // Retos de comunidad (demo)
  String get challenge30Days        => t('Reto 30 Días', '30-Day Challenge');
  String get challenge30DaysDesc    => t('Completa una rutina cada día por 30 días', 'Complete a routine every day for 30 days');
  String get challenge100Squats     => t('Reto 100 Sentadillas', '100 Squats Challenge');
  String get challenge100SquatsDesc => t('Haz 100 sentadillas en un día', 'Do 100 squats in a day');
  String get challengeHydration     => t('Reto Hidratación', 'Hydration Challenge');
  String get challengeHydrationDesc => t('Bebe 8 vasos de agua diarios por 21 días', 'Drink 8 glasses of water daily for 21 days');
  String get difficultyMedium       => t('Media', 'Medium');
  String get difficultyHigh         => t('Alta', 'High');
  String get difficultyLow          => t('Baja', 'Low');

  // ── Chat de Soporte ───────────────────────────────────────────────────────
  String get supportChatTitle    => t('Chat de Soporte', 'Support Chat');
  String get supportAvailable247 => t('Soporte disponible 24/7 • Respuesta rápida garantizada', 'Support available 24/7 • Fast response guaranteed');
  String get writeMsgHint        => t('Escribe tu mensaje...', 'Write your message...');
  String get chatInfoTitle       => t('Info del Chat', 'Chat Info');
  String get virtualAssistant    => t('🤖 **Asistente Virtual**', '🤖 **Virtual Assistant**');
  String get autoResponse        => t('Respuesta automática inteligente', 'Smart automatic response');
  String get humanSupport        => t('👨‍💼 **Soporte Humano**', '👨‍💼 **Human Support**');
  String get humanSupportHours   => t('Disponible Lunes a Viernes, 9am-6pm', 'Available Monday to Friday, 9am-6pm');
  String get responseTimeTitle   => t('⚡ **Tiempo de respuesta**', '⚡ **Response time**');
  String get chatImmediate       => t('Chat: Inmediato', 'Chat: Immediate');
  String get emailResponseTime   => t('Email: 2-4 horas', 'Email: 2-4 hours');
  String get quickReplies        => t('Respuestas Rápidas', 'Quick Replies');
  String get quickRepliesHelpRoutines  => t('Ayuda con rutinas', 'Help with routines');
  String get quickRepliesPaymentIssue  => t('Problemas de pago', 'Payment issues');
  String get quickRepliesSetupProfile  => t('Configurar perfil', 'Set up profile');
  String get quickRepliesTechError     => t('Error técnico', 'Technical error');
  String get quickRepliesCancelSub     => t('Cancelar suscripción', 'Cancel subscription');
  String get quickRepliesContactHuman  => t('Contactar humano', 'Contact human support');

  // Mensajes del bot
  String get botWelcome => t(
    '¡Hola! 👋 Soy tu asistente virtual de Eva Strong.\n\n¿En qué puedo ayudarte hoy?\n\n💪 Puedo ayudarte con:\n• Rutinas y ejercicios\n• Problemas técnicos\n• Configuración de perfil\n• Pagos y suscripciones',
    'Hi! 👋 I\'m your Eva Strong virtual assistant.\n\nHow can I help you today?\n\n💪 I can help you with:\n• Routines and exercises\n• Technical issues\n• Profile setup\n• Payments and subscriptions',
  );
  String get botRoutineHelp => t(
    '💪 **Sobre Rutinas:**\n\nPuedes acceder a tus rutinas personalizadas desde:\n• Menú lateral → "Mis Rutinas"\n• Pestaña "Rutinas" en la pantalla principal\n\n¿Necesitas ayuda con algo específico de tu rutina?',
    '💪 **About Routines:**\n\nYou can access your personalized routines from:\n• Side menu → "My Routines"\n• "Routines" tab on the main screen\n\nDo you need help with something specific about your routine?',
  );
  String get botPaymentHelp => t(
    '💳 **Sobre Pagos:**\n\nPara gestionar tu suscripción:\n1. Ve a tu perfil\n2. Selecciona "Configuración de pagos"\n3. Elige tu plan (Mensual/Anual)\n\n¿Problemas con un pago? Contacta a soporte@evastrong.com',
    '💳 **About Payments:**\n\nTo manage your subscription:\n1. Go to your profile\n2. Select "Payment settings"\n3. Choose your plan (Monthly/Annual)\n\nPayment issues? Contact soporte@evastrong.com',
  );
  String get botProfileHelp => t(
    '👤 **Sobre tu Perfil:**\n\nConfigura tu perfil completo:\n• Menú lateral → "Configurar Perfil"\n• Agrega tu edad, nivel y objetivos\n• Esto personalizará tus rutinas\n\n¿Qué sección de tu perfil quieres ajustar?',
    '👤 **About your Profile:**\n\nSet up your complete profile:\n• Side menu → "Set Up Profile"\n• Add your age, level and goals\n• This will personalize your routines\n\nWhich section of your profile do you want to adjust?',
  );
  String get botHelloResponse => t(
    '¡Hola! 😊 ¿Cómo estás hoy?\n\nRecuerda que la consistencia es clave para tus objetivos.\n¿Qué rutina vas a hacer hoy? 💪',
    'Hello! 😊 How are you today?\n\nRemember that consistency is key for your goals.\nWhat routine are you going to do today? 💪',
  );
  String get botThanksResponse => t(
    '🌟 **¡De nada!**\n\nEstoy aquí para ayudarte a alcanzar tus metas.\n¡Sigue adelante, tú puedes! 💪✨\n\n¿Necesitas algo más?',
    '🌟 **You\'re welcome!**\n\nI\'m here to help you reach your goals.\nKeep going, you can do it! 💪✨\n\nDo you need anything else?',
  );
  String get botDefaultResponse => t(
    '🤔 **Entiendo tu consulta.**\n\nPuedo ayudarte con:\n• 📋 Rutinas y ejercicios personalizados\n• 💳 Pagos y suscripciones\n• 👤 Configuración de perfil\n• 🔧 Problemas técnicos\n• 📈 Seguimiento de progreso\n\n¿Podrías darme más detalles sobre lo que necesitas?\n\nO si prefieres, puedes escribir "ayuda" para ver todas las opciones.',
    '🤔 **I understand your query.**\n\nI can help you with:\n• 📋 Personalized routines and exercises\n• 💳 Payments and subscriptions\n• 👤 Profile setup\n• 🔧 Technical issues\n• 📈 Progress tracking\n\nCould you give me more details about what you need?\n\nOr if you prefer, type "help" to see all options.',
  );

  // ── Configurar Perfil ────────────────────────────────────────────────────
  String get setupFitnessProfile => t('Configurar Perfil de Fitness', 'Set Up Fitness Profile');
  String get createPerfectProfile => t('💪 Crea Tu Perfil Perfecto', '💪 Create Your Perfect Profile');
  String get profileSetupSubtitle => t(
    'Personaliza tu experiencia de fitness con rutinas adaptadas a tus necesidades y objetivos específicos.',
    'Personalize your fitness experience with routines tailored to your specific needs and goals.',
  );
  String get basicInfo           => t('Información Básica', 'Basic Information');
  String get prefsAndLimitations => t('Preferencias y Limitaciones', 'Preferences & Limitations');
  String get ageRange            => t('Rango de Edad', 'Age Range');
  String get ageRangeHint        => t('Selecciona tu rango de edad', 'Select your age range');
  String get physicalConstitution => t('Constitución Física', 'Body Constitution');
  String get constitutionHint    => t('Selecciona tu tipo de constitución', 'Select your body type');
  String get fitnessLevel        => t('Nivel de Fitness', 'Fitness Level');
  String get fitnessLevelHint    => t('Selecciona tu nivel actual', 'Select your current level');
  String get kneeSensitive       => t('Rodillas Sensibles', 'Sensitive Knees');
  String get kneeSensitiveDesc   => t('Marcar si tienes problemas en las rodillas', 'Check if you have knee problems');
  String get pathologies         => t('Patologías', 'Medical Conditions');
  String get pathologiesHint     => t('Selecciona si tienes alguna condición médica', 'Select any medical conditions');
  String get dailyTime           => t('Tiempo Diario Disponible', 'Daily Available Time');
  String get dailyTimeHint       => t('Minutos que puedes dedicar al ejercicio', 'Minutes you can dedicate to exercise');
  String get saveProfile         => t('Guardar Perfil', 'Save Profile');
  String get fieldRequired       => t('Campo requerido', 'Field required');
  String get profileLoadError    => t('Error al cargar perfil', 'Error loading profile');
  String get profileUpdatedOk    => t('¡Perfil actualizado exitosamente!', 'Profile updated successfully!');
  String get profileSavedLocally => t('¡Perfil guardado localmente!', 'Profile saved locally!');
  String get profileSaveError    => t('Error al guardar perfil', 'Error saving profile');

  String profileFormatValue(String key) {
    switch (key) {
      case '18-35':        return t('18-35 años', '18-35 years');
      case '36-55':        return t('36-55 años', '36-55 years');
      case '55+':          return t('55+ años', '55+ years');
      case 'bajo_peso':    return t('Bajo peso', 'Underweight');
      case 'normopeso':    return t('Normopeso', 'Normal weight');
      case 'sobrepeso':    return t('Sobrepeso', 'Overweight');
      case 'obesidad':     return t('Obesidad', 'Obesity');
      case 'beginner':
      case 'principiante': return t('Principiante', 'Beginner');
      case 'intermediate':
      case 'intermedio':   return t('Intermedio', 'Intermediate');
      case 'advanced':
      case 'avanzado':     return t('Avanzado', 'Advanced');
      case 'ninguna':      return t('Ninguna', 'None');
      case 'cardiaca':     return t('Cardíaca', 'Cardiac');
      case 'respiratoria': return t('Respiratoria', 'Respiratory');
      case 'metabolica':   return t('Metabólica', 'Metabolic');
      case 'otra':         return t('Otra', 'Other');
      default:             return key;
    }
  }

  // ── Contacto ─────────────────────────────────────────────────────────────
  String get contactTitle       => t('Contacto', 'Contact');
  String get followUsNetworks   => t('Síguenos en nuestras redes', 'Follow us on social media');
  String get followUsOn         => t('Síguenos en:', 'Follow us on:');
  String get contactInfo        => t('Información de contacto', 'Contact information');
  String get ourLocation        => t('Nuestra ubicación', 'Our location');
  String get openGoogleMaps     => t('Abrir en Google Maps', 'Open in Google Maps');

  // ── Feedback ─────────────────────────────────────────────────────────────
  String get feedbackTitle    => t('Tu opinión nos importa', 'Your opinion matters');
  String get feedbackSubtitle => t('Déjanos tus comentarios', 'Leave us your feedback');
  String get feedbackListening => t(
    'Estamos aquí para escucharte y valoramos\ncada palabra que compartes con nosotras.',
    'We are here to listen to you and value\nevery word you share with us.',
  );
  String get yourRating       => t('Tu valoración', 'Your rating');
  String get category         => t('Categoría', 'Category');
  String get nameOptional     => t('Tu nombre (opcional)', 'Your name (optional)');
  String get nameHint         => t('Ej: María', 'e.g. Maria');
  String get emailOptional    => t('Tu correo (opcional)', 'Your email (optional)');
  String get emailHint        => t('tu@correo.com', 'you@email.com');
  String get yourComment      => t('Tu comentario *', 'Your comment *');
  String get commentHint      => t(
    'Cuéntanos tu experiencia, sugerencias o lo que quieras...',
    'Tell us your experience, suggestions or anything you like...',
  );
  String get commentRequired  => t('El comentario no puede estar vacío.', 'Comment cannot be empty.');
  String get selectRatingFirst => t('Por favor selecciona una valoración.', 'Please select a rating.');
  String get send             => t('Enviar comentario', 'Send feedback');
  String get sendError        => t('Error al enviar. Intenta de nuevo.', 'Error sending. Please try again.');
  String get connectionError  => t('Error de conexión. Intenta de nuevo.', 'Connection error. Please try again.');
  String get thankYou         => t('¡Gracias por tu comentario!', 'Thank you for your feedback!');
  String get feedbackSuccess  => t(
    'Tu opinión nos ayuda a mejorar cada día.\nEva Strong se construye junto a ti.',
    'Your feedback helps us improve every day.\nEva Strong is built together with you.',
  );
  String get backToHome       => t('Volver al inicio', 'Back to home');

  String feedbackCategory(String key) {
    switch (key) {
      case 'general': return t('General', 'General');
      case 'rutinas': return t('Rutinas', 'Routines');
      case 'dietas':  return t('Dietas', 'Diets');
      case 'app':     return 'App';
      case 'soporte': return t('Soporte', 'Support');
      case 'otro':    return t('Otro', 'Other');
      default:        return key;
    }
  }

  // ── Categorías de rutinas ────────────────────────────────────────────────
  String routineCategory(String key) {
    switch (key) {
      case 'strength':    return t('Fuerza', 'Strength');
      case 'cardio':      return t('Cardio', 'Cardio');
      case 'flexibility': return t('Flexibilidad', 'Flexibility');
      case 'hiit':        return 'HIIT';
      case 'pilates':     return 'Pilates';
      case 'yoga':        return 'Yoga';
      case 'crossfit':    return 'CrossFit';
      case 'functional':
      case 'funcional':   return t('Funcional', 'Functional');
      case 'gluteos':     return t('Glúteos', 'Glutes');
      case 'other':
      case 'otro':        return t('Otro', 'Other');
      default:            return key;
    }
  }

  String routineDifficulty(String key) {
    switch (key) {
      case 'beginner':
      case 'principiante': return t('Principiante', 'Beginner');
      case 'intermediate':
      case 'intermedio':   return t('Intermedio', 'Intermediate');
      case 'advanced':
      case 'avanzado':     return t('Avanzado', 'Advanced');
      case 'expert':       return t('Experto', 'Expert');
      default:             return profileFormatValue(key);
    }
  }

  String ratingsCount(int n) =>
      t('$n valoracion${n == 1 ? '' : 'es'}', '$n rating${n == 1 ? '' : 's'}');

  String get startWorkout => t('¡Empezar!', 'Start!');
  String get startRoutineLabel => t('¡Empezar rutina!', 'Start workout!');

  /// Translates a raw routine tag (may be in Spanish or English)
  String routineTag(String tag) {
    switch (tag.toLowerCase()) {
      case 'gluteos':
      case 'glúteos':         return t('Glúteos', 'Glutes');
      case 'tren_inferior':   return t('Tren inferior', 'Lower body');
      case 'tren_superior':   return t('Tren superior', 'Upper body');
      case 'principiante':    return t('Principiante', 'Beginner');
      case 'intermedio':      return t('Intermedio', 'Intermediate');
      case 'avanzado':        return t('Avanzado', 'Advanced');
      case 'sin_material':    return t('Sin material', 'No equipment');
      case 'sin equipo':      return t('Sin equipo', 'No equipment');
      case 'colchoneta':      return t('Colchoneta', 'Mat');
      case 'core':            return 'Core';
      case 'abdomen':         return t('Abdomen', 'Abs');
      case 'cintura':         return t('Cintura', 'Waist');
      case 'piernas':         return t('Piernas', 'Legs');
      case 'brazos':          return t('Brazos', 'Arms');
      case 'espalda':         return t('Espalda', 'Back');
      case 'cardio':          return 'Cardio';
      case 'hiit':            return 'HIIT';
      case 'pilates':         return 'Pilates';
      case 'yoga':            return 'Yoga';
      case 'funcional':
      case 'functional':      return t('Funcional', 'Functional');
      case 'quemar grasa':
      case 'quema grasa':     return t('Quema grasa', 'Fat burn');
      case 'vientre plano':   return t('Vientre plano', 'Flat belly');
      case 'free':            return t('Gratis', 'Free');
      case 'premium':         return 'Premium';
      case 'fuerza':          return t('Fuerza', 'Strength');
      case 'flexibilidad':    return t('Flexibilidad', 'Flexibility');
      default:                return tag;
    }
  }

  String exerciseType(String key) {
    switch (key) {
      case 'fuerza':         return t('Fuerza', 'Strength');
      case 'cardio_suave':   return t('Cardio suave', 'Light cardio');
      case 'cardio_intenso': return t('Cardio intenso', 'Intense cardio');
      case 'movilidad':      return t('Movilidad', 'Mobility');
      case 'flexibilidad':   return t('Flexibilidad', 'Flexibility');
      case 'equilibrio':     return t('Equilibrio', 'Balance');
      default:               return key;
    }
  }

  // ── Pantalla de rutinas ───────────────────────────────────────────────────
  String get noRoutinesAvailable => t('No hay rutinas disponibles', 'No routines available');
  String get clearFilters        => t('Limpiar filtros', 'Clear filters');
  String get noResults           => t('Sin resultados', 'No results');
  String get noFavoritesYet      => t('Aún no tienes favoritas', 'No favorites yet');
  String get noWorkoutsYet       => t('Sin entrenamientos aún', 'No workouts yet');
  String get latestWorkouts      => t('Últimos entrenamientos', 'Latest workouts');
  String get totalProgress       => t('Tu progreso total', 'Your total progress');
  String get minutesLabel        => t('Minutos', 'Minutes');
  String get noResultsFilters    => t('Sin resultados para estos filtros', 'No results for these filters');
  String get filtersLabel        => t('Filtros', 'Filters');
  String get kneeAdapted         => t('Adaptada para sensibilidad en rodillas', 'Adapted for knee sensitivity');
  String get levelLabel          => t('Nivel', 'Level');
  String get categoryLabel       => t('Categoría', 'Category');
  String get kneesLabel          => t('Rodillas', 'Knees');
  String get noRestriction       => t('Sin restricción', 'No restriction');
  String get withSensitivity     => t('Con sensibilidad', 'With sensitivity');
  String get useTemplate         => t('Usar plantilla', 'Use template');
  String get instructorLabel     => t('Instructor', 'Instructor');
  String get durationLabel       => t('Duración', 'Duration');
  String get intensityLabel      => t('Intensidad', 'Intensity');
  String get subscribe           => t('Suscribirse', 'Subscribe');

  // ── Video tutoriales ──────────────────────────────────────────────────────
  String get videoTutorialsTitle     => t('Video Tutoriales', 'Video Tutorials');
  String get premiumContent          => t('Contenido Premium', 'Premium Content');
  String get premiumRoutineMsg       => t('Esta rutina requiere suscripción.\n¿Quieres ver los planes disponibles?', 'This routine requires a subscription.\nWould you like to see the available plans?');
  String get premiumDialogBadge      => t('✦ EVA STRONG PREMIUM ✦', '✦ EVA STRONG PREMIUM ✦');
  String get premiumDialogHeadline   => t('Desbloquea tu\nmejor versión', 'Unlock Your\nBest Self');
  String get premiumDialogSub        => t('Accede a rutinas exclusivas diseñadas\npara transformar tu cuerpo y mente.', 'Access exclusive routines designed\nto transform your body and mind.');
  String get premiumBenefit1         => t('Más de 200 rutinas exclusivas', '200+ exclusive workouts');
  String get premiumBenefit2         => t('Planes personalizados con IA', 'AI-personalized training plans');
  String get premiumBenefit3         => t('Seguimiento de progreso avanzado', 'Advanced progress tracking');
  String get premiumDialogCta        => t('Comenzar mi transformación', 'Start My Transformation');
  String get premiumDialogDecline    => t('Quizás más tarde', 'Maybe later');
  String get premiumExclusive        => t('Este contenido es exclusivo para miembros Premium.', 'This content is exclusive to Premium members.');
  String get premiumBenefitsTitle    => t('Beneficios Premium:', 'Premium benefits:');
  String get premiumAllVideos        => t('• Acceso a todos los videos', '• Access to all videos');
  String get premiumDownloads        => t('• Descargas sin límite', '• Unlimited downloads');
  String get premiumNoAds            => t('• Sin anuncios', '• No ads');
  String get premiumExclusiveContent => t('• Contenido exclusivo', '• Exclusive content');
  String get getPremium              => t('Hacerse Premium', 'Get Premium');
  String get searchTutorials         => t('Buscar Tutoriales', 'Search Tutorials');
  String get searchHint              => t('Escribe para buscar...', 'Type to search...');
  String get search                  => t('Buscar', 'Search');
  String get applyFilter             => t('Aplicar', 'Apply');
  String get difficultyFilter        => t('Dificultad', 'Difficulty');
  String get durationFilter          => t('Duración', 'Duration');
  String get difficultyEasy          => t('Fácil', 'Easy');
  String get difficultyMediumLevel   => t('Media', 'Medium');
  String get difficultyHighLevel     => t('Alta', 'High');
  String get difficultyAdvancedLevel => t('Avanzado', 'Advanced');
  String playingLabel(String title)  => t('Reproduciendo: $title', 'Playing: $title');

  String videoTutorialCategory(String key) {
    switch (key) {
      case 'all':        return t('Todos', 'All');
      case 'beginners':  return t('Principiantes', 'Beginners');
      case 'technique':  return t('Técnica', 'Technique');
      case 'routines':   return t('Rutinas', 'Routines');
      case 'nutrition':  return t('Nutrición', 'Nutrition');
      case 'recovery':   return t('Recuperación', 'Recovery');
      case 'cardio':     return t('Cardio', 'Cardio');
      default:           return key;
    }
  }

  String get maxLevelReached => t('¡Nivel máximo alcanzado! 👑', 'Max level reached! 👑');

  // ── Profile Setup (wizard) ────────────────────────────────────────────────
  String get setupContinue       => t('Continuar', 'Continue');
  String get setupStepOf         => t('de', 'of');
  String get setupSaveProfile    => t('Guardar mi perfil', 'Save my profile');
  String get setupFieldRequired  => t('Selecciona una opción para continuar', 'Please select an option to continue');

  // Step 1 — Age
  String get setupAgeTitle       => t('¿Cuántos años\ntienes?', 'How old\nare you?');
  String get setupAgeSubtitle    => t('Adaptamos cada rutina a tu etapa de vida para maximizar tus resultados.', 'We tailor each routine to your life stage to maximize your results.');
  String get setupAge1835        => t('18 – 35 años', '18 – 35 years');
  String get setupAge1835Desc    => t('Joven y llena de energía', 'Young and full of energy');
  String get setupAge3655        => t('36 – 55 años', '36 – 55 years');
  String get setupAge3655Desc    => t('En plena madurez y fortaleza', 'In full maturity and strength');
  String get setupAge55plus      => t('55+ años', '55+ years');
  String get setupAge55plusDesc  => t('Activa y sin límites', 'Active and limitless');

  // Step 2 — Fitness level
  String get setupLevelTitle         => t('¿Cuál es tu\nnivel de fitness?', 'What is your\nfitness level?');
  String get setupLevelSubtitle      => t('Sé honesta contigo misma. Siempre puedes actualizarlo más adelante.', 'Be honest with yourself. You can always update it later.');
  String get setupLevelBeginner      => t('Principiante', 'Beginner');
  String get setupLevelBeginnerDesc  => t('Estoy empezando o llevo poco tiempo entrenando', 'I\'m just starting out or have been training for a short time');
  String get setupLevelIntermediate      => t('Intermedio', 'Intermediate');
  String get setupLevelIntermediateDesc  => t('Entreno con regularidad hace meses', 'I\'ve been training regularly for months');
  String get setupLevelAdvanced      => t('Avanzada', 'Advanced');
  String get setupLevelAdvancedDesc  => t('Entreno intensamente de forma constante', 'I train intensely on a consistent basis');

  // Step 3 — Constitution
  String get setupBodyTitle        => t('¿Cómo describirías\ntu cuerpo hoy?', 'How would you\ndescribe your body today?');
  String get setupBodySubtitle     => t('Esta información es completamente privada y nos ayuda a elegir los mejores ejercicios para ti.', 'This information is completely private and helps us choose the best exercises for you.');
  String get setupBodyUnderweight  => t('Bajo peso', 'Underweight');
  String get setupBodyUnderDesc    => t('IMC por debajo de lo recomendado', 'BMI below the recommended range');
  String get setupBodyHealthy      => t('Peso saludable', 'Healthy weight');
  String get setupBodyHealthyDesc  => t('IMC dentro del rango recomendado', 'BMI within the recommended range');
  String get setupBodyOverweight   => t('Sobrepeso', 'Overweight');
  String get setupBodyOverDesc     => t('Algo por encima del rango recomendado', 'Slightly above the recommended range');
  String get setupBodyObese        => t('Obesidad', 'Obesity');
  String get setupBodyObeseDesc    => t('Busco perder peso con un plan seguro', 'I want to lose weight with a safe plan');

  // Step 4 — Health
  String get setupHealthTitle       => t('¿Tienes alguna\ncondición de salud?', 'Do you have any\nhealth conditions?');
  String get setupHealthSubtitle    => t('Adaptamos los ejercicios para que entrenes de forma segura y efectiva.', 'We adapt exercises so you can train safely and effectively.');
  String get setupKneeSensitive     => t('Rodillas sensibles', 'Sensitive knees');
  String get setupKneeSensitiveDesc => t('Evitaremos ejercicios con impacto en las rodillas', 'We\'ll avoid high-impact knee exercises');
  String get setupHealthCondition   => t('Condición de salud', 'Health condition');
  String get setupHealthNone        => t('Sin condiciones', 'No conditions');
  String get setupHealthCardiac     => t('Cardíaca', 'Cardiac');
  String get setupHealthRespiratory => t('Respiratoria', 'Respiratory');
  String get setupHealthMetabolic   => t('Metabólica', 'Metabolic');
  String get setupHealthOther       => t('Otra', 'Other');

  // Step 5 — Time
  String get setupTimeTitle      => t('¿Cuánto tiempo\ntienes al día?', 'How much time\ndo you have each day?');
  String get setupTimeSubtitle   => t('Diseñamos cada sesión para que aproveches al máximo cada minuto.', 'We design each session so you make the most of every minute.');
  String get setupTime10         => t('10 minutos', '10 minutes');
  String get setupTime10Desc     => t('Express — para días muy ocupados', 'Express — for very busy days');
  String get setupTime15         => t('15 minutos', '15 minutes');
  String get setupTime15Desc     => t('Equilibrado — el favorito de nuestras usuarias', 'Balanced — our users\' favorite');
  String get setupTime20         => t('20 minutos', '20 minutes');
  String get setupTime20Desc     => t('Completo — para maximizar resultados', 'Full — to maximize results');
  String get setupAlmostDone     => t('¡Ya casi terminamos!', 'Almost done!');
  String get setupAlmostDoneDesc => t('Tu plan personalizado está listo para ser creado.', 'Your personalized plan is ready to be created.');

  String videoDifficulty(String key) {
    switch (key) {
      case 'easy':     return t('Fácil', 'Easy');
      case 'medium':   return t('Media', 'Medium');
      case 'high':     return t('Alta', 'High');
      case 'advanced': return t('Avanzado', 'Advanced');
      default:         return key;
    }
  }
}
