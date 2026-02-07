import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/eva_colors.dart';

class Eva3DModelWidget extends StatefulWidget {
  const Eva3DModelWidget({Key? key}) : super(key: key);

  @override
  State<Eva3DModelWidget> createState() => _Eva3DModelWidgetState();
}

class _Eva3DModelWidgetState extends State<Eva3DModelWidget> {
  // Controlador 3D con todas las funciones
  Flutter3DController controller = Flutter3DController();
  
  bool _isLoaded = false;
  bool _isRotating = false;
  List<String> _availableAnimations = [];
  String? _currentAnimation;

  @override
  void initState() {
    super.initState();
    
    // Escuchar cuando el modelo se cargue
    controller.onModelLoaded.addListener(() {
      setState(() {
        _isLoaded = controller.onModelLoaded.value;
      });
      
      if (_isLoaded) {
        _loadAnimations();
        // Iniciar rotación automática
        controller.startRotation(rotationSpeed: 15);
        setState(() => _isRotating = true);
      }
    });
  }

  Future<void> _loadAnimations() async {
    try {
      final animations = await controller.getAvailableAnimations();
      setState(() {
        _availableAnimations = animations ?? [];
        if (_availableAnimations.isNotEmpty) {
          _currentAnimation = _availableAnimations.first;
          // Reproducir primera animación en loop
          controller.playAnimation(
            animationName: _currentAnimation,
            loopCount: 0, // Loop infinito
          );
        }
      });
    } catch (e) {
      print('Error cargando animaciones: $e');
    }
  }

  void _toggleRotation() {
    if (_isRotating) {
      controller.pauseRotation();
    } else {
      controller.startRotation(rotationSpeed: 15);
    }
    setState(() => _isRotating = !_isRotating);
  }

  void _resetView() {
    controller.resetCameraOrbit();
    controller.resetCameraTarget();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            EvaColors.wellnessPurple.withOpacity(0.2),
            EvaColors.vibrantPink.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: EvaColors.vibrantPink.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Modelo 3D
            Expanded(
              child: Flutter3DViewer(
                controller: controller,
                src: 'assets/models/eva.glb', // Usar modelo eva.glb
                // Configuración del visor
                backgroundColor: Colors.transparent,
                // Controles táctiles habilitados
                enableTouch: true,
                // Carga progresiva
                progressBarColor: EvaColors.vibrantPink,
              ),
            ),
            
            // Controles
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isLoaded ? Icons.check_circle : Icons.hourglass_empty,
                        color: _isLoaded ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLoaded ? 'Modelo Cargado' : 'Cargando...',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Botones de control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Rotación
                      _buildControlButton(
                        icon: _isRotating ? Icons.pause : Icons.rotate_right,
                        label: _isRotating ? 'Pausar' : 'Rotar',
                        onPressed: _isLoaded ? _toggleRotation : null,
                      ),
                      
                      // Reset vista
                      _buildControlButton(
                        icon: Icons.refresh,
                        label: 'Reset',
                        onPressed: _isLoaded ? _resetView : null,
                      ),
                      
                      // Animación
                      if (_availableAnimations.isNotEmpty)
                        _buildControlButton(
                          icon: Icons.play_arrow,
                          label: 'Animar',
                          onPressed: () {
                            if (_currentAnimation != null) {
                              controller.playAnimation(
                                animationName: _currentAnimation,
                                loopCount: 1,
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  
                  // Texto descriptivo
                  const SizedBox(height: 8),
                  Text(
                    'Toca y arrastra para rotar',
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: EvaColors.vibrantPink.withOpacity(0.3),
            disabledBackgroundColor: Colors.grey.withOpacity(0.2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            color: onPressed != null ? Colors.white : Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
