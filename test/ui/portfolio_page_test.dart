import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/ui/content_panel.dart';
import 'package:portfolio/ui/identity_panel.dart';
import 'package:portfolio/ui/matrix_background.dart';

import '../support/fixtures.dart';

void main() {
  setUpAll(() async {
    sampleContent = await loadSampleContent();
  });

  testWidgets('desktop shows two panes side by side', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    expect(find.byType(IdentityPanel), findsOneWidget);
    expect(find.byType(ContentPanel), findsOneWidget);

    final id = tester.getTopLeft(find.byType(IdentityPanel));
    final cp = tester.getTopLeft(find.byType(ContentPanel));
    expect(id.dx, lessThan(cp.dx));
    expect(id.dy, closeTo(cp.dy, 1));
  });

  testWidgets('phone stacks identity above content', (tester) async {
    await pumpAt(tester, const Size(390, 844));
    final id = tester.getTopLeft(find.byType(IdentityPanel));
    final cp = tester.getTopLeft(find.byType(ContentPanel));
    expect(id.dy, lessThan(cp.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('320px phone with long content scrolls without overflow', (tester) async {
    await pumpAt(tester, const Size(320, 640));
    await tester.ensureVisible(find.text('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop content scrolls in the right pane only', (tester) async {
    await pumpAt(tester, const Size(1280, 500));
    final before = tester.getTopLeft(find.byType(IdentityPanel));
    await tester.drag(find.byType(ContentPanel), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(IdentityPanel)), before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('matrix sits behind the page content', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    expect(find.byType(MatrixBackground), findsOneWidget);
    expect(find.text('Barend Blom'), findsOneWidget);
  });

  testWidgets('narrow desktop still fits without overflow', (tester) async {
    await pumpAt(tester, const Size(901, 700));
    expect(tester.takeException(), isNull);
  });
}
