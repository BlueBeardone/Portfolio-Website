import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/data/json_read.dart';

void main() {
  group('readString', () {
    test('reports file and path for a missing required string', () {
      expect(
        () => readString({'name': 1}, 'name', file: 'profile.json', path: 'profile'),
        throwsA(isA<DataException>()
            .having((e) => e.file, 'file', 'profile.json')
            .having((e) => e.path, 'path', 'profile.name')
            .having((e) => e.message, 'message', contains('string'))),
      );
    });

    test('throws for a missing key', () {
      expect(
        () => readString({}, 'name', file: 'p.json'),
        throwsA(isA<DataException>()
            .having((e) => e.path, 'path', 'name')
            .having((e) => e.message, 'message', contains('missing'))),
      );
    });

    test('returns the value when the types match', () {
      expect(readString({'name': 'Barend'}, 'name', file: 'p.json'), 'Barend');
    });
  });

  group('readMap', () {
    test('reports indexed path for a bad list item', () {
      final json = {'links': <Object?>[1]};
      final list = readList(json, 'links', file: 'p.json');
      expect(
        () => readMap(list.first, '', file: 'p.json', path: 'p.links[0]'),
        throwsA(isA<DataException>().having((e) => e.path, 'path', 'p.links[0]')),
      );
    });

    test('throws when the value is not a map', () {
      expect(
        () => readMap('nope', 'contact', file: 'p.json'),
        throwsA(isA<DataException>()
            .having((e) => e.path, 'path', 'contact')
            .having((e) => e.message, 'message', contains('object'))),
      );
    });
  });

  group('readOptionalString', () {
    test('returns empty string when absent', () {
      expect(readOptionalString({'a': 'x'}, 'missing', file: 'p.json'), '');
    });

    test('returns the value when present', () {
      expect(readOptionalString({'a': 'x'}, 'a', file: 'p.json'), 'x');
    });
  });

  group('readOptionalList', () {
    test('returns an empty list when absent', () {
      expect(readOptionalList({'a': 'x'}, 'children', file: 'p.json'), isEmpty);
    });

    test('rejects a non-list value', () {
      expect(
        () => readOptionalList({'children': 'nope'}, 'children', file: 'p.json'),
        throwsA(isA<DataException>()
            .having((e) => e.path, 'path', 'children')
            .having((e) => e.message, 'message', contains('list'))),
      );
    });
  });

  group('readStringList', () {
    test('rejects a non-string member', () {
      expect(
        () => readStringList({'tabs': <Object?>['a', 2]}, 'tabs', file: 'p.json'),
        throwsA(isA<DataException>().having((e) => e.path, 'path', 'tabs[1]')),
      );
    });

    test('returns strings in order', () {
      expect(
        readStringList({'tabs': <Object?>['Skills', 'History']}, 'tabs', file: 'p.json'),
        ['Skills', 'History'],
      );
    });
  });
}
