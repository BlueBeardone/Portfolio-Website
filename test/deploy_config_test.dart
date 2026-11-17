import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Render serves `render.yaml` headers verbatim. The content files and the PDFs
/// are edited in place and redeployed, so they must not be cached as immutable:
/// a year-long immutable cache would strand returning visitors on old content.
List<Map<String, String>> _headerRules(String yaml) {
  final rules = <Map<String, String>>[];
  Map<String, String>? current;
  for (final raw in yaml.split('\n')) {
    final line = raw.trim();
    if (line.startsWith('- path:')) {
      current = {'path': line.substring('- path:'.length).trim()};
      rules.add(current);
    } else if (current != null && line.startsWith('name:')) {
      current['name'] = line.substring('name:'.length).trim();
    } else if (current != null && line.startsWith('value:')) {
      current['value'] = line.substring('value:'.length).trim();
    }
  }
  return rules;
}

void main() {
  final yaml = File('render.yaml').readAsStringSync();
  final rules = _headerRules(yaml);

  test('render.yaml declares cache rules', () {
    expect(rules, isNotEmpty);
    expect(rules.every((r) => r.containsKey('value')), isTrue);
  });

  for (final rule in rules) {
    final path = rule['path'] ?? '';
    if (path.contains('/data/') || path.contains('/pdf/')) {
      test('$path is revalidated, not cached for a year', () {
        final value = rule['value'] ?? '';
        expect(value, isNot(contains('immutable')));
        expect(value, isNot(contains('max-age=31536000')));
        expect(value.toLowerCase(), anyOf(contains('no-cache'), contains('must-revalidate')));
      });
    }
  }

  test('the editable content and PDFs are covered by a cache rule', () {
    final paths = rules.map((r) => r['path'] ?? '').join(' ');
    expect(paths, contains('/data/'));
    expect(paths, contains('/pdf/'));
  });
}
