import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/routine_recommendation_service.dart';

class RoutineExecutionScreen extends StatefulWidget {
  final PersonalizedRoutine routine;

  const RoutineExecutionScreen({super.key, required this.routine});

  @override
  _RoutineExecutionScreenState createState() => _RoutineExecutionScreenState();
}

class _RoutineExecutionScreenState extends State<RoutineExecutionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String _currentPhase = 'calentamiento';
  int _currentExerciseIndex = 0;
  int _currentCycle = 1;
  int _remainingTime = 0;
  bool _isRunning = false;
  bool _isResting = false;
  Timer? _timer;

  List<Exercise> get _currentExercises {
    switch (_currentPhase) {
      case 'calentamiento':
        return widget.routine.calentamiento.exercises;
      case 'principal':
        return widget.routine.principal.exercises;
      case 'enfriamiento':
        return widget.routine.enfriamiento.exercises;
      default:
        return [];
    }
  }

  Exercise get _currentExercise {
    if (_currentExercises.isEmpty) return _currentExercises[0];
    return _currentExercises[_currentExerciseIndex];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _startExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startExercise() {
    final exercise = _currentExercise;
    setState(() {
      _remainingTime = exercise.timeSeconds ?? 30;
      _isResting = false;
      _isRunning = true;
    });
    _controller.repeat();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
        if (_remainingTime <= 0) {
          timer.cancel();
          _controller.stop();
          _controller.reset();
          _onExerciseComplete();
        }
      });
    });
  }

  void _onExerciseComplete() {
    final exercise = _currentExercise;

    if (exercise.restSeconds > 0 && _currentPhase == 'principal') {
      _startRest();
    } else {
      _nextExercise();
    }
  }

  void _startRest() {
    final exercise = _currentExercise;
    setState(() {
      _remainingTime = exercise.restSeconds;
      _isResting = true;
      _isRunning = false;
    });
    HapticFeedback.lightImpact();
    _startTimer();
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _currentExercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
      _startExercise();
    } else {
      _onPhaseComplete();
    }
  }

  void _onPhaseComplete() {
    if (_currentPhase == 'principal' &&
        _currentCycle < widget.routine.mainCycles) {
      setState(() {
        _currentCycle++;
        _currentExerciseIndex = 0;
      });
      _startExercise();
    } else {
      _nextPhase();
    }
  }

  void _nextPhase() {
    switch (_currentPhase) {
      case 'calentamiento':
        setState(() {
          _currentPhase = 'principal';
          _currentExerciseIndex = 0;
          _currentCycle = 1;
        });
        _showPhaseDialog('Parte Principal', '¡Comienza el entrenamiento!');
        break;
      case 'principal':
        setState(() {
          _currentPhase = 'enfriamiento';
          _currentExerciseIndex = 0;
        });
        _showPhaseDialog('Enfriamiento', 'Estiramientos y relajación');
        break;
      case 'enfriamiento':
        _showCompletionDialog();
        break;
    }

    if (_currentPhase != 'enfriamiento') {
      Future.delayed(const Duration(seconds: 2), () {
        _startExercise();
      });
    }
  }

  void _showPhaseDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Comenzar'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Rutina Completada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text('Has completado "${widget.routine.name}"'),
            const SizedBox(height: 8),
            Text('Duración total: ${widget.routine.duration} minutos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a pantalla anterior
            },
            child: const Text('Finalizar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartRoutine();
            },
            child: const Text('Repetir'),
          ),
        ],
      ),
    );
  }

  void _restartRoutine() {
    setState(() {
      _currentPhase = 'calentamiento';
      _currentExerciseIndex = 0;
      _currentCycle = 1;
      _remainingTime = 0;
      _isRunning = false;
      _isResting = false;
    });
    _startExercise();
  }

  void _togglePause() {
    if (_isRunning) {
      _timer?.cancel();
      _controller.stop();
      setState(() => _isRunning = false);
    } else {
      _startTimer();
      _controller.repeat();
      setState(() => _isRunning = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(widget.routine.name),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePause,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitConfirmation(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(child: _buildMainContent()),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_currentPhase) {
      case 'calentamiento':
        return Colors.orange[50]!;
      case 'principal':
        return Colors.purple[50]!;
      case 'enfriamiento':
        return Colors.blue[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getPhaseDisplayName(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentPhase == 'principal')
                Text(
                  'Ciclo $_currentCycle/${widget.routine.mainCycles}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentExerciseIndex + 1) / _currentExercises.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getPhaseColor()),
          ),
          const SizedBox(height: 4),
          Text(
            'Ejercicio ${_currentExerciseIndex + 1}/${_currentExercises.length}',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_currentExercises.isEmpty) {
      return const Center(child: Text('No hay ejercicios disponibles'));
    }

    final exercise = _currentExercise;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isResting ? 1.0 : (0.8 + _animation.value * 0.2),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _getPhaseColor(),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: _getPhaseColor().withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            exercise.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            exercise.shortDescription,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildTimerDisplay(),
          if (_isResting) ...[
            const SizedBox(height: 16),
            Text(
              'DESCANSO',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$minutes:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _getPhaseColor(),
            ),
          ),
          Text(
            _isResting ? 'Descanso' : 'Tiempo restante',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _isRunning || _isResting ? _togglePause : null,
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            label: Text(_isRunning ? 'Pausar' : 'Reanudar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _nextExercise,
            icon: const Icon(Icons.skip_next),
            label: const Text('Siguiente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getPhaseDisplayName() {
    switch (_currentPhase) {
      case 'calentamiento':
        return 'Calentamiento';
      case 'principal':
        return 'Parte Principal';
      case 'enfriamiento':
        return 'Enfriamiento';
      default:
        return '';
    }
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case 'calentamiento':
        return Colors.orange;
      case 'principal':
        return Colors.purple;
      case 'enfriamiento':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la rutina?'),
        content: const Text('Perderás el progreso actual. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Salir de la pantalla
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
