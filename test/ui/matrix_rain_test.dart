import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/models/site_theme.dart';
import 'package:portfolio/ui/matrix_background.dart';
import 'package:portfolio/ui/matrix_rain.dart';

const cfg = MatrixConfig(
  enabled: true,
  opacity: 1.0,
  speed: 1.0,
  fontSize: 16,
  color: Color(0xFF4ADE80),
  trailLength: 8,
  maxLayerOpacity: 0.28,
);

void main() {
  test('one column per 16 logical pixels', () {
    final rain = MatrixRain(width: 320, height: 800, config: cfg, seed: 1);
    expect(rain.glyphs, hasLength(20));
  });

  test('advance moves a column down', () {
    final rain = MatrixRain(width: 160, height: 800, config: cfg, seed: 1);
    final before = rain.glyphs.first.y;
    rain.advance(1.0);
    expect(rain.glyphs.first.y, greaterThan(before));
  });

  test('a column that passes 1.5x the height wraps to the top', () {
    final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
    for (var i = 0; i < 200; i++) {
      rain.advance(0.5);
    }
    expect(rain.glyphs.every((g) => g.y < 150), isTrue);
  });

  test('trail never exceeds trailLength and never contains the head cell', () {
    final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
    for (var i = 0; i < 200; i++) {
      rain.advance(0.2);
    }
    expect(rain.trailFor(0).length, lessThanOrEqualTo(cfg.trailLength));
    final head = rain.glyphs.firstWhere((g) => g.column == 0);
    expect(rain.trailFor(0).every((g) => g.y < head.y), isTrue);
  });

  test('a glyph holds its character for as long as it stays in one cell', () {
    final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
    const column = 4;

    MatrixGlyph head() =>
        rain.glyphs.firstWhere((g) => g.column == column);

    var charNow = head().char;
    var cell = head().y.floor();
    var crossings = 0;

    for (var i = 0; i < 200; i++) {
      rain.advance(0.01);
      final next = head();
      final nextCell = next.y.floor();
      if (nextCell != cell) {
        crossings++;
        expect(next.char, isNot(charNow),
            reason: 'a new cell should get a fresh character');
        charNow = next.char;
        cell = nextCell;
      } else {
        expect(next.char, charNow,
            reason: 'a glyph must not flicker while it is in the same cell');
      }
    }

    expect(crossings, greaterThan(4));
  });

  test('trail entries keep their own character', () {
    final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
    for (var i = 0; i < 200; i++) {
      rain.advance(0.2);
    }
    final trail = rain.trailFor(6);
    expect(trail, isNotEmpty);
    expect(trail.map((g) => g.char).toSet().length, greaterThan(1));
  });

  test('trail sits behind the head, brightest first', () {
    final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
    for (var i = 0; i < 10; i++) {
      rain.advance(0.2);
    }
    final trail = rain.trailFor(3);
    expect(trail.length, greaterThan(1));
    for (var i = 1; i < trail.length; i++) {
      expect(trail[i].y, lessThan(trail[i - 1].y));
    }
  });

  test('layer opacity is capped at maxLayerOpacity', () {
    final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
    expect(rain.layerOpacity(3), lessThanOrEqualTo(cfg.maxLayerOpacity));
    expect(rain.layerOpacity(0), lessThan(rain.layerOpacity(3)));
    for (var i = 0; i < 4; i++) {
      expect(rain.layerOpacity(i), greaterThan(0));
    }
  });

  test('resize rebuilds the column count', () {
    final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
    rain.resize(320, 100);
    expect(rain.glyphs, hasLength(20));
  });

  test('a disabled matrix produces no glyphs', () {
    const off = MatrixConfig(
      enabled: false,
      opacity: 1.0,
      speed: 1.0,
      fontSize: 16,
      color: Color(0xFF4ADE80),
      trailLength: 8,
      maxLayerOpacity: 0.28,
    );
    final rain = MatrixRain(width: 320, height: 100, config: off, seed: 1);
    expect(rain.glyphs, isEmpty);
  });

  testWidgets('reduced motion paints without a ticker', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true, size: Size(400, 400)),
        child: MaterialApp(
          home: MatrixBackground(config: cfg, child: SizedBox.expand()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('matrix paints behind its child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MatrixBackground(
          config: cfg,
          child: Center(child: Text('content')),
        ),
      ),
    );
    expect(find.text('content'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
