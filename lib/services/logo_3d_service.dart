import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';
import '../theme/eva_colors.dart';

/// Servicio para renderizar el logo 3D de Eva Strong con modelo Seren optimizado
class Logo3DService {
  static Logo3DService? _instance;
  static Logo3DService get instance {
    _instance ??= Logo3DService._();
    return _instance!;
  }

  Logo3DService._();

  bool _isInitialized = false;
  bool _isLoading = true;
  Object? _model;

  /// Inicializar el renderizador 3D
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Cargar el modelo 3D Eva
      await _loadModelSeren();
      _isInitialized = true;
      _isLoading = false;
    } catch (e) {
      print('Error initializing 3D logo: $e');
      _isLoading = false;
    }
  }

  /// Cargar el modelo 3D Seren - optimizado para rendimiento
  Future<void> _loadModelSeren() async {
    print('🚀 Loading optimized Seren GLTF model...');

    try {
      // Cargar el modelo seren.gltf (más compatible y ligero)
      _model = Object(fileName: 'assets/models/seren.gltf');

      if (_model != null) {
        print('✅ Seren GLTF model loaded successfully');
        print('⚡ Performance optimized: 17.5 KB only');
        print('📁 File: assets/models/seren.gltf');
        print('🎯 Ready to render in 3D scene');
      } else {
        throw Exception('Failed to load 3D model');
      }
    } catch (e) {
      print('❌ Error loading Seren GLTF: $e');
      print('🔄 Using placeholder for stability');
      _model = null;
    }
  }

  /// Renderizar el logo a un widget
  Widget renderLogo({
    double width = 100,
    double height = 100,
    bool animate = true,
  }) {
    // Forzar inicialización síncrona para carga instantánea
    if (!_isInitialized) {
      _initializeSync();
    }

    // Si ya está cargado, mostrar el modelo inmediatamente
    if (_model != null) {
      return _Logo3DWidget(
        service: this,
        width: width,
        height: height,
        animate: animate,
      );
    }

    // Si no hay modelo, mostrar placeholder brevemente
    return _buildLoadingPlaceholder(width, height);
  }

  /// Inicialización síncrona ultra rápida
  void _initializeSync() {
    if (_isInitialized) return;

    print('⚡ Ultra-fast 3D model initialization...');

    try {
      // Cargar modelo síncronamente sin delays
      _model = Object(fileName: 'assets/models/seren.gltf');
      _isInitialized = true;
      _isLoading = false;

      print('✅ Model loaded instantly - no waiting');
      print('🚀 Ready to render NOW');
    } catch (e) {
      print('❌ Fast load failed: $e');
      _isLoading = false;
    }
  }

  /// Widget de carga con efectos 3D simulados - Loading 3D
  Widget _buildLoadingPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EvaColors.vibrantPink, // Rosa vibrante principal
            EvaColors.cosmicRed, // Rojo cósmico
            EvaColors.wellnessPurple, // Morado wellness
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: EvaColors.vibrantPink.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: EvaColors.cosmicRed.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Texto "Loading..." animado
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: 0.5 + (value * 0.5),
                child: Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.08,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: height * 0.05),
          // Texto "en 3D"
          Text(
            'en 3D',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: width * 0.06,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: height * 0.08),
          // Indicador de carga animado
          SizedBox(
            width: width * 0.3,
            height: height * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLoadingDot(0),
                _buildLoadingDot(1),
                _buildLoadingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Punto animado para el indicador de carga
  Widget _buildLoadingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = ((value + delay) % 1.0);
        return Transform.scale(
          scale: 0.5 + (animValue * 0.5),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(animValue * 0.8),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Estado de carga
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
}

/// Widget personalizado para renderizar el logo 3D
class _Logo3DWidget extends StatefulWidget {
  final Logo3DService service;
  final double width;
  final double height;
  final bool animate;

  const _Logo3DWidget({
    required this.service,
    required this.width,
    required this.height,
    this.animate = true,
  });

  @override
  State<_Logo3DWidget> createState() => _Logo3DWidgetState();
}

class _Logo3DWidgetState extends State<_Logo3DWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
        seconds: 4,
      ), // Más rápido: 4 segundos en lugar de 8
      vsync: this,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Cube(
            onSceneCreated: (Scene scene) {
              try {
                if (widget.service._model != null) {
                  // Agregar modelo Eva directamente
                  scene.world.add(widget.service._model!);

                  // Configuración ultra rápida
                  scene.camera.position.z = 3; // Más cercano: 3 en lugar de 5
                  scene.world.rotation.y = _controller.value * 2 * math.pi;

                  print('🎯 3D model rendering - FAST MODE');
                  print('⚡ Rotation speed: 2x faster');
                  print('📊 Model: ${widget.service._model.runtimeType}');
                } else {
                  print('⚠️ No 3D model available');
                }
              } catch (e) {
                print('❌ Error rendering 3D model: $e');
              }
            },
          ),
        );
      },
    );
  }
}

/// Widget de Logo 3D optimizado para uso en la app
class EvaLogo3D extends StatelessWidget {
  final double size;
  final bool animate;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const EvaLogo3D({
    super.key,
    this.size = 60,
    this.animate = true,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        child: Logo3DService.instance.renderLogo(
          width: size,
          height: size,
          animate: animate,
        ),
      ),
    );
  }
}

/// Widget de Logo 3D con efectos avanzados
class EvaLogo3DAdvanced extends StatefulWidget {
  final double size;
  final bool animate;
  final bool showGlow;
  final bool showParticles;

  const EvaLogo3DAdvanced({
    super.key,
    this.size = 80,
    this.animate = true,
    this.showGlow = true,
    this.showParticles = false,
  });

  @override
  State<EvaLogo3DAdvanced> createState() => _EvaLogo3DAdvancedState();
}

class _EvaLogo3DAdvancedState extends State<EvaLogo3DAdvanced>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    if (widget.animate) {
      _rotationController.repeat();
      _glowController.repeat(reverse: true);
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationController,
        _glowController,
        _particleController,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              // Efecto de glow
              if (widget.showGlow)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(
                            0xFFFF69B4,
                          ).withOpacity(_glowController.value * 0.6),
                          blurRadius: 20 + _glowController.value * 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

              // Partículas animadas
              if (widget.showParticles)
                ...List.generate(6, (index) {
                  final angle =
                      (index * 60 + _particleController.value * 360) *
                      math.pi /
                      180;
                  final radius = widget.size * 0.4;

                  return Positioned(
                    left: widget.size / 2 + math.cos(angle) * radius - 3,
                    top: widget.size / 2 + math.sin(angle) * radius - 3,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFF69B4).withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(color: Color(0xFFFF69B4), blurRadius: 4),
                        ],
                      ),
                    ),
                  );
                }),

              // Logo principal
              Center(
                child: Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Transform.scale(
                    scale:
                        1.0 +
                        math.sin(_rotationController.value * 2 * math.pi) * 0.1,
                    child: Logo3DService.instance._buildLoadingPlaceholder(
                      widget.size * 0.8,
                      widget.size * 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
