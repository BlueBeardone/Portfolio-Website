import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/data/json_read.dart';
import 'package:portfolio/models/site_theme.dart';
import 'package:portfolio/theme/app_theme.dart';

SiteTheme loadTheme() {
  final json = jsonDecode(File('assets/data/theme.json').readAsStringSync())
      as Map<String, dynamic>;
  return SiteTheme.fromJson(json, file: 'theme.json');
}

void main() {
  test('parses 6- and 8-digit hex', () {
    expect(parseHexColor('#4ADE80'), const Color(0xFF4ADE80));
    expect(parseHexColor('#14FFFFFF'), const Color(0x14FFFFFF));
    expect(() => parseHexColor('green'), throwsFormatException);
    expect(() => parseHexColor('#12345'), throwsFormatException);
    expect(() => parseHexColor('#ZZZZZZ'), throwsFormatException);
  });

  test('theme uses the JSON accent and breakpoint', () {
    final theme = loadTheme();
    expect(theme.colors.accent, const Color(0xFF4ADE80));
    expect(theme.layout.breakpoint, 900);
    expect(theme.layout.maxContentWidth, 1200);
    expect(theme.matrix.maxLayerOpacity, 0.28);
    expect(theme.matrix.trailLength, 8);
    expect(theme.type.heroDesktop, 88);
  });

  test('buildThemeData is dark, uses Inter and the JSON accent', () {
    final data = buildThemeData(loadTheme());
    expect(data.colorScheme.brightness, Brightness.dark);
    expect(data.colorScheme.surface, const Color(0xFF07090A));
    expect(data.colorScheme.primary, const Color(0xFF4ADE80));
    expect(data.scaffoldBackgroundColor, const Color(0xFF07090A));
    expect(data.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(data.textTheme.bodyMedium?.fontSize, 15);
    expect(data.textTheme.bodySmall?.fontSize, 12);
    expect(data.textTheme.displayLarge?.fontFamily, 'SpaceGrotesk');
  });

  test('a bad colour value surfaces the field path', () {
    final json = jsonDecode(File('assets/data/theme.json').readAsStringSync())
        as Map<String, dynamic>;
    (json['colors'] as Map<String, dynamic>)['accent'] = 'not-a-colour';
    expect(
      () => SiteTheme.fromJson(json, file: 'theme.json'),
      throwsA(isA<DataException>()
          .having((e) => e.file, 'file', 'theme.json')
          .having((e) => e.path, 'path', 'colors.accent')
          .having((e) => e.message, 'message', contains('colour'))),
    );
  });
}
