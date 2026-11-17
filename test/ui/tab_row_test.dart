import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/ui/tab_row.dart';

import '../support/fixtures.dart';

void main() {
  setUpAll(() async {
    sampleContent = await loadSampleContent();
  });

  testWidgets('enter and space re-select the focused tab without crashing', (tester) async {
    final calls = <int>[];
    var selected = 1;
    await tester.pumpWidget(wrap(
      StatefulBuilder(
        builder: (context, setState) => TabRow(
          labels: const ['One', 'Two', 'Three'],
          selected: selected,
          onSelect: (index) {
            calls.add(index);
            setState(() => selected = index);
          },
          accent: Colors.green,
        ),
      ),
    ));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(calls, [1]);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(calls, [1, 1]);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(calls.last, 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(calls.last, 1);

    expect(tester.takeException(), isNull);
  });

  testWidgets('arrow keys stop at the ends instead of wrapping', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(wrap(
      TabRow(
        labels: const ['One', 'Two'],
        selected: 0,
        onSelect: selected.add,
        accent: Colors.green,
      ),
    ));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
  });
}
