import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/ui/content_panel.dart';

import '../support/fixtures.dart';

Widget panel({List<String>? tabs}) => ContentPanel(
      skills: sampleSkills,
      history: sampleHistory,
      about: sampleAbout,
      tabs: tabs ?? sampleProfile.tabs,
      theme: sampleTheme,
    );

void main() {
  setUpAll(() async {
    sampleContent = await loadSampleContent();
  });

  testWidgets('opens on the first tab and shows only skills', (tester) async {
    await tester.pumpWidget(wrap(panel()));
    expect(find.text('Frontend'), findsOneWidget);
    expect(find.text('BelgiumCampus iTversity — Software Engineering'), findsNothing);
    expect(find.textContaining('Specialised in full-stack'), findsOneWidget);
  });

  testWidgets('tapping History swaps content and hides skills', (tester) async {
    await tester.pumpWidget(wrap(panel()));
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('BelgiumCampus iTversity — Software Engineering'), findsOneWidget);
    expect(find.text('Frontend'), findsNothing);
    expect(find.text('Education'), findsOneWidget);
    expect(find.text('Work Experience'), findsOneWidget);
  });

  testWidgets('tapping About shows the intro and groups', (tester) async {
    await tester.pumpWidget(wrap(panel()));
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Creative problem-solver'), findsOneWidget);
    expect(find.text('Personal Interests'), findsOneWidget);
    expect(find.text('Values'), findsOneWidget);
    expect(find.text('Currently Learning'), findsOneWidget);
  });

  testWidgets('tab labels come from data, not code', (tester) async {
    await tester.pumpWidget(wrap(panel(tabs: const ['One', 'Two', 'Three'])));
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Skills'), findsNothing);
  });

  testWidgets('arrow keys move between tabs', (tester) async {
    await tester.pumpWidget(wrap(panel()));
    await tester.pumpAndSettle();

    // Focus a tab first: the row must not grab focus on load, or it would
    // swallow the arrow keys from page scrolling.
    await tester.tap(find.text('Skills'));
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('BelgiumCampus iTversity — Software Engineering'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Personal Interests'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('BelgiumCampus iTversity — Software Engineering'), findsOneWidget);
  });

  testWidgets('entries with empty meta and description render title only', (tester) async {
    await tester.pumpWidget(wrap(panel()));
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('Contributed to projects on GitHub'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text(''), findsNothing);
  });

  testWidgets('long content scrolls without overflow on a narrow panel', (tester) async {
    await tester.pumpWidget(wrap(panel(), size: const Size(320, 600)));
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('switching tabs starts the new tab at the top', (tester) async {
    await tester.pumpWidget(wrap(panel(), size: const Size(600, 400)));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels,
      greaterThan(0),
    );

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(
      tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels,
      0,
    );
  });

  testWidgets('the tab row does not take focus on load', (tester) async {
    await tester.pumpWidget(wrap(panel()));
    await tester.pumpAndSettle();

    // Nothing is focused yet, so the arrow key belongs to the page, not the tabs.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Frontend'), findsOneWidget);
    expect(find.text('BelgiumCampus iTversity — Software Engineering'), findsNothing);
  });

}
