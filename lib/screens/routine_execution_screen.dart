import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_strings.dart';
import '../services/exercise_gif_service.dart';
import '../widgets/routine_video_player.dart';
import '../services/exercise_instructions_service.dart';
import '../services/history_service.dart';
import '../services/routine_recommendation_service.dart';
import '../services/voice_coach_service.dart';
import '../theme/eva_colors.dart';

/// Representa un intervalo de tiempo dentro de la rutina.
class _IntervalSegment {
  final String name;
  final String phase;
  final String type;
  final int durationSeconds;

  const _IntervalSegment({
    required this.name,
    required this.phase,
    required this.type,
    required this.durationSeconds,
  });
}

class RoutineExecutionScreen extends StatefulWidget {
  final PersonalizedRoutine routine;

  const RoutineExecutionScreen({super.key, required this.routine});

  @override
  _RoutineExecutionScreenState createState() => _RoutineExecutionScreenState();
}

class _RoutineExecutionScreenState extends State<RoutineExecutionScreen>
    with TickerProviderStateMixin {

  // Trophy celebration animation
  late AnimationController _trophyController;
  late Animation<double> _trophyScale;
  late Animation<double> _trophyOpacity;

  // Timer circle pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Voz entrenadora
  final VoiceCoachService _voice = VoiceCoachService();

  // Segmentos de intervalo
  late final List<_IntervalSegment> _allSegments;
  final ScrollController _segmentScrollController = ScrollController();

  String _currentPhase = 'calentamiento';
  int _currentExerciseIndex = 0;
  int _currentCycle = 1;
  int _currentSet = 1;          // serie actual dentro del ejercicio
  int _remainingTime = 0;
  int _totalTime = 1;           // evita division por cero
  bool _isRunning = false;
  bool _isResting = false;      // descanso entre ejercicios
  bool _isSetResting = false;   // descanso entre series
  bool _isCompleted = false;
  bool _isPaused = false;
  Timer? _timer;

  int _completedSeconds = 0;
  int get _totalGoalSeconds => (widget.routine.duration * 60).clamp(1, 9999);

  // ─── Helpers de ejercicios ───────────────────────────────────────────────────

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

  Exercise? get _currentExercise {
    final list = _currentExercises;
    if (list.isEmpty) return null;
    final idx = _currentExerciseIndex.clamp(0, list.length - 1);
    return list[idx];
  }

  double get _progressPercent =>
      (_completedSeconds / _totalGoalSeconds * 100).clamp(0.0, 100.0);

  double get _timerProgress =>
      _totalTime > 0 ? (_remainingTime / _totalTime).clamp(0.0, 1.0) : 0.0;

  /// Fracción completada del ejercicio actual (0.0 → 1.0).
  double get _currentSegmentFill =>
      _totalTime > 0
          ? ((_totalTime - _remainingTime) / _totalTime).clamp(0.0, 1.0)
          : 0.0;

  /// Índice global en `_allSegments` que corresponde a la serie actual.
  int get _currentGlobalIndex {
    int idx = 0;
    final cal = widget.routine.calentamiento.exercises;
    for (int i = 0; i < cal.length; i++) {
      if (_currentPhase == 'calentamiento' && i == _currentExerciseIndex) {
        return idx + (_currentSet - 1).clamp(0, cal[i].sets - 1);
      }
      idx += cal[i].sets;
    }
    final prin = widget.routine.principal.exercises;
    for (int c = 0; c < widget.routine.mainCycles; c++) {
      for (int i = 0; i < prin.length; i++) {
        if (_currentPhase == 'principal' && c == _currentCycle - 1 && i == _currentExerciseIndex) {
          return idx + (_currentSet - 1).clamp(0, prin[i].sets - 1);
        }
        idx += prin[i].sets;
      }
    }
    final enf = widget.routine.enfriamiento.exercises;
    for (int i = 0; i < enf.length; i++) {
      if (_currentPhase == 'enfriamiento' && i == _currentExerciseIndex) {
        return idx + (_currentSet - 1).clamp(0, enf[i].sets - 1);
      }
      idx += enf[i].sets;
    }
    return (_allSegments.isEmpty ? 0 : _allSegments.length - 1);
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _trophyScale = CurvedAnimation(parent: _trophyController, curve: Curves.elasticOut);
    _trophyOpacity = CurvedAnimation(parent: _trophyController, curve: Curves.easeIn);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _allSegments = _buildSegments();
    _voice.init().then((_) {
      // Pequeño delay para que la app esté estable antes de hablar
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _voice.speak(_voice.phaseStart('calentamiento'));
      });
    });
    _startExercise();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voice.dispose();
    _trophyController.dispose();
    _pulseController.dispose();
    _segmentScrollController.dispose();
    super.dispose();
  }

  // ─── Lógica del temporizador ─────────────────────────────────────────────────

  void _startExercise() {
    final exercise = _currentExercise;
    if (exercise == null) {
      _onPhaseComplete();
      return;
    }
    setState(() {
      _currentSet = 1;
      _isPaused = false;
    });
    _startSet();
  }

  void _startSet() {
    final exercise = _currentExercise;
    if (exercise == null) return;
    final duration = exercise.timeSeconds ?? 30;
    setState(() {
      _remainingTime = duration;
      _totalTime = duration;
      _isResting = false;
      _isSetResting = false;
      _isRunning = true;
    });
    _pulseController.repeat(reverse: true);
    _startTimer();
    _scrollToCurrentSegment();

    // Voz: anuncia la serie (con pequeño delay para no solaparse con el prev speech)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      // Primera serie del ejercicio → anuncia nombre + serie
      if (_currentSet == 1) {
        _voice.speak(_voice.exerciseStart(exercise.name, exercise.repetitions));
      } else {
        _voice.speak(_voice.setStart(_currentSet, exercise.sets, exercise.repetitions));
      }
    });
  }

  void _scrollToCurrentSegment() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_segmentScrollController.hasClients) return;
      const segWidth = 40.0;
      final targetOffset = (_currentGlobalIndex * segWidth)
          .clamp(0.0, _segmentScrollController.position.maxScrollExtent);
      _segmentScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        if (!_isResting && !_isSetResting && _remainingTime > 0) _completedSeconds++;
        _remainingTime--;

        // ── Voz durante el timer ───────────────────────────────────────────
        if (!_isResting && !_isSetResting) {
          // Cuenta regresiva final: 3, 2, 1
          if (_remainingTime == 3 || _remainingTime == 2 || _remainingTime == 1) {
            _voice.speak(_voice.countdown(_remainingTime));
          }
          // Frase motivacional a mitad de la serie (solo si dura >10s)
          final half = _totalTime ~/ 2;
          if (_totalTime > 10 && _remainingTime == half) {
            _voice.speak(_voice.midExercise(_currentSet));
          }
        }
        // Aviso de fin de descanso entre series (3s antes)
        if (_isSetResting && _remainingTime == 3) {
          _voice.speak(_voice.setRestEnding());
        }

        if (_remainingTime <= 0) {
          timer.cancel();
          _pulseController.stop();
          _pulseController.reset();
          _onTimerComplete();
        }
      });
    });
  }

  void _onTimerComplete() {
    if (_isSetResting) {
      // Fin del descanso entre series → iniciar siguiente serie
      setState(() {
        _currentSet++;
        _isSetResting = false;
      });
      _startSet();
    } else if (_isResting) {
      // Fin del descanso entre ejercicios → siguiente ejercicio
      setState(() => _isResting = false);
      _nextExercise();
    } else {
      // Fin de una serie activa
      _onSetComplete();
    }
  }

  void _onSetComplete() {
    final exercise = _currentExercise;
    if (exercise == null) return;
    HapticFeedback.lightImpact();

    if (_currentSet < exercise.sets) {
      // Quedan más series → descanso entre series (15 seg)
      _startSetRest(15);
    } else {
      // Última serie del ejercicio → descanso entre ejercicios (solo en principal)
      if (exercise.restSeconds > 0 && _currentPhase == 'principal') {
        _startRest(exercise.restSeconds);
      } else {
        _nextExercise();
      }
    }
  }

  void _startSetRest(int seconds) {
    final nextSet = _currentSet + 1;
    final total = _currentExercise?.sets ?? 1;
    setState(() {
      _remainingTime = seconds;
      _totalTime = seconds;
      _isSetResting = true;
      _isResting = false;
      _isRunning = false;
    });
    _voice.speak(_voice.setRest(seconds, nextSet, total));
    _startTimer();
  }

  void _startRest(int seconds) {
    setState(() {
      _remainingTime = seconds;
      _totalTime = seconds;
      _isResting = true;
      _isSetResting = false;
      _isRunning = false;
    });
    _voice.speak(_voice.exerciseRest(seconds));
    _startTimer();
  }

  void _nextExercise() {
    final list = _currentExercises;
    if (_currentExerciseIndex < list.length - 1) {
      setState(() => _currentExerciseIndex++);
      _startExercise();
    } else {
      _onPhaseComplete();
    }
  }

  void _onPhaseComplete() {
    if (_currentPhase == 'principal' && _currentCycle < widget.routine.mainCycles) {
      setState(() {
        _currentCycle++;
        _currentExerciseIndex = 0;
      });
      _startExercise();
      return;
    }
    _nextPhase();
  }

  void _nextPhase() {
    switch (_currentPhase) {
      case 'calentamiento':
        setState(() {
          _currentPhase = 'principal';
          _currentExerciseIndex = 0;
          _currentCycle = 1;
        });
        _voice.speak(_voice.phaseTransition('principal'));
        _showPhaseDialog(
          AppStrings.of(context).phaseMainTitle,
          AppStrings.of(context).phaseMainSubtitle,
        );
        break;
      case 'principal':
        setState(() {
          _currentPhase = 'enfriamiento';
          _currentExerciseIndex = 0;
        });
        _voice.speak(_voice.phaseTransition('enfriamiento'));
        _showPhaseDialog(
          AppStrings.of(context).phaseCooldownTitle,
          AppStrings.of(context).phaseCooldownSubtitle,
        );
        break;
      case 'enfriamiento':
        _showCelebration();
        return;
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _startExercise();
    });
  }

  void _showPhaseDialog(String title, String message, {String? startLabel}) {
    _timer?.cancel();
    _pulseController.stop();

    final List<Color> dialogGradient = _getPhaseGradientColors();
    final Color phaseColor = _getPhaseColor();
    final IconData phaseIcon = _getPhaseIcon();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1.0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        dialogGradient[0].withOpacity(0.92),
                        dialogGradient[1].withOpacity(0.88),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.22),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: phaseColor.withOpacity(0.45),
                        blurRadius: 40,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono de fase con glow
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: phaseColor.withOpacity(0.5),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(phaseIcon, size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      // Titulo
                      Text(
                        title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Separador decorativo
                      Container(
                        width: 48,
                        height: 2,
                        decoration: BoxDecoration(
                          color: EvaColors.vitalityYellow.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Mensaje
                      Text(
                        message,
                        style: GoogleFonts.raleway(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.88),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      // Botón
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                EvaColors.vibrantPink,
                                EvaColors.cosmicRed,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: EvaColors.cosmicRed.withOpacity(0.45),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (startLabel ?? AppStrings.of(context).begin).toUpperCase(),
                                style: GoogleFonts.raleway(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCelebration() {
    _timer?.cancel();
    _pulseController.stop();
    HapticFeedback.heavyImpact();
    setState(() => _isCompleted = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _trophyController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _voice.speak(_voice.completion(widget.routine.duration));
    });
    HistoryService.saveCompleted(
      routineName: widget.routine.name,
      durationMinutes: widget.routine.duration,
      category: widget.routine.principal.exercises.isNotEmpty
          ? widget.routine.principal.exercises.first.type
          : 'general',
    ).catchError((_) {});
  }

  void _restartRoutine() {
    _trophyController.reset();
    setState(() {
      _currentPhase = 'calentamiento';
      _currentExerciseIndex = 0;
      _currentCycle = 1;
      _currentSet = 1;
      _remainingTime = 0;
      _totalTime = 1;
      _isRunning = false;
      _isResting = false;
      _isSetResting = false;
      _isCompleted = false;
      _isPaused = false;
      _completedSeconds = 0;
    });
    _startExercise();
  }

  void _togglePause() {
    if (!_isPaused) {
      // Pausar
      _timer?.cancel();
      _pulseController.stop();
      setState(() {
        _isPaused = true;
        _isRunning = false;
      });
    } else {
      // Reanudar
      setState(() {
        _isPaused = false;
        if (!_isResting && !_isSetResting) {
          _isRunning = true;
          _pulseController.repeat(reverse: true);
        }
      });
      _startTimer();
    }
  }

  // ─── Segmentos de intervalo ──────────────────────────────────────────────────

  List<_IntervalSegment> _buildSegments() {
    final list = <_IntervalSegment>[];

    void addExercise(Exercise ex, String phase) {
      final totalSets = ex.sets.clamp(1, 99);
      for (int s = 1; s <= totalSets; s++) {
        list.add(_IntervalSegment(
          name: totalSets > 1 ? '${ex.name} — Serie $s/$totalSets' : ex.name,
          phase: phase,
          type: ex.type,
          durationSeconds: ex.timeSeconds ?? 30,
        ));
      }
    }

    for (final ex in widget.routine.calentamiento.exercises) {
      addExercise(ex, 'calentamiento');
    }
    for (int c = 0; c < widget.routine.mainCycles; c++) {
      for (final ex in widget.routine.principal.exercises) {
        addExercise(ex, 'principal');
      }
    }
    for (final ex in widget.routine.enfriamiento.exercises) {
      addExercise(ex, 'enfriamiento');
    }

    return list;
  }

  /// Devuelve el color del segmento según la fase del ejercicio (paleta premium).
  Color _phaseSegmentColor(String phase) {
    switch (phase) {
      case 'calentamiento': return EvaColors.motivationOrange;
      case 'principal':     return EvaColors.vibrantPink;
      case 'enfriamiento':  return EvaColors.strongBlue;
      default:              return EvaColors.balanceGray;
    }
  }

  String _phaseSegmentLabel(String phase) =>
      AppStrings.of(context).phaseSegmentLabel(phase);

  /// Barra de segmentos: un bloque por intervalo, se llena según intensidad.
  Widget _buildIntervalBar() {
    if (_allSegments.isEmpty) return const SizedBox.shrink();
    final currentIdx = _currentGlobalIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leyenda de fases
        Row(
          children: [
            _legendDot(EvaColors.motivationOrange, AppStrings.of(context).phaseWarmupLegend),
            const SizedBox(width: 10),
            _legendDot(EvaColors.vibrantPink, AppStrings.of(context).phaseMainLegend),
            const SizedBox(width: 10),
            _legendDot(EvaColors.strongBlue, AppStrings.of(context).phaseCooldownLegend),
            const Spacer(),
            Text(
              AppStrings.of(context).intervalLabel(currentIdx + 1, _allSegments.length),
              style: GoogleFonts.raleway(
                fontSize: 10,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Barra de segmentos
        SizedBox(
          height: 22,
          child: ListView.separated(
            controller: _segmentScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _allSegments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 3),
            itemBuilder: (context, i) {
              final seg = _allSegments[i];
              final color = _phaseSegmentColor(seg.phase);
              final isDone = i < currentIdx;
              final isCurrent = i == currentIdx;
              final fill = isDone
                  ? 1.0
                  : (isCurrent ? _currentSegmentFill : 0.0);

              return Tooltip(
                message: '${seg.name} — ${_phaseSegmentLabel(seg.phase)}',
                child: SizedBox(
                  width: 36,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Fondo vacío — glass oscuro
                        Container(
                          color: Colors.white.withOpacity(0.10),
                        ),
                        // Relleno animado
                        if (fill > 0)
                          AnimatedFractionallySizedBox(
                            widthFactor: fill,
                            heightFactor: 1.0,
                            alignment: Alignment.centerLeft,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withOpacity(0.75)],
                                ),
                              ),
                            ),
                          ),
                        // Icono check cuando completo
                        if (isDone)
                          Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        // Borde resaltado del actual
                        if (isCurrent)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: color,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
            ],
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 10,
            color: Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) return _buildCelebrationScreen();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildPremiumAppBar(),
      body: Stack(
        children: [
          // Fondo degradado rico por fase
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getPhaseGradientColors(),
              ),
            ),
          ),
          // Overlay oscuro para legibilidad
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.70),
                ],
              ),
            ),
          ),
          // Orbe decorativo superior
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getPhaseColor().withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Orbe decorativo inferior
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    EvaColors.magentaDark.withOpacity(0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                _buildProgressHeader(),
                Expanded(child: _buildMainContent()),
                _buildBottomSkipButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.40),
                  _getPhaseColor().withOpacity(0.20),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.12), width: 1),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Back / close button circular glass
                    _buildGlassActionButton(
                      icon: Icons.close_rounded,
                      onTap: _showExitConfirmation,
                    ),
                    const SizedBox(width: 8),
                    // Titulo de la rutina
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.routine.name,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.6,
                              shadows: [
                                Shadow(
                                  color: _getPhaseColor().withOpacity(0.6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getPhaseDisplayName().toUpperCase(),
                            style: GoogleFonts.raleway(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getPhaseColor(),
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón volumen glass
                    StatefulBuilder(
                      builder: (context, setIconState) => _buildGlassActionButton(
                        icon: _voice.isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        onTap: () {
                          setIconState(() => _voice.toggleMute());
                          if (_voice.isMuted) _voice.stop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassActionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  // ─── Progress header ─────────────────────────────────────────────────────────

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fase actual + ciclo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Phase badge con gradiente y glow
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getPhaseColor(),
                            _getPhaseColor().withOpacity(0.70),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getPhaseColor().withOpacity(0.45),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getPhaseIcon(), size: 12, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            _getPhaseDisplayName().toUpperCase(),
                            style: GoogleFonts.raleway(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_currentPhase == 'principal')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.20), width: 1),
                        ),
                        child: Text(
                          AppStrings.of(context).cycleLabel(_currentCycle, widget.routine.mainCycles),
                          style: GoogleFonts.raleway(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Barra de intervalos
                _buildIntervalBar(),

                const SizedBox(height: 10),

                // Meta diaria + tiempo
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: EvaColors.motivationOrange,
                      size: 15,
                      shadows: [Shadow(color: EvaColors.motivationOrange.withOpacity(0.6), blurRadius: 6)],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.of(context).goalLabel(widget.routine.duration),
                      style: GoogleFonts.raleway(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: EvaColors.vitalityYellow,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(_completedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_completedSeconds % 60).toString().padLeft(2, '0')} / ${widget.routine.duration}:00',
                      style: GoogleFonts.raleway(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.70),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                // Barra de progreso general
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: FAProgressBar(
                    currentValue: _progressPercent,
                    displayText: '%',
                    size: 18,
                    animatedDuration: const Duration(milliseconds: 500),
                    progressColor: EvaColors.vibrantPink,
                    backgroundColor: Colors.white.withOpacity(0.14),
                    displayTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Main content ─────────────────────────────────────────────────────────────

  Widget _buildMainContent() {
    final exercise = _currentExercise;
    if (exercise == null) {
      return Center(
        child: Text(
          AppStrings.of(context).noExercises,
          style: GoogleFonts.raleway(color: Colors.white),
        ),
      );
    }

    final gifUrl = ExerciseGifService.getGifUrl(
      exercise.exerciseId,
      exerciseType: exercise.type,
    );
    final hasVideo = ExerciseGifService.hasVideo(exercise.videoUrl);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // GIF / Descanso
          if (_isResting)
            _buildRestIndicator()
          else if (_isSetResting)
            _buildSetRestIndicator(exercise)
          else if (gifUrl != null)
            _buildGifDisplay(gifUrl)
          else
            _buildPulsingIcon(),

          const SizedBox(height: 14),

          // Nombre del ejercicio
          Text(
            AppStrings.of(context).languageCode == 'en'
                ? ExerciseInstructionsService.translateName(exercise.name)
                : exercise.name,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  color: _getPhaseColor().withOpacity(0.55),
                  blurRadius: 12,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),

          // Descripcion corta
          if (exercise.shortDescription.isNotEmpty)
            Text(
              AppStrings.of(context).languageCode == 'en'
                  ? ExerciseInstructionsService.translateShortDesc(exercise.shortDescription)
                  : exercise.shortDescription,
              style: GoogleFonts.raleway(
                fontSize: 13,
                color: Colors.white.withOpacity(0.72),
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

          // Zona muscular badge premium
          if (exercise.zone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getPhaseColor().withOpacity(0.75),
                    EvaColors.magentaDark.withOpacity(0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: _getPhaseColor().withOpacity(0.30),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                AppStrings.of(context).exerciseZone(exercise.zone).toUpperCase(),
                style: GoogleFonts.raleway(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Indicador de series
          if (!_isResting)
            _buildSetIndicator(exercise),

          const SizedBox(height: 14),

          // Instrucciones paso a paso
          if (!_isResting && !_isSetResting)
            _buildInstructions(exercise),

          const SizedBox(height: 18),

          // Temporizador + botón combinados
          _buildTimerButton(),

          if (_isResting) ...[
            const SizedBox(height: 12),
            Text(
              'DESCANSA — próximo ejercicio',
              style: GoogleFonts.raleway(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: EvaColors.strongBlue.withOpacity(0.9),
                letterSpacing: 2.0,
              ),
            ),
          ],

          // Botón video
          if (hasVideo && !_isSetResting && !_isResting) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _showVideoDialog(exercise.videoUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _getPhaseColor().withOpacity(0.45),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle_outline, size: 18, color: _getPhaseColor()),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.of(context).viewDemo,
                          style: GoogleFonts.raleway(
                            color: Colors.white.withOpacity(0.90),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ─── Indicador de series — el "corazón" de la experiencia ────────────────────

  Widget _buildSetIndicator(Exercise exercise) {
    final color = _getPhaseColor();
    final totalSets = exercise.sets.clamp(1, 99);
    final reps = exercise.repetitions ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Frase del entrenador — Playfair Display italic, dorado
              Text(
                _trainerMessage(exercise),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: EvaColors.vitalityYellow.withOpacity(0.90),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Serie actual — numero enorme Cormorant Garamond
              if (!_isSetResting) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${AppStrings.of(context).series} ',
                      style: GoogleFonts.raleway(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.55),
                        letterSpacing: 2.5,
                      ),
                    ),
                    Text(
                      '$_currentSet',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: color.withOpacity(0.7),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      ' / $totalSets',
                      style: GoogleFonts.raleway(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),

                // Dots de series con glow
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalSets, (i) {
                    final done = i < _currentSet - 1;
                    final current = i == _currentSet - 1;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: current ? 28 : 16,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: done || current
                            ? LinearGradient(
                                colors: [color, color.withOpacity(0.65)],
                              )
                            : null,
                        color: done || current ? null : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: current
                            ? Border.all(color: Colors.white.withOpacity(0.50), width: 1.5)
                            : null,
                        boxShadow: current || done
                            ? [BoxShadow(color: color.withOpacity(0.55), blurRadius: 8, spreadRadius: 1)]
                            : null,
                      ),
                      child: done
                          ? const Icon(Icons.check, size: 10, color: Colors.white)
                          : null,
                    );
                  }),
                ),
              ],

              // Badge de repeticiones — gradiente vibrantPink → cosmicRed
              if (reps.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [EvaColors.vibrantPink, EvaColors.cosmicRed],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: EvaColors.cosmicRed.withOpacity(0.40),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    reps,
                    style: GoogleFonts.raleway(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _trainerMessage(Exercise exercise) {
    final s = AppStrings.of(context);
    if (_isSetResting) return s.trainerSetRest;
    if (_isResting)    return s.trainerExRest;
    final total = exercise.sets.clamp(1, 99);
    if (_currentSet == 1)                 return s.trainerSet1;
    if (_currentSet == total)             return s.trainerLastSet;
    if (_currentSet == 2 && total >= 3)   return s.trainerSet2of3;
    return s.trainerGeneric;
  }

  // ─── Indicador de descanso entre series ───────────────────────────────────────

  Widget _buildSetRestIndicator(Exercise exercise) {
    final color = _getPhaseColor();
    final nextSet = _currentSet + 1;
    final total = exercise.sets.clamp(1, 99);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.20),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de descanso mas femenino — sparkles
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.55), EvaColors.magentaDark.withOpacity(0.55)],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.45), blurRadius: 18, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.auto_awesome_rounded, size: 34, color: Colors.white),
              ),
              const SizedBox(height: 16),
              // Texto de serie completada con badge dorado
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¡Serie $_currentSet completada! ',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '✦',
                    style: TextStyle(
                      fontSize: 18,
                      color: EvaColors.vitalityYellow,
                      shadows: [Shadow(color: EvaColors.vitalityYellow.withOpacity(0.7), blurRadius: 8)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Frase motivacional
              Text(
                _trainerMessage(exercise),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 13,
                  color: EvaColors.vitalityYellow.withOpacity(0.85),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Proxima serie info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                ),
                child: Text(
                  'Preparate para la serie $nextSet de $total',
                  style: GoogleFonts.raleway(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if ((exercise.repetitions ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  exercise.repetitions ?? '',
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.60),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Instrucciones ───────────────────────────────────────────────────────────

  Widget _buildInstructions(Exercise exercise) {
    final lang = AppStrings.of(context).languageCode;
    final steps = ExerciseInstructionsService.getInstructions(
      exercise.exerciseId,
      exerciseType: exercise.type,
      lang: lang,
    );
    final color = _getPhaseColor();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, EvaColors.magentaDark]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.45), blurRadius: 8, spreadRadius: 1),
                      ],
                    ),
                    child: const Icon(Icons.format_list_numbered_rounded, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.of(context).howToDo,
                    style: GoogleFonts.raleway(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.92),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...steps.asMap().entries.map((entry) {
                final i = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 1, right: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, EvaColors.cosmicRed],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.45),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
                          style: GoogleFonts.raleway(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.82),
                            height: 1.50,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Temporizador + pausa COMBINADOS ─────────────────────────────────────────

  Widget _buildTimerButton() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';
    final color = (_isResting || _isSetResting) ? EvaColors.strongBlue : _getPhaseColor();

    return GestureDetector(
      onTap: _togglePause,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRunning ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anillo decorativo exterior semitransparente
            SizedBox(
              width: 190,
              height: 190,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 3,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Anillo de progreso principal
            SizedBox(
              width: 175,
              height: 175,
              child: CircularProgressIndicator(
                value: _timerProgress,
                strokeWidth: 11,
                backgroundColor: color.withOpacity(0.18),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            // Circulo interior con gradient y glow
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    EvaColors.magentaDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.55),
                    blurRadius: 28,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timeStr,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.30), blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Icon(
                    _isPaused
                        ? Icons.play_arrow_rounded
                        : (_isSetResting || _isResting)
                            ? Icons.hourglass_bottom_rounded
                            : Icons.pause_rounded,
                    color: Colors.white.withOpacity(0.85),
                    size: 26,
                  ),
                  Text(
                    _isPaused
                        ? AppStrings.of(context).tapToResume
                        : _isSetResting
                            ? AppStrings.of(context).resting
                            : _isResting
                                ? AppStrings.of(context).rest
                                : AppStrings.of(context).tapToPause,
                    style: GoogleFonts.raleway(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Botón de saltar ejercicio (abajo) ────────────────────────────────────────

  Widget _buildBottomSkipButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: GestureDetector(
        onTap: _nextExercise,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.14),
                    _getPhaseColor().withOpacity(0.18),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _getPhaseColor().withOpacity(0.45),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.of(context).nextExercise,
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── GIF display ─────────────────────────────────────────────────────────────

  Widget _buildGifDisplay(String gifUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getPhaseColor().withOpacity(0.45),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getPhaseColor().withOpacity(0.30),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
          color: Colors.black.withOpacity(0.35),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: gifUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: _getPhaseColor(),
              strokeWidth: 2.5,
            ),
          ),
          errorWidget: (context, url, error) => _buildPulsingIcon(),
        ),
      ),
    );
  }

  Widget _buildPulsingIcon() {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getPhaseColor().withOpacity(0.15),
            EvaColors.magentaDark.withOpacity(0.20),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getPhaseColor().withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.fitness_center_rounded,
        size: 72,
        color: _getPhaseColor().withOpacity(0.60),
        shadows: [Shadow(color: _getPhaseColor().withOpacity(0.5), blurRadius: 16)],
      ),
    );
  }

  Widget _buildRestIndicator() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                EvaColors.strongBlue.withOpacity(0.30),
                EvaColors.wellnessPurple.withOpacity(0.30),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: EvaColors.strongBlue.withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [EvaColors.strongBlue, EvaColors.wellnessPurple],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: EvaColors.strongBlue.withOpacity(0.50),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.self_improvement_rounded,
                    size: 38, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'RECUPERATE',
                style: GoogleFonts.raleway(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.80),
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'El siguiente ejercicio viene pronto',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 13,
                  color: EvaColors.vitalityYellow.withOpacity(0.80),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Pantalla de celebración ──────────────────────────────────────────────────

  Widget _buildCelebrationScreen() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF9C27B0),
              Color(0xFFE91E63),
              Color(0xFFFF69B4),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _trophyScale,
                child: FadeTransition(
                  opacity: _trophyOpacity,
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 120,
                    color: Color(0xFFFFD700),
                    shadows: [Shadow(color: Colors.orange, blurRadius: 40)],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _trophyOpacity,
                child: Text(
                  AppStrings.of(context).youDidIt,
                  style: GoogleFonts.cormorantGaramond(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _trophyOpacity,
                child: Text(
                  AppStrings.of(context).minutesCompleted(widget.routine.duration),
                  style: GoogleFonts.raleway(
                    color: Colors.white70,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      AppStrings.of(context).dailyGoal,
                      style: GoogleFonts.raleway(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FAProgressBar(
                      currentValue: 100,
                      displayText: '%',
                      size: 22,
                      animatedDuration: const Duration(milliseconds: 1500),
                      progressColor: const Color(0xFFFFD700),
                      backgroundColor: Colors.white24,
                      displayTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 56),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _restartRoutine,
                        icon: const Icon(Icons.replay, color: Colors.white),
                        label: Text(
                          AppStrings.of(context).repeat,
                          style: GoogleFonts.raleway(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          AppStrings.of(context).finish,
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.purple[900],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Video dialog ─────────────────────────────────────────────────────────────

  // Gradiente de 2 colores segun la fase actual (para fondos y dialogos)
  List<Color> _getPhaseGradientColors() {
    switch (_currentPhase) {
      case 'calentamiento':
        return [EvaColors.motivationOrange, EvaColors.magentaDark];
      case 'principal':
        return [EvaColors.vibrantPink, EvaColors.wellnessPurple];
      case 'enfriamiento':
        return [EvaColors.strongBlue, const Color(0xFF0A0A2A)];
      default:
        return [EvaColors.balanceGray, EvaColors.magentaDark];
    }
  }

  // Confirmacion antes de salir de la rutina en ejecucion
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          AppStrings.of(context).exitRoutineTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppStrings.of(context).exitRoutineBody,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.of(ctx).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(AppStrings.of(ctx).exit),
          ),
        ],
      ),
    );
  }

  void _showVideoDialog(String videoUrl) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            AppStrings.of(context).demonstration,
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: RoutineVideoPlayer(videoUrl: videoUrl),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.of(ctx).close)),
          ],
        ),
      );
    }

  // _getBackgroundColor ya no se usa directamente (reemplazado por Stack + gradiente)
  // pero se conserva para no romper referencias externas si las hubiera.
  Color _getBackgroundColor() {
    switch (_currentPhase) {
      case 'calentamiento': return EvaColors.magentaDark;
      case 'principal':     return EvaColors.wellnessPurple;
      case 'enfriamiento':  return const Color(0xFF0A0A2A);
      default:              return EvaColors.magentaDark;
    }
  }

  String _getPhaseDisplayName() =>
      AppStrings.of(context).phaseDisplayName(_currentPhase);

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case 'calentamiento': return EvaColors.motivationOrange;
      case 'principal':     return EvaColors.vibrantPink;
      case 'enfriamiento':  return EvaColors.strongBlue;
      default:              return EvaColors.balanceGray;
    }
  }

  IconData _getPhaseIcon() {
    switch (_currentPhase) {
      case 'calentamiento': return Icons.local_fire_department_rounded;
      case 'principal':     return Icons.fitness_center_rounded;
      case 'enfriamiento':  return Icons.self_improvement_rounded;
      default:              return Icons.sports_gymnastics;
    }
  }
}
