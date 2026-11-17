import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/data/json_read.dart';
import 'package:portfolio/models/site_theme.dart';

/// A theme value the app cannot draw with must reach the owner as a data error
/// naming the field, not as an uncaught build error that blanks the page.
Map<String, dynamic> themeJson() =>
    jsonDecode(File('assets/data/theme.json').readAsStringSync())
        as Map<String, dynamic>;

Matcher failsOn(String path) => throwsA(
      isA<DataException>().having((e) => e.path, 'path', path),
    );

void main() {
  test('a zero matrix font size is a data error', () {
    final json = themeJson();
    (json['matrix'] as Map<String, dynamic>)['fontSize'] = 0;
    expect(() => SiteTheme.fromJson(json, file: 'theme.json'), failsOn('matrix.fontSize'));
  });

  test('a zero trail length is a data error', () {
    final json = themeJson();
    (json['matrix'] as Map<String, dynamic>)['trailLength'] = 0;
    expect(() => SiteTheme.fromJson(json, file: 'theme.json'), failsOn('matrix.trailLength'));
  });

  test('an opacity outside 0..1 is a data error', () {
    final json = themeJson();
    (json['matrix'] as Map<String, dynamic>)['opacity'] = 2;
    expect(() => SiteTheme.fromJson(json, file: 'theme.json'), failsOn('matrix.opacity'));
  });

  test('a zero breakpoint is a data error', () {
    final json = themeJson();
    (json['layout'] as Map<String, dynamic>)['breakpoint'] = 0;
    expect(() => SiteTheme.fromJson(json, file: 'theme.json'), failsOn('layout.breakpoint'));
  });

  test('a non-positive hero size is a data error', () {
    final json = themeJson();
    (json['type'] as Map<String, dynamic>)['heroDesktop'] = -4;
    expect(() => SiteTheme.fromJson(json, file: 'theme.json'), failsOn('type.heroDesktop'));
  });

  test('an identity width factor outside 0..1 is a data error', () {
    final json = themeJson();
    (json['layout'] as Map<String, dynamic>)['identityWidthFactor'] = 1.4;
    expect(
      () => SiteTheme.fromJson(json, file: 'theme.json'),
      failsOn('layout.identityWidthFactor'),
    );
  });

  test('the shipped theme still parses', () {
    expect(SiteTheme.fromJson(themeJson(), file: 'theme.json').matrix.fontSize, 16);
  });
}
