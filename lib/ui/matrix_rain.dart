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
    required this.char,
    required this.cell,
    required this.trail,
  });

  double y;
  final double speed;
  final double fontSize;
  final int layer;

  /// The character currently shown at the head. It only changes when the head
  /// moves into the next character cell, so glyphs read as glyphs instead of
  /// flickering into a trail of light.
  String char;

  /// Integer cell the head currently occupies.
  int cell;

  /// Cells already passed, newest first. Each keeps the character it displayed.
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
          MatrixGlyph(
            column: i,
            y: _columns[i].y,
            char: _columns[i].char,
            layer: _columns[i].layer,
            fontSize: _columns[i].fontSize,
          ),
      ];

  /// The cells already passed above [column]'s head, newest first.
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
        _reset(column, index);
        continue;
      }

      final cell = column.y.floor();
      while (column.cell < cell) {
        column.cell++;
        column.trail.insert(
          0,
          MatrixGlyph(
            column: index,
            y: column.cell.toDouble(),
            char: column.char,
            layer: column.layer,
            fontSize: column.fontSize,
          ),
        );
        column.char = _randomChar();
        if (column.trail.length > config.trailLength) {
          column.trail.removeRange(config.trailLength, column.trail.length);
        }
      }
    }
  }

  void _build(double width, double height) {
    _height = height;
    _columns.clear();
    if (!config.enabled) return;
    final count = (width / config.fontSize).ceil();
    for (var i = 0; i < count; i++) {
      final startY = -_random.nextDouble() * height / config.fontSize;
      _columns.add(
        _Column(
          speed: (0.5 + _random.nextDouble() * 1.5) * config.speed,
          fontSize: config.fontSize + _random.nextDouble() * 8,
          layer: _random.nextInt(4),
          y: startY,
          char: _randomChar(),
          cell: startY.floor(),
          trail: [],
        ),
      );
    }
  }

  void _reset(_Column column, int index) {
    final startY = -_random.nextDouble() * 20 - 1;
    column.y = startY;
    column.cell = startY.floor();
    column.char = _randomChar();
    column.trail.clear();
  }

  String _randomChar() =>
      kMatrixAlphabet[_random.nextInt(kMatrixAlphabet.length)];
}
