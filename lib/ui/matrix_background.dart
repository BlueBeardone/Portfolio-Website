import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/site_theme.dart';
import 'matrix_rain.dart';

/// Paints the matrix rain behind [child].
///
/// The rain repaints on its own [Listenable] so the child subtree is never
/// rebuilt by the animation. It stops when the tab is hidden and stays static
/// when the platform asks for reduced motion.
class MatrixBackground extends StatefulWidget {
  const MatrixBackground({super.key, required this.config, required this.child});

  final MatrixConfig config;
  final Widget child;

  @override
  State<MatrixBackground> createState() => _MatrixBackgroundState();
}

class _MatrixBackgroundState extends State<MatrixBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ValueNotifier<int> _frames = ValueNotifier<int>(0);

  Ticker? _ticker;
  MatrixRain? _rain;
  Size _size = Size.zero;
  Duration _lastTick = Duration.zero;
  bool _reduceMotion = false;
  bool _lifecyclePaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      if (_reduceMotion) {
        _stopTicker();
      } else {
        _startTicker();
      }
    } else if (widget.config.enabled && !_reduceMotion && _ticker == null) {
      _startTicker();
    }
  }

  @override
  void didUpdateWidget(covariant MatrixBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.enabled != widget.config.enabled) {
      widget.config.enabled ? _startTicker() : _stopTicker();
      _rain = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final paused = state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive;
    _lifecyclePaused = paused;
    if (paused) {
      _stopTicker();
    } else {
      _startTicker();
    }
  }

  void _startTicker() {
    if (!widget.config.enabled || _reduceMotion || _lifecyclePaused) return;
    if (_ticker != null) return;
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
      _lastTick = elapsed;
      if (dt <= 0) return;
      _rain?.advance(dt);
      _frames.value++;
    })
      ..start();
  }

  void _stopTicker() {
    _ticker?.dispose();
    _ticker = null;
    _lastTick = Duration.zero;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTicker();
    _frames.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size != _size) {
          _size = size;
          _rain = MatrixRain(
            width: size.width.isFinite ? size.width : 0,
            height: size.height.isFinite ? size.height : 0,
            config: widget.config,
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            if (widget.config.enabled && _rain != null)
              RepaintBoundary(
                child: CustomPaint(
                  painter: MatrixRainPainter(
                    rain: _rain!,
                    config: widget.config,
                    repaint: _frames,
                  ),
                ),
              ),
            widget.child,
          ],
        );
      },
    );
  }
}

class MatrixRainPainter extends CustomPainter {
  MatrixRainPainter({
    required this.rain,
    required this.config,
    super.repaint,
  });

  final MatrixRain rain;
  final MatrixConfig config;

  final Map<String, TextPainter> _cache = {};

  TextPainter _textPainter(String char, double fontSize, int bucket, double opacity) {
    final key = '$char|${fontSize.round()}|$bucket';
    return _cache.putIfAbsent(key, () {
      final painter = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: fontSize,
            color: config.color.withValues(alpha: opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return painter;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!config.enabled) return;

    final heads = rain.glyphs;
    for (var column = 0; column < heads.length; column++) {
      final head = heads[column];
      final x = column * config.fontSize;
      final opacity = rain.layerOpacity(head.layer);

      final trail = rain.trailFor(column);
      for (var i = trail.length - 1; i >= 0; i--) {
        final glyph = trail[i];
        final faded = opacity * (1 - (i + 1) / (config.trailLength + 1)) * 0.8;
        if (faded <= 0.002) continue;
        final painter = _textPainter(glyph.char, glyph.fontSize, (faded * 50).round(), faded);
        painter.paint(canvas, Offset(x, glyph.y * config.fontSize));
      }

      final headPainter = _textPainter(head.char, head.fontSize, 1000, opacity);
      headPainter.paint(canvas, Offset(x, head.y * config.fontSize));
    }
  }

  @override
  bool shouldRepaint(covariant MatrixRainPainter oldDelegate) =>
      oldDelegate.rain != rain || oldDelegate.config != config;
}
