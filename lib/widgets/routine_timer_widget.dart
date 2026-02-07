import 'package:flutter/material.dart';
import 'package:odometer/odometer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../theme/eva_colors.dart';

/// Widget de temporizador para rutinas con contador animado
class RoutineTimerWidget extends StatefulWidget {
  final int totalSeconds; // Duración total de la rutina en segundos
  final VoidCallback? onComplete; // Callback cuando termina el timer
  final bool autoStart; // Si debe iniciar automáticamente

  const RoutineTimerWidget({
    super.key,
    required this.totalSeconds,
    this.onComplete,
    this.autoStart = false,
  });

  @override
  State<RoutineTimerWidget> createState() => _RoutineTimerWidgetState();
}

class _RoutineTimerWidgetState extends State<RoutineTimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    if (widget.autoStart) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isCompleted) {
      _resetTimer();
    }
    
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isCompleted = true;
          _showCompletionDialog();
          widget.onComplete?.call();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.totalSeconds;
      _isRunning = false;
      _isCompleted = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: EvaColors.vibrantPink,
        title: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Felicitaciones!',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '¡Completaste tu rutina! 💪\n\nSigue así y alcanzarás tus metas.',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Continuar',
                style: GoogleFonts.lato(
                  color: EvaColors.vibrantPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isCompleted
              ? [Colors.green[400]!, Colors.green[600]!]
              : _isRunning
                  ? [EvaColors.vibrantPink, EvaColors.cosmicRed]
                  : [EvaColors.wellnessPurple, Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isRunning ? EvaColors.vibrantPink : EvaColors.wellnessPurple)
                .withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Text(
            _isCompleted ? '¡Completado!' : 'Tiempo de Rutina',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Temporizador con Odometer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minutos
              AnimatedSlideOdometerNumber(
                odometerNumber: OdometerNumber(minutes),
                duration: const Duration(milliseconds: 300),
                numberTextStyle: GoogleFonts.orbitron(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              
              // Separador ":"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  ':',
                  style: GoogleFonts.orbitron(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Segundos
              AnimatedSlideOdometerNumber(
                odometerNumber: OdometerNumber(seconds),
                duration: const Duration(milliseconds: 300),
                numberTextStyle: GoogleFonts.orbitron(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Botones de control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Iniciar/Pausar
              if (!_isCompleted)
                ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Pausar' : 'Iniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: EvaColors.vibrantPink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              
              const SizedBox(width: 12),
              
              // Botón Reiniciar
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh, color: Colors.white),
                iconSize: 32,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Barra de progreso
          if (!_isCompleted)
            Column(
              children: [
                LinearProgressIndicator(
                  value: 1 - (_remainingSeconds / widget.totalSeconds),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${((1 - (_remainingSeconds / widget.totalSeconds)) * 100).toStringAsFixed(0)}% completado',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
