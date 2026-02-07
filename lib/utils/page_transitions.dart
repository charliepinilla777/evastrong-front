import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// Helper class para transiciones de página con Material Motion
class PageTransitions {
  /// Transición con SharedAxis (horizontal)
  static Route<T> sharedAxisHorizontal<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Transición con FadeThrough
  static Route<T> fadeThrough<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Transición con FadeScale (para modales)
  static Route<T> fadeScale<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Container abierto (para tarjetas que se expanden)
  static Widget openContainer({
    required Widget closedBuilder,
    required Widget openBuilder,
    VoidCallback? onClosed,
    Color? closedColor,
    Color? openColor,
  }) {
    return OpenContainer(
      closedBuilder: (context, action) => closedBuilder,
      openBuilder: (context, action) => openBuilder,
      onClosed: onClosed != null ? (_) => onClosed() : null,
      closedElevation: 0,
      closedColor: closedColor ?? Colors.transparent,
      openColor: openColor ?? Colors.white,
      transitionDuration: const Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fadeThrough,
    );
  }
}
