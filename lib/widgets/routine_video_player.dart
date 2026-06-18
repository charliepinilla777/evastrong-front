import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../services/routine_service.dart';
import '../theme/eva_colors.dart';

/// Reproductor de video de rutina con subtítulos accesibles sincronizados.
/// OPTIMIZADO: throttle del listener de subtítulos para evitar 60 setState/seg.
class RoutineVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final List<SubtitleEntry> subtitles;

  const RoutineVideoPlayer({
    super.key,
    this.videoUrl,
    this.subtitles = const [],
  });

  @override
  State<RoutineVideoPlayer> createState() => _RoutineVideoPlayerState();
}

class _RoutineVideoPlayerState extends State<RoutineVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _initialized = false;
  bool _hasError = false;
  bool _subtitlesEnabled = true;
  SubtitleEntry? _currentSubtitle;

  // FIX: throttle — solo revisamos subtítulos cada 250ms, no en cada frame
  DateTime _lastSubtitleCheck = DateTime(0);
  static const _subtitleThrottle = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    final url = widget.videoUrl;
    if (url != null && url.isNotEmpty) {
      _initializePlayer(url);
    }
  }

  Future<void> _initializePlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: EvaColors.vibrantPink),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: EvaColors.vibrantPink,
          handleColor: EvaColors.cosmicRed,
          bufferedColor: EvaColors.lightPink.withOpacity(0.5),
          backgroundColor: Colors.white24,
        ),
      );

      if (widget.subtitles.isNotEmpty) {
        _videoController!.addListener(_syncSubtitle);
      }

      if (mounted) setState(() => _initialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _syncSubtitle() {
    if (_videoController == null) return;

    // FIX: throttle — ignoramos llamadas más frecuentes que cada 250ms
    final now = DateTime.now();
    if (now.difference(_lastSubtitleCheck) < _subtitleThrottle) return;
    _lastSubtitleCheck = now;

    final pos = _videoController!.value.position;
    SubtitleEntry? found;
    for (final sub in widget.subtitles) {
      if (pos >= sub.start && pos <= sub.end) {
        found = sub;
        break;
      }
    }

    // FIX: solo llamamos setState si el subtítulo realmente cambió
    if (found != _currentSubtitle) {
      setState(() => _currentSubtitle = found);
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_syncSubtitle);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVideoBox(),
        const SizedBox(height: 10),
        _buildSubtitlePanel(),
      ],
    );
  }

  Widget _buildVideoBox() {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.videocam_off_outlined,
        message: 'Esta rutina no tiene video asignado.',
      );
    }
    if (_hasError) {
      return _buildPlaceholder(
        icon: Icons.error_outline,
        message: 'No se pudo cargar el video.',
      );
    }
    if (!_initialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: EvaColors.vibrantPink),
        ),
      );
    }
    if (_videoController == null || _chewieController == null) {
      return _buildPlaceholder(
        icon: Icons.error_outline,
        message: 'No se pudo cargar el video.',
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  Widget _buildPlaceholder({required IconData icon, required String message}) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white30, size: 52),
          const SizedBox(height: 10),
          Text(
            message,
            style: GoogleFonts.raleway(fontSize: 13, color: Colors.white38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitlePanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.closed_caption_outlined,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Subtítulos',
                  style: GoogleFonts.raleway(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                _buildToggle(),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _subtitlesEnabled
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(14),
              child: _buildSubtitleContent(),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Text(
                'Subtítulos desactivados',
                style:
                    GoogleFonts.raleway(fontSize: 12, color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return GestureDetector(
      onTap: () =>
          setState(() => _subtitlesEnabled = !_subtitlesEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _subtitlesEnabled
              ? EvaColors.vibrantPink.withOpacity(0.25)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _subtitlesEnabled
                ? EvaColors.vibrantPink.withOpacity(0.6)
                : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _subtitlesEnabled
                  ? Icons.visibility
                  : Icons.visibility_off_outlined,
              size: 13,
              color: _subtitlesEnabled
                  ? EvaColors.vibrantPink
                  : Colors.white38,
            ),
            const SizedBox(width: 5),
            Text(
              _subtitlesEnabled ? 'Activados' : 'Desactivados',
              style: GoogleFonts.raleway(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _subtitlesEnabled
                    ? EvaColors.vibrantPink
                    : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitleContent() {
    if (widget.subtitles.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white30, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No hay subtítulos disponibles para esta rutina.',
              style: GoogleFonts.raleway(
                  fontSize: 13, color: Colors.white38, height: 1.5),
            ),
          ),
        ],
      );
    }

    final text = _currentSubtitle?.text ?? '';
    if (text.isEmpty) {
      return Center(
        child: Text(
          '— — —',
          style: GoogleFonts.raleway(
              fontSize: 13, color: Colors.white30, letterSpacing: 2),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: EvaColors.vibrantPink.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.raleway(
          fontSize: 15,
          color: Colors.white,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
