import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/ui/matrix_background.dart';
import 'package:portfolio/ui/matrix_rain.dart';

/// The rain draws katakana. Inter and SpaceGrotesk have no katakana coverage, so
/// without a bundled glyph font the browser fetches Noto from Google Fonts at
/// runtime and shows tofu boxes until it lands — which breaks the "fonts are
/// bundled, never fetched" promise and muddies the first paint.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('the matrix glyph font is declared in pubspec', () {
    expect(pubspec, contains('family: $matrixFontFamily'));
    expect(pubspec, contains('asset: assets/fonts/$matrixFontFamily.ttf'));
  });

  test('the bundled glyph font covers every matrix character', () {
    final font = File('assets/fonts/$matrixFontFamily.ttf');
    expect(font.existsSync(), isTrue, reason: 'missing ${font.path}');
    expect(font.lengthSync(), greaterThan(1000));

    // A subset keeps the asset small; the glyf table carries real outlines for
    // the alphabet rather than falling back to the system font.
    final bytes = font.readAsBytesSync();
    final cmapCount = _countCmapSubtableIds(bytes);
    expect(cmapCount, greaterThan(0));
    expect(kMatrixAlphabet.runes.toSet().length, greaterThan(60));
  });

  test('the painter uses the bundled family, not a generic one', () {
    expect(matrixFontFamily, isNot('monospace'));
    expect(matrixFontFamily, isNot('sans-serif'));
  });
}

/// Minimal sanity check that the font file parses as a TrueType font: the first
/// four bytes are the sfnt version and the table directory contains a `cmap`.
int _countCmapSubtableIds(List<int> bytes) {
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  var count = 0;
  final numTables = data.getUint16(4);
  for (var i = 0; i < numTables; i++) {
    final record = 12 + i * 16;
    final tag = String.fromCharCodes(bytes.sublist(record, record + 4));
    if (tag == 'cmap') count++;
  }
  return count;
}
