import 'package:flutter/material.dart';
import '../theme/eva_colors.dart';

/// Servicio para efectos 3D profesionales con nueva paleta de colores
class Effects3DService {
  /// Gradientes 3D profesionales - Nueva Paleta Vibrante
  static const LinearGradient primaryGradient3D = LinearGradient(
    colors: [
      EvaColors.vibrantPink, // Rosa vibrante principal
      EvaColors.cosmicRed, // Rojo cósmico
      EvaColors.wellnessPurple, // Morado wellness
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient3D = LinearGradient(
    colors: [
      EvaColors.neutralGray, // Gris neutro
      EvaColors.lightPink, // Rosa claro
      Colors.white, // Blanco
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient buttonGradient3D = LinearGradient(
    colors: [
      EvaColors.motivationOrange, // Naranja motivación
      EvaColors.vibrantPink, // Rosa vibrante
      EvaColors.cosmicRed, // Rojo cósmico
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  /// Gradiente para wellness/yoga
  static LinearGradient get wellnessGradient3D => EvaColors.wellnessGradient;

  /// Gradiente para entrenamiento/motivación
  static LinearGradient get workoutGradient3D => EvaColors.workoutGradient;

  /// Gradiente para perfiles de usuario
  static LinearGradient get profileGradient3D => EvaColors.profileGradient;

  static const LinearGradient textGradient3D = LinearGradient(
    colors: [
      Colors.white, // Blanco puro
      EvaColors.lightPink, // Rosa muy claro
      EvaColors.neutralGray, // Gris neutro claro
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient whiteTextGradient3D = LinearGradient(
    colors: [Colors.white, EvaColors.lightPink, Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Sombras 3D con nuevos colores
  static const List<BoxShadow> primaryShadow3D = [
    BoxShadow(
      color: EvaColors.cosmicRed,
      blurRadius: 15,
      spreadRadius: 1,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: EvaColors.vibrantPink,
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevatedShadow3D = [
    BoxShadow(
      color: EvaColors.cosmicRed,
      blurRadius: 20,
      spreadRadius: 2,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: EvaColors.motivationOrange,
      blurRadius: 15,
      spreadRadius: 1,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> subtleShadow3D = [
    BoxShadow(
      color: EvaColors.balanceGray,
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: EvaColors.neutralGray,
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  // Sombras de texto
  static const List<Shadow> bigTextShadow3D = [
    Shadow(color: EvaColors.cosmicRed, blurRadius: 8, offset: Offset(2, 2)),
    Shadow(color: EvaColors.vibrantPink, blurRadius: 4, offset: Offset(1, 1)),
  ];

  static const List<Shadow> textShadow3D = [
    Shadow(color: EvaColors.cosmicRed, blurRadius: 4, offset: Offset(1, 1)),
    Shadow(
      color: EvaColors.vibrantPink,
      blurRadius: 2,
      offset: Offset(0.5, 0.5),
    ),
  ];

  /// AppBar con efectos 3D
  static PreferredSizeWidget appBar3D({
    required String title,
    required LinearGradient gradient,
    List<BoxShadow>? shadows,
    Widget? leading,
    List<Widget>? actions,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          boxShadow: shadows ?? primaryShadow3D,
        ),
        child: AppBar(
          title: text3D(
            text: title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            shadows: bigTextShadow3D,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: leading,
          actions: actions,
        ),
      ),
    );
  }

  /// Tarjeta con efectos 3D
  static Widget card3D({
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
    List<BoxShadow>? shadows,
    LinearGradient? gradient,
    double borderRadius = 15.0,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? cardGradient3D,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? subtleShadow3D,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }

  /// Botón con efectos 3D
  static Widget button3D({
    required Widget child,
    required VoidCallback onPressed,
    required LinearGradient gradient,
    List<BoxShadow>? shadows,
    EdgeInsets? padding,
    double borderRadius = 25.0,
    double? width,
    double? height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? primaryShadow3D,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  /// Icono con efectos 3D
  static Widget icon3D({
    required IconData icon,
    Color color = EvaColors.vibrantPink,
    double size = 24.0,
    List<Shadow>? shadows,
  }) {
    return Icon(
      icon,
      color: color,
      size: size,
      shadows: shadows ?? textShadow3D,
    );
  }

  /// Texto con efectos 3D
  static Widget text3D({
    required String text,
    required TextStyle style,
    List<Shadow>? shadows,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: style.copyWith(
        shadows: shadows ?? textShadow3D,
        foreground: Paint()
          ..shader = textGradient3D.createShader(
            const Rect.fromLTWH(0, 0, 200, 70),
          ),
      ),
    );
  }

  /// Decoración de cristal con efectos 3D
  static BoxDecoration glassDecoration3D({
    Color color = Colors.white,
    double opacity = 0.1,
    double borderRadius = 15.0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows ?? subtleShadow3D,
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
    );
  }

  /// Decoración neon con efectos 3D
  static BoxDecoration neonDecoration3D({
    Color color = EvaColors.vibrantPink,
    double intensity = 0.5,
    double borderRadius = 15.0,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color.withOpacity(intensity),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadows ?? primaryShadow3D,
      border: Border.all(color: color.withOpacity(0.8), width: 2),
    );
  }

  /// Gradiente de fondo para pantallas
  static LinearGradient get backgroundGradient3D =>
      EvaColors.backgroundGradient;

  /// Gradiente para botones de acción principal
  static LinearGradient get actionButtonGradient3D => buttonGradient3D;

  /// Gradiente para tarjetas informativas
  static LinearGradient get infoCardGradient3D => cardGradient3D;
}
