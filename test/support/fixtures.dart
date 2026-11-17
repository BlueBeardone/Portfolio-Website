import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/data/content_repository.dart';
import 'package:portfolio/models/about.dart';
import 'package:portfolio/models/history.dart';
import 'package:portfolio/models/profile.dart';
import 'package:portfolio/models/site_content.dart';
import 'package:portfolio/models/site_theme.dart';
import 'package:portfolio/models/skills.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/ui/portfolio_page.dart';

/// Loads the real `assets/data/*.json` files, so widget tests run against the
/// same content the site ships with.
Future<SiteContent> loadSampleContent() =>
    ContentRepository(loader: (key) => File(key).readAsString()).load();

late SiteContent sampleContent;

SiteTheme get sampleTheme => sampleContent.theme;
Profile get sampleProfile => sampleContent.profile;
Skills get sampleSkills => sampleContent.skills;
History get sampleHistory => sampleContent.history;
About get sampleAbout => sampleContent.about;

Profile profileWith({
  String? kicker,
  String? name,
  String? role,
  String? location,
  List<LinkItem>? links,
  Contact? contact,
  List<PdfItem>? pdfs,
  List<String>? tabs,
}) {
  final base = sampleProfile;
  return Profile(
    kicker: kicker ?? base.kicker,
    name: name ?? base.name,
    role: role ?? base.role,
    location: location ?? base.location,
    links: links ?? base.links,
    contact: contact ?? base.contact,
    pdfs: pdfs ?? base.pdfs,
    tabs: tabs ?? base.tabs,
  );
}

Widget wrap(Widget child, {SiteTheme? theme, Size size = const Size(900, 900)}) {
  return MaterialApp(
    theme: buildThemeData(theme ?? sampleTheme),
    home: Scaffold(
      body: SizedBox(width: size.width, height: size.height, child: child),
    ),
  );
}

/// Pumps the real page at [size] with [disableAnimations] on, so the matrix
/// ticker does not keep `pumpAndSettle` spinning forever.
Future<void> pumpAt(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: true, size: size),
      child: MaterialApp(
        theme: buildThemeData(sampleTheme),
        home: PortfolioPage(content: sampleContent),
      ),
    ),
  );
  await tester.pump();
}
