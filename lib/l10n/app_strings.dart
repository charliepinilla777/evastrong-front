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
  String get howToDo         => t('Cómo hacerlo', 'How to do it');
  String get series          => t('SERIE', 'SET');
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
  String get dietErrorMsg => t('No se pudieron cargar las recetas. Verifica tu conexión.', 'Could not load recipes. Check your connection.');

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
  String get instagramSubtitle  => t('@evastrong · Síguenos', '@evastrong · Follow us');
  String get facebookSubtitle   => t('EvaStrong · Síguenos', 'EvaStrong · Follow us');
  String get pinterestSubtitle  => t('@evastrong · Inspírate', '@evastrong · Get inspired');
  String get emailLabel         => t('Correo', 'Email');
  String get emailSubtitle      => t('soporte@evastrong.app · Escríbenos', 'soporte@evastrong.app · Contact us');
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
}
