import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_strings.dart';
import '../services/exercise_gif_service.dart';
import '../services/exercise_instructions_service.dart';
import '../services/history_service.dart';
import '../services/routine_recommendation_service.dart';
import '../services/voice_coach_service.dart';

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _getPhaseColor(),
          ),
        ),
        content: Text(message, style: GoogleFonts.raleway(fontSize: 15)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPhaseColor(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(startLabel ?? AppStrings.of(context).begin),
          ),
        ],
      ),
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

  /// Devuelve el color del segmento según la fase del ejercicio.
  Color _phaseSegmentColor(String phase) {
    switch (phase) {
      case 'calentamiento': return Colors.orange;
      case 'principal':     return Colors.purple;
      case 'enfriamiento':  return Colors.blue;
      default:              return Colors.grey;
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
            _legendDot(Colors.orange, AppStrings.of(context).phaseWarmupLegend),
            const SizedBox(width: 10),
            _legendDot(Colors.purple, AppStrings.of(context).phaseMainLegend),
            const SizedBox(width: 10),
            _legendDot(Colors.blue, AppStrings.of(context).phaseCooldownLegend),
            const Spacer(),
            Text(
              AppStrings.of(context).intervalLabel(currentIdx + 1, _allSegments.length),
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Barra de segmentos
        SizedBox(
          height: 20,
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
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Fondo vacío
                        Container(color: Colors.grey[200]),
                        // Relleno animado
                        if (fill > 0)
                          AnimatedFractionallySizedBox(
                            widthFactor: fill,
                            heightFactor: 1.0,
                            alignment: Alignment.centerLeft,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            child: Container(color: color),
                          ),
                        // Icono check cuando completo
                        if (isDone)
                          Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 12,
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
                              borderRadius: BorderRadius.circular(4),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) return _buildCelebrationScreen();

    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          widget.routine.name,
          style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _getPhaseColor(),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón mute/unmute de voz
          StatefulBuilder(
            builder: (context, setIconState) => IconButton(
              icon: Icon(
                _voice.isMuted
                    ? Icons.volume_off_rounded
                    : Icons.volume_up_rounded,
              ),
              tooltip: _voice.isMuted
                  ? AppStrings.of(context).enableVoice
                  : AppStrings.of(context).muteVoice,
              onPressed: () {
                setIconState(() => _voice.toggleMute());
                if (_voice.isMuted) _voice.stop();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitConfirmation,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(child: _buildMainContent()),
            _buildBottomSkipButton(),
          ],
        ),
      ),
    );
  }

  // ─── Progress header ─────────────────────────────────────────────────────────

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fase actual + ciclo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: _getPhaseColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    _getPhaseDisplayName(),
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getPhaseColor(),
                    ),
                  ),
                ],
              ),
              if (_currentPhase == 'principal')
                Text(
                  AppStrings.of(context).cycleLabel(_currentCycle, widget.routine.mainCycles),
                  style: GoogleFonts.raleway(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Barra de intervalos ─────────────────────────────────────────────
          _buildIntervalBar(),

          const SizedBox(height: 10),

          // Meta diaria + tiempo
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 15),
              const SizedBox(width: 3),
              Text(
                AppStrings.of(context).goalLabel(widget.routine.duration),
                style: GoogleFonts.raleway(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const Spacer(),
              Text(
                '${(_completedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_completedSeconds % 60).toString().padLeft(2, '0')} / ${widget.routine.duration}:00',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FAProgressBar(
            currentValue: _progressPercent,
            displayText: '%',
            size: 18,
            animatedDuration: const Duration(milliseconds: 500),
            progressColor: _getPhaseColor(),
            backgroundColor: Colors.grey[200]!,
            displayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(9)),
          ),
        ],
      ),
    );
  }

  // ─── Main content ─────────────────────────────────────────────────────────────

  Widget _buildMainContent() {
    final exercise = _currentExercise;
    if (exercise == null) {
      return Center(child: Text(AppStrings.of(context).noExercises));
    }

    final gifUrl = ExerciseGifService.getGifUrl(
      exercise.exerciseId,
      exerciseType: exercise.type,
    );
    final hasVideo = ExerciseGifService.hasVideo(exercise.videoUrl);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // ── GIF / Descanso ───────────────────────────────────────────────
          if (_isResting)
            _buildRestIndicator()
          else if (_isSetResting)
            _buildSetRestIndicator(exercise)
          else if (gifUrl != null)
            _buildGifDisplay(gifUrl)
          else
            _buildPulsingIcon(),

          const SizedBox(height: 14),

          // ── Nombre del ejercicio ─────────────────────────────────────────
          Text(
            AppStrings.of(context).languageCode == 'en'
                ? ExerciseInstructionsService.translateName(exercise.name)
                : exercise.name,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.of(context).languageCode == 'en'
                ? ExerciseInstructionsService.translateShortDesc(exercise.shortDescription)
                : exercise.shortDescription,
            style: GoogleFonts.raleway(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          // Zona muscular
          if (exercise.zone.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getPhaseColor().withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppStrings.of(context).exerciseZone(exercise.zone).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _getPhaseColor(),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Indicador de series (corazón de la feature) ──────────────────
          if (!_isResting)
            _buildSetIndicator(exercise),

          const SizedBox(height: 14),

          // ── Instrucciones paso a paso (solo en serie activa) ─────────────
          if (!_isResting && !_isSetResting)
            _buildInstructions(exercise),

          const SizedBox(height: 18),

          // ── Temporizador + botón combinados ──────────────────────────────
          _buildTimerButton(),

          if (_isResting) ...[
            const SizedBox(height: 12),
            Text(
              'DESCANSA — próximo ejercicio',
              style: GoogleFonts.raleway(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
                letterSpacing: 1.5,
              ),
            ),
          ],

          // Botón video
          if (hasVideo && !_isSetResting && !_isResting) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _showVideoDialog(exercise.videoUrl!),
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: Text(AppStrings.of(context).viewDemo),
              style: OutlinedButton.styleFrom(
                foregroundColor: _getPhaseColor(),
                side: BorderSide(color: _getPhaseColor(), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ─── Indicador de series — el "corazón" de la experiencia de entrenador ──────

  Widget _buildSetIndicator(Exercise exercise) {
    final color = _getPhaseColor();
    final totalSets = exercise.sets.clamp(1, 99);
    final reps = exercise.repetitions ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.08), color.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        children: [
          // Frase del entrenador
          Text(
            _trainerMessage(exercise),
            style: GoogleFonts.raleway(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Serie actual grande
          if (!_isSetResting) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${AppStrings.of(context).series} ',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[600],
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '$_currentSet',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1,
                  ),
                ),
                Text(
                  ' / $totalSets',
                  style: GoogleFonts.raleway(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),

            // Puntos de progreso de series
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalSets, (i) {
                final done = i < _currentSet - 1;
                final current = i == _currentSet - 1;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: current ? 24 : 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: done
                        ? color
                        : current
                            ? color.withOpacity(0.7)
                            : color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(7),
                    border: current
                        ? Border.all(color: color, width: 2)
                        : null,
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 9, color: Colors.white)
                      : null,
                );
              }),
            ),
          ],

          // Repeticiones
          if (reps.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
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

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pause_circle_outline_rounded,
              size: 48, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(
            '¡Serie $_currentSet completada!',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Preparate para la serie $nextSet de $total',
            style: GoogleFonts.raleway(
              fontSize: 13,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            exercise.repetitions ?? '',
            style: GoogleFonts.raleway(
              fontSize: 12,
              color: Colors.blue[500],
            ),
          ),
        ],
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_list_numbered_rounded, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                AppStrings.of(context).howToDo,
                style: GoogleFonts.raleway(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 1, right: 10),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
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
                        color: Colors.grey[800],
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Temporizador + pausa COMBINADOS ─────────────────────────────────────────

  Widget _buildTimerButton() {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    final timeStr = '$minutes:${seconds.toString().padLeft(2, '0')}';
    final color = (_isResting || _isSetResting) ? Colors.blue : _getPhaseColor();

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
            // Anillo de progreso exterior
            SizedBox(
              width: 170,
              height: 170,
              child: CircularProgressIndicator(
                value: _timerProgress,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            // Círculo interior con sombra
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timeStr,
                    style: GoogleFonts.raleway(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    _isPaused
                        ? Icons.play_arrow_rounded
                        : (_isSetResting || _isResting)
                            ? Icons.hourglass_bottom_rounded
                            : Icons.pause_rounded,
                    color: Colors.white.withOpacity(0.9),
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
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _nextExercise,
          icon: const Icon(Icons.skip_next_rounded),
          label: Text(AppStrings.of(context).nextExercise),
          style: OutlinedButton.styleFrom(
            foregroundColor: _getPhaseColor(),
            side: BorderSide(color: _getPhaseColor(), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: GoogleFonts.raleway(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ─── GIF display ─────────────────────────────────────────────────────────────

  Widget _buildGifDisplay(String gifUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: _getPhaseColor().withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getPhaseColor().withOpacity(0.2), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: gifUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: _getPhaseColor(),
            strokeWidth: 2,
          ),
        ),
        errorWidget: (context, url, error) => _buildPulsingIcon(),
      ),
    );
  }

  Widget _buildPulsingIcon() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: _getPhaseColor().withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getPhaseColor().withOpacity(0.2), width: 1),
      ),
      child: Icon(
        Icons.fitness_center_rounded,
        size: 72,
        color: _getPhaseColor().withOpacity(0.5),
      ),
    );
  }

  Widget _buildRestIndicator() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Icon(
        Icons.self_improvement_rounded,
        size: 80,
        color: Colors.blue[300],
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

  void _showVideoDialog(String videoUrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.of(context).demonstration),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_outline, size: 60, color: Colors.purple),
            const SizedBox(height: 12),
            Text(videoUrl, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.of(ctx).close)),
        ],
      ),
    );
  }

  // ─── Exit confirmation ────────────────────────────────────────────────────────

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.of(context).exitRoutineTitle),
        content: Text(AppStrings.of(context).exitRoutineBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppStrings.of(context).exit, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers de color y fase ──────────────────────────────────────────────────

  Color _getBackgroundColor() {
    switch (_currentPhase) {
      case 'calentamiento': return Colors.orange[50]!;
      case 'principal':     return Colors.purple[50]!;
      case 'enfriamiento':  return Colors.blue[50]!;
      default:              return Colors.grey[50]!;
    }
  }

  String _getPhaseDisplayName() =>
      AppStrings.of(context).phaseDisplayName(_currentPhase);

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case 'calentamiento': return Colors.orange;
      case 'principal':     return Colors.purple;
      case 'enfriamiento':  return Colors.blue;
      default:              return Colors.grey;
    }
  }
}
