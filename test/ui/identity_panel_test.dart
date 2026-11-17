import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/data/launcher.dart';
import 'package:portfolio/models/profile.dart';
import 'package:portfolio/ui/identity_panel.dart';

import '../support/fixtures.dart';

void main() {
  setUpAll(() async {
    sampleContent = await loadSampleContent();
  });

  testWidgets('renders name, role and location from data', (tester) async {
    await tester.pumpWidget(wrap(IdentityPanel(profile: sampleProfile, theme: sampleTheme)));
    expect(find.text('Barend Blom'), findsOneWidget);
    expect(find.textContaining('Software Developer'), findsOneWidget);
    expect(find.textContaining('Gauteng, South Africa'), findsOneWidget);
    expect(find.text('Portfolio / 2026'), findsOneWidget);
  });

  testWidgets('every link row opens its URL in order, email last', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(wrap(
      IdentityPanel(profile: sampleProfile, theme: sampleTheme, onOpenLink: opened.add),
    ));

    expect(find.text('GitHub'), findsOneWidget);
    await tester.tap(find.text('LinkedIn'));
    await tester.tap(find.text('itch.io'));
    await tester.tap(find.text('barend.army@gmail.com'));

    expect(opened, [
      'https://www.linkedin.com/in/barend-blom-980b53265/',
      'https://itch.io/profile/4shblue',
      'mailto:barend.army@gmail.com',
    ]);
  });

  testWidgets('a link with an empty URL taps without crashing', (tester) async {
    final opened = <String>[];
    final broken = profileWith(links: const [LinkItem(label: 'Broken', url: '')]);
    await tester.pumpWidget(wrap(
      IdentityPanel(profile: broken, theme: sampleTheme, onOpenLink: opened.add),
    ));

    await tester.tap(find.text('Broken'));
    expect(opened, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long role text wraps on a 320px phone', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final long = profileWith(
      role: 'Software Developer and full-stack engineer with a very long descriptor',
      location: 'Somewhere with an unusually long place name, South Africa',
    );
    await tester.pumpWidget(wrap(
      IdentityPanel(profile: long, theme: sampleTheme),
      size: const Size(320, 900),
    ));

    expect(tester.takeException(), isNull);
  });

  testWidgets('PDF buttons call back with their asset path', (tester) async {
    final downloaded = <String>[];
    await tester.pumpWidget(wrap(
      IdentityPanel(
        profile: sampleProfile,
        theme: sampleTheme,
        onDownloadPdf: downloaded.add,
      ),
    ));

    await tester.tap(find.text('Download CV'));
    await tester.tap(find.text('Download Grades'));

    expect(downloaded, [
      'assets/pdf/Barend_Blom_CV.pdf',
      'assets/pdf/GR12_Graduation_Marks.pdf',
    ]);
  });

  test('asset URLs resolve against the page base', () {
    expect(
      resolveAssetUrl(Uri.parse('http://x/'), 'assets/pdf/cv.pdf'),
      'http://x/assets/assets/pdf/cv.pdf',
    );
    expect(
      resolveAssetUrl(Uri.parse('http://x/sub/'), 'assets/pdf/cv.pdf'),
      'http://x/sub/assets/assets/pdf/cv.pdf',
    );
  });

  testWidgets('links are pointer-tappable, not just keyboard', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(wrap(
      IdentityPanel(profile: sampleProfile, theme: sampleTheme, onOpenLink: opened.add),
    ));
    await tester.tap(find.text('GitHub'), kind: PointerDeviceKind.mouse);
    expect(opened, ['https://github.com/BlueBeardone']);
  });
}
