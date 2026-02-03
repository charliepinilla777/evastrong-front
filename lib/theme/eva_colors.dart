import 'package:flutter/material.dart';

/// Paleta de colores completa Eva Strong - Rosa Vibrante, Cósmica y Energía Dinámica
class EvaColors {
  // === PALETA PRINCIPAL - Rosa Vibrante y Cósmica ===

  // Rosa vibrante principal
  static const Color vibrantPink = Color(
    0xFFFF69B4,
  ); // Hot Pink - Headers y CTAs
  static const Color cosmicRed = Color(
    0xFFD71E49,
  ); // Rojo cósmico - Progresos y alertas
  static const Color neutralGray = Color(
    0xFFDCDDDE,
  ); // Gris neutro - Fondos limpios
  static const Color wellnessPurple = Color(
    0xFF800080,
  ); // Morado wellness - Yoga/estiramientos
  static const Color softBlack = Color(
    0xFF323335,
  ); // Negro suave - Textos y bordes

  // === PALETA SECUNDARIA - Energía Dinámica ===

  // Naranja motivación
  static const Color motivationOrange = Color(
    0xFFFFA500,
  ); // Botones "Entrenar ahora"

  // Verde activo
  static const Color activeGreen = Color(
    0xFF32CD32,
  ); // Barras de progreso y logros

  // Azul fuerte
  static const Color strongBlue = Color(0xFF4169E1); // Fondos de perfil usuario

  // Amarillo vitalidad
  static const Color vitalityYellow = Color(0xFFFFD700); // Notificaciones push

  // Gris balance
  static const Color balanceGray = Color(0xFF808080); // Elementos secundarios

  // === COLORES COMPLEMENTARIOS DERIVADOS ===

  // Tonos rosa derivados
  static const Color lightPink = Color(0xFFFFB3D9); // Rosa claro para fondos
  static const Color darkPink = Color(0xFFE91E63); // Rosa oscuro para acentos
  static const Color mediumPink = Color(0xFFFF4081); // Rosa medio
  static const Color deepPink = Color(0xFFC2185B); // Rosa profundo

  // Tonos naranja derivados
  static const Color lightOrange = Color(0xFFFFB347); // Naranja claro
  static const Color darkOrange = Color(0xFFFF8C00); // Naranja oscuro

  // Tonos verde derivados
  static const Color lightGreen = Color(0xFF90EE90); // Verde claro
  static const Color darkGreen = Color(0xFF228B22); // Verde oscuro

  // Tonos azul derivados
  static const Color lightBlue = Color(0xFF87CEEB); // Azul claro
  static const Color darkBlue = Color(0xFF191970); // Azul oscuro

  // Tonos amarillo derivados
  static const Color lightYellow = Color(0xFFFFFACD); // Amarillo claro
  static const Color darkYellow = Color(0xFFDAA520); // Amarillo oscuro

  // === COLORES DE TEXTO ===

  static const Color textOnVibrant = Colors.white; // Texto sobre rosa vibrante
  static const Color textOnDark = Colors.white; // Texto sobre fondos oscuros
  static const Color textOnLight = softBlack; // Texto sobre fondos claros
  static const Color textPrimary = softBlack; // Texto principal
  static const Color textSecondary = Color(0xFF666666); // Texto secundario
  static const Color textMuted = Color(0xFF999999); // Texto silenciado

  // === COLORES DE FONDO ===

  static const Color backgroundLight = neutralGray; // Fondo principal claro
  static const Color backgroundDark = Color(
    0xFF2A2A2A,
  ); // Fondo principal oscuro
  static const Color surfaceLight = Colors.white; // Superficies claras
  static const Color surfaceDark = Color(0xFF3A3A3A); // Superficies oscuras
  static const Color cardLight = Color(0xFFF8F9FA); // Fondo de tarjetas claro
  static const Color cardDark = Color(0xFF2C2C2C); // Fondo de tarjetas oscuro

  // === COLORES DE ESTADO ===

  static const Color success = activeGreen; // Verde para éxito
  static const Color warning = cosmicRed; // Rojo cósmico para advertencias
  static const Color error = Color(0xFFFF5252); // Rojo para errores
  static const Color info = vibrantPink; // Rosa vibrante para información
  static const Color pending = vitalityYellow; // Amarillo para pendientes

  // === GRADIENTES PRINCIPALES ===

  // Gradiente Rosa Vibrante
  static const List<Color> vibrantGradient = [
    vibrantPink, // Rosa vibrante principal
    cosmicRed, // Rojo cósmico
    mediumPink, // Rosa medio
  ];

  // Gradiente Wellness
  static const List<Color> wellnessGradientColors = [
    wellnessPurple, // Morado wellness
    lightPink, // Rosa claro
    surfaceLight, // Blanco
  ];

  // Gradiente Cósmico
  static const List<Color> cosmicGradientColors = [
    cosmicRed, // Rojo cósmico
    vibrantPink, // Rosa vibrante
    darkPink, // Rosa oscuro
  ];

  // Gradiente Neutro (lista de colores)
  static const List<Color> neutralGradientColors = [
    neutralGray, // Gris neutro
    lightPink, // Rosa claro
    surfaceLight, // Blanco
  ];

  // === GRADIENTES DE ENERGÍA DINÁMICA ===

  // Gradiente Motivación (Naranja-Rosa)
  static const List<Color> motivationGradient = [
    motivationOrange, // Naranja motivación
    vibrantPink, // Rosa vibrante
    cosmicRed, // Rojo cósmico
  ];

  // Gradiente Activo (Verde-Azul)
  static const List<Color> activeGradient = [
    activeGreen, // Verde activo
    strongBlue, // Azul fuerte
    lightGreen, // Verde claro
  ];

  // Gradiente Vitalidad (Amarillo-Naranja)
  static const List<Color> vitalityGradient = [
    vitalityYellow, // Amarillo vitalidad
    motivationOrange, // Naranja motivación
    lightYellow, // Amarillo claro
  ];

  // Gradiente Balance (Gris-Azul)
  static const List<Color> balanceGradient = [
    balanceGray, // Gris balance
    strongBlue, // Azul fuerte
    lightBlue, // Azul claro
  ];

  // === TEMA CLARO ===

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: vibrantPink,
            brightness: Brightness.light,
          ).copyWith(
            primary: vibrantPink,
            secondary: cosmicRed,
            tertiary: wellnessPurple,
            surface: surfaceLight,
            error: error,
            onPrimary: textOnVibrant,
            onSecondary: textOnVibrant,
            onTertiary: textOnVibrant,
            onSurface: textPrimary,
            onError: textOnVibrant,
          ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 32,
          letterSpacing: 1.2,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 28,
          letterSpacing: 1.0,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          letterSpacing: 0.8,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0.3,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.2,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.1,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.0,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.0,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          letterSpacing: 0.0,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: 0.0,
        ),
        bodySmall: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          letterSpacing: 0.0,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 10,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: vibrantPink,
        foregroundColor: textOnVibrant,
        elevation: 8,
        shadowColor: cosmicRed.withOpacity(0.3),
        titleTextStyle: const TextStyle(
          color: textOnVibrant,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vibrantPink,
          foregroundColor: textOnVibrant,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 6,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: neutralGray.withOpacity(0.3)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cosmicRed,
        foregroundColor: textOnVibrant,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neutralGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: vibrantPink, width: 2),
        ),
        filled: true,
        fillColor: surfaceLight,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: activeGreen,
        linearTrackColor: neutralGray,
        circularTrackColor: neutralGray,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: vibrantPink,
        unselectedItemColor: textSecondary,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),
    );
  }

  // === TEMA OSCURO ===

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: vibrantPink,
            brightness: Brightness.dark,
          ).copyWith(
            primary: vibrantPink,
            secondary: cosmicRed,
            tertiary: wellnessPurple,
            surface: surfaceDark,
            error: error,
            onPrimary: textOnVibrant,
            onSecondary: textOnVibrant,
            onTertiary: textOnVibrant,
            onSurface: textOnDark,
            onError: textOnVibrant,
          ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 32,
          letterSpacing: 1.2,
          color: textOnDark,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 28,
          letterSpacing: 1.0,
          color: textOnDark,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 24,
          letterSpacing: 0.8,
          color: textOnDark,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          letterSpacing: 0.5,
          color: textOnDark,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0.3,
          color: textOnDark,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.2,
          color: textOnDark,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          letterSpacing: 0.1,
          color: textOnDark,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.0,
          color: textOnDark,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 0.0,
          color: textOnDark,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          letterSpacing: 0.0,
          color: textOnDark,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          letterSpacing: 0.0,
          color: textOnDark,
        ),
        bodySmall: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          letterSpacing: 0.0,
          color: textOnDark,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.5,
          color: textOnDark,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.3,
          color: textOnDark,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 10,
          letterSpacing: 0.2,
          color: textOnDark,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cosmicRed,
        foregroundColor: textOnVibrant,
        elevation: 8,
        titleTextStyle: const TextStyle(
          color: textOnVibrant,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vibrantPink,
          foregroundColor: textOnVibrant,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 6,
          shadowColor: cosmicRed.withOpacity(0.6),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: wellnessPurple.withOpacity(0.3)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: wellnessPurple,
        foregroundColor: textOnVibrant,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: wellnessPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: vibrantPink, width: 2),
        ),
        filled: true,
        fillColor: surfaceDark,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          color: textOnDark,
        ),
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: activeGreen,
        linearTrackColor: surfaceDark,
        circularTrackColor: surfaceDark,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: vibrantPink,
        unselectedItemColor: textMuted,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),
    );
  }

  // === GRADIENTES PERSONALIZADOS ===

  static LinearGradient get primaryGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: vibrantGradient,
    );
  }

  static LinearGradient get wellnessGradient {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [wellnessPurple, lightPink, surfaceLight],
    );
  }

  static LinearGradient get cosmicGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [cosmicRed, vibrantPink, motivationOrange],
    );
  }

  static LinearGradient get neutralGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [neutralGray, balanceGray, surfaceLight],
    );
  }

  // === GRADIENTES ESPECIALIZADOS ===

  // Gradiente de bienvenida (especial para yoga/estiramientos)
  static LinearGradient get welcomeGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        wellnessPurple, // Morado wellness
        vibrantPink, // Rosa vibrante
        cosmicRed, // Rojo cósmico
      ],
    );
  }

  // Gradiente de progreso (para barras de progreso y logros)
  static LinearGradient get progressGradient {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        activeGreen, // Verde activo para progreso
        motivationOrange, // Naranja motivación
      ],
    );
  }

  // Gradiente de fondo limpio
  static LinearGradient get backgroundGradient {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        neutralGray, // Gris neutro
        surfaceLight, // Blanco
        neutralGray, // Gris neutro
      ],
    );
  }

  // Gradiente de perfil usuario
  static LinearGradient get profileGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        strongBlue, // Azul fuerte
        lightBlue, // Azul claro
        vibrantPink, // Rosa vibrante
      ],
    );
  }

  // Gradiente de entrenamiento
  static LinearGradient get workoutGradient {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        motivationOrange, // Naranja motivación
        activeGreen, // Verde activo
        vitalityYellow, // Amarillo vitalidad
      ],
    );
  }

  // === MÉTODOS DE UTILIDAD ===

  // Color dinámico para progreso
  static Color getProgressColor(double progress) {
    if (progress < 0.3) return cosmicRed;
    if (progress < 0.6) return motivationOrange;
    if (progress < 0.8) return activeGreen;
    return wellnessPurple;
  }

  // Colores por categoría
  static Color getWellnessColor() => wellnessPurple;
  static Color getProgressColorStatic() => activeGreen;
  static Color getHeaderColor() => vibrantPink;
  static Color getBackgroundClean() => neutralGray;
  static Color getTextPrimary() => softBlack;
  static Color getTextSecondary() => textSecondary;
  static Color getMotivationColor() => motivationOrange;
  static Color getProfileColor() => strongBlue;
  static Color getVitalityColor() => vitalityYellow;
  static Color getBalanceColor() => balanceGray;

  // Colores para botones específicos
  static Color getTrainNowColor() => motivationOrange;
  static Color getAchievementColor() => activeGreen;
  static Color getNotificationColor() => vitalityYellow;
  static Color getSecondaryElementColor() => balanceGray;

  // Gradientes por contexto
  static LinearGradient getGradientForContext(String context) {
    switch (context.toLowerCase()) {
      case 'wellness':
      case 'yoga':
      case 'stretching':
        return welcomeGradient;
      case 'workout':
      case 'training':
        return workoutGradient;
      case 'profile':
      case 'user':
        return profileGradient;
      case 'progress':
      case 'achievement':
        return progressGradient;
      case 'motivation':
        return primaryGradient;
      default:
        return primaryGradient;
    }
  }

  // Método para obtener color basado en estado emocional
  static Color getEmotionalColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'energetic':
      case 'motivated':
        return motivationOrange;
      case 'calm':
      case 'relaxed':
        return wellnessPurple;
      case 'focused':
      case 'active':
        return activeGreen;
      case 'confident':
      case 'strong':
        return strongBlue;
      case 'happy':
      case 'vibrant':
        return vibrantPink;
      case 'balanced':
      case 'neutral':
        return balanceGray;
      default:
        return vibrantPink;
    }
  }
}
