import 'dart:math';

import '../models/site_theme.dart';

/// Katakana + digits + A–Z, same alphabet as the old site's matrix.js.
const String kMatrixAlphabet =
    '01アァカサタナハマヤャラワガザダバパイィキシチニヒミリヰギジヂビピウゥクスツヌフムユュルグズブヅプエェケセテネヘメレヱゲゼデベペオォコソトノホモヨョロヲゴゾドボポヴッン'
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

class MatrixGlyph {
  const MatrixGlyph({
    required this.column,
    required this.y,
    required this.char,
    required this.layer,
    required this.fontSize,
  });

  final int column;
  final double y;
  final String char;
  final int layer;
  final double fontSize;
}

class _Column {
  _Column({
    required this.speed,
    required this.fontSize,
    required this.layer,
    required this.y,
    required this.trail,
  });

  double y;
  final double speed;
  final double fontSize;
  final int layer;

  /// Newest first.
  final List<MatrixGlyph> trail;
}

/// The simulation behind the rain. Pure Dart, no widgets, so it can be tested
/// without a render surface.
class MatrixRain {
  MatrixRain({
    required double width,
    required double height,
    required this.config,
    int? seed,
  }) : _random = Random(seed) {
    _build(width, height);
  }

  final MatrixConfig config;
  final Random _random;

  final List<_Column> _columns = [];
  double _height = 0;

  static const List<double> _layerOpacities = [0.08, 0.15, 0.21, 0.28];

  List<MatrixGlyph> get glyphs => [
        for (var i = 0; i < _columns.length; i++)
          if (_columns[i].trail.isNotEmpty)
            MatrixGlyph(
              column: i,
              y: _columns[i].y,
              char: _columns[i].trail.first.char,
              layer: _columns[i].layer,
              fontSize: _columns[i].fontSize,
            ),
      ];

  List<MatrixGlyph> trailFor(int column) {
    if (column < 0 || column >= _columns.length) return const [];
    return List.unmodifiable(_columns[column].trail);
  }

  double layerOpacity(int layer) {
    if (!config.enabled) return 0;
    final base = _layerOpacities[layer.clamp(0, 3)];
    return min(base * config.opacity, config.maxLayerOpacity);
  }

  void resize(double width, double height) => _build(width, height);

  void advance(double dtSeconds) {
    if (!config.enabled) return;
    for (var index = 0; index < _columns.length; index++) {
      final column = _columns[index];
      column.y += column.speed * dtSeconds * 60 / config.fontSize;
      if (column.y * config.fontSize > _height * 1.5) {
        _reset(column, aboveTop: true);
      }
      column.trail.insert(
        0,
        MatrixGlyph(
          column: index,
          y: column.y,
          char: _randomChar(),
          layer: column.layer,
          fontSize: column.fontSize,
        ),
      );
      if (column.trail.length > config.trailLength) {
        column.trail.removeRange(config.trailLength, column.trail.length);
      }
    }
  }

  void _build(double width, double height) {
    _height = height;
    _columns.clear();
    if (!config.enabled) return;
    final count = (width / config.fontSize).ceil();
    for (var i = 0; i < count; i++) {
      final column = _Column(
        speed: (0.5 + _random.nextDouble() * 1.5) * config.speed,
        fontSize: config.fontSize + _random.nextDouble() * 8,
        layer: _random.nextInt(4),
        y: -_random.nextDouble() * height / config.fontSize,
        trail: [],
      );
      column.trail.add(
        MatrixGlyph(
          column: i,
          y: column.y,
          char: _randomChar(),
          layer: column.layer,
          fontSize: column.fontSize,
        ),
      );
      _columns.add(column);
    }
  }

  void _reset(_Column column, {required bool aboveTop}) {
    column.y = aboveTop ? -_random.nextDouble() * 20 - 1 : column.y;
    column.trail.clear();
  }

  String _randomChar() =>
      kMatrixAlphabet[_random.nextInt(kMatrixAlphabet.length)];
}
