# Flutter Portfolio Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the Express/EJS portfolio as a Flutter web app with a split-editorial layout, an animated matrix rain background, and all visitor-facing copy in editable `assets/data/*.json` files.

**Architecture:** A single-page Flutter web app. `main.dart` loads five JSON files through `ContentRepository` into typed models, then renders one `PortfolioPage` that switches between a two-pane desktop layout and a stacked mobile layout at 900px. A `CustomPainter` behind the content draws the matrix rain; a tab row swaps the three content panels inside an `AnimatedSwitcher`.

**Tech Stack:** Flutter 3.47.0 / Dart 3.13.0, `url_launcher`, `package:web` (conditional import for PDF download), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-11-17-flutter-portfolio-design.md`

## Global Constraints

- Flutter stable 3.47.0, Dart 3.13.0. Web only (`--platforms=web`).
- Static output: `flutter build web --release --base-href /`, publish dir `build/web`.
- Every visitor-facing string comes from `assets/data/*.json`. Nothing visitor-facing is hardcoded in Dart.
- Role text is exactly `Software Developer`.
- itch.io URL is exactly `https://itch.io/profile/4shblue`.
- Skills are one flat list. No proficiency levels, no group headings.
- No project tab, no routing, no backend, no analytics, no light mode.
- Matrix: accent-coloured, max layer opacity `0.28`, stops when the tab is hidden, static when `prefers-reduced-motion`.
- Base colours: background `#07090A`, text `#EEF2F0`, muted `#8EA79A`, accent `#4ADE80`, accent secondary `#22D3EE`.
- Old Node files are deleted in Task 1. PDFs move to `assets/pdf/`.
- Only functional dependencies: `url_launcher`, `web`. Fonts are bundled assets, never fetched at runtime.

## Review Focus

- **Malformed JSON typed by the owner** (trailing comma, missing quote): must show `ErrorView` naming file, field path and parser message — never a blank page. Pinned in Task 2 and Task 8.
- **Long content on a 320px-wide phone** (long skill detail, long name, long job description): must wrap and scroll, never overflow-stripe. Pinned in Task 5 and Task 7.
- **Broken or empty URL in `profile.json`**: row still renders, tap does nothing, no crash. Pinned in Task 5.
- **Desktop content taller than the viewport**: right panel scrolls while the identity panel stays visible; nothing clipped. Pinned in Task 7.
- **PDF asset URL**: must resolve from the page's own base URL (`Uri.base`), not an absolute path, so the file is found under any mount point. Pinned in Task 5.

---

### Task 1: Scaffold, dependencies, remove Node

**Files:**
- Create: `pubspec.yaml`, `web/index.html`, `.gitignore` (rewrite), `assets/pdf/` (moved)
- Delete: `app.js`, `views/`, `Public/css`, `Public/js`, `Public/images`, `package.json`, `package-lock.json`, `test/widget_test.dart`, default `lib/main.dart` body

**Interfaces:**
- Consumes: nothing.
- Produces: a building Flutter web app; `assets/data/` and `assets/fonts/` declared in `pubspec.yaml`; `assets/pdf/` containing both PDFs.

- [ ] **Step 1: Create the branch**

```bash
git checkout -b flutter-rebuild
```

- [ ] **Step 2: Scaffold the Flutter project in place**

Run: `flutter create . --platforms=web --project-name portfolio --empty`
Expected: `pubspec.yaml`, `lib/`, `web/`, `test/` created; existing files untouched.

- [ ] **Step 3: Move the PDFs and delete the Node implementation**

```bash
mkdir -p assets/pdf assets/data assets/fonts
git mv Public/pdf/Barend_Blom_CV.pdf assets/pdf/
git mv Public/pdf/GR12_Graduation_Marks.pdf assets/pdf/
git rm -r app.js views Public package.json package-lock.json
```

Expected: `git status` shows deletions of the Node files and the two PDFs as renames.

- [ ] **Step 4: Write `pubspec.yaml`**

Set: name `portfolio`, description "Personal portfolio of Barend Blom.", `publish_to: none`, `environment.sdk: ^3.13.0`. Dependencies: `flutter`, `cupertino_icons`, `url_launcher: ^6.3.0`, `web: ^1.0.0`. Dev: `flutter_test`, `flutter_lints: ^6.0.0`. `flutter: uses-material-design: true`, and assets: `assets/data/`, `assets/pdf/`. Fonts declared in Task 3.

- [ ] **Step 5: Write `.gitignore`**

Flutter defaults from the generated file, plus `.superpowers/`.

- [ ] **Step 6: Verify it builds**

Run: `flutter pub get && flutter analyze && flutter build web --release --base-href /`
Expected: analyze "No issues found"; `build/web/index.html` exists.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "chore: scaffold Flutter web app, remove Node implementation"
```

---

### Task 2: Models, JSON readers, content repository, content files

**Files:**
- Create: `lib/models/profile.dart`, `lib/models/skills.dart`, `lib/models/history.dart`, `lib/models/about.dart`, `lib/models/site_theme.dart`, `lib/models/site_content.dart`, `lib/data/json_read.dart`, `lib/data/content_repository.dart`
- Create: `assets/data/profile.json`, `skills.json`, `history.json`, `about.json`, `theme.json`
- Test: `test/data/content_repository_test.dart`, `test/data/json_read_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `class DataException implements Exception { final String file; final String path; final String message; }`
  - `String readString(Map<String, dynamic> json, String key, {required String file, String path = ''})`; same shape for `readList`, `readMap`, `readStringList`, `readOptionalString`.
  - `class ContentRepository { ContentRepository({AssetLoader? loader}); Future<SiteContent> load(); static const List<String> files; }` with `typedef AssetLoader = Future<String> Function(String key);` (defaults to `rootBundle.loadString`).
  - `class SiteContent { final Profile profile; final Skills skills; final History history; final About about; final SiteTheme theme; }`
  - Models: `Profile(kicker, name, role, location, List<LinkItem> links, Contact contact, List<PdfItem> pdfs, List<String> tabs)`, `LinkItem(label, url)`, `Contact(email, phone)`, `PdfItem(label, asset)`, `Skills(List<SkillItem> items, String highlight)`, `SkillItem(name, detail)`, `History(List<HistoryGroup> groups)`, `HistoryGroup(title, List<HistoryEntry> entries)`, `HistoryEntry(title, meta, description)`, `About(intro, List<AboutGroup> groups)`, `AboutGroup(title, List<String> items)`, `SiteTheme(colors…, layout…, type…, MatrixConfig matrix)` — `SiteTheme` fields are finalised in Task 3.
  - Every model has `factory X.fromJson(Map<String, dynamic> json, {required String file, String path = ''})`.

- [ ] **Step 1: Write the failing reader tests**

```dart
test('reports file and path for a missing required string', () {
  expect(
    () => readString({'name': 1}, 'name', file: 'profile.json', path: 'profile'),
    throwsA(isA<DataException>()
        .having((e) => e.file, 'file', 'profile.json')
        .having((e) => e.path, 'path', 'profile.name')
        .having((e) => e.message, 'message', contains('string'))),
  );
});

test('reports indexed path for a bad list item', () {
  final json = {'links': [1]};
  final list = readList(json, 'links', file: 'p.json');
  expect(
    () => readMap(list.first, '', file: 'p.json', path: 'p.links[0]'),
    throwsA(isA<DataException>().having((e) => e.path, 'path', 'p.links[0]')),
  );
});

test('readOptionalString returns empty string when absent', () {
  expect(readOptionalString({'a': 'x'}, 'missing', file: 'p.json'), '');
});

test('readStringList rejects a non-string member', () {
  expect(
    () => readStringList({'tabs': ['a', 2]}, 'tabs', file: 'p.json'),
    throwsA(isA<DataException>().having((e) => e.path, 'path', 'p.tabs[1]')),
  );
});
```

Write `test/data/json_read_test.dart` covering: missing key, wrong type, `readOptionalString`, and `readStringList` rejecting non-strings. Signature used above: `Map<String, dynamic> readMap(Object? value, String key, {required String file, String path = ''})` and `List<dynamic> readList(Map<String, dynamic> json, String key, {required String file, String path = ''})`.

- [ ] **Step 2: Run them and watch them fail**

Run: `flutter test test/data/json_read_test.dart`
Expected: FAIL — `readString` not defined.

- [ ] **Step 3: Implement `lib/data/json_read.dart`**

Each reader appends its key to `path` (`path.isEmpty ? key : '$path.$key'`); list readers append `[$i]`. Throw `DataException` with a message naming the expected and actual Dart type.

- [ ] **Step 4: Write the content JSON files**

`assets/data/profile.json`:

```json
{
  "_hint": "Everything in the left panel. Edit the text, save, and restart the dev server.",
  "kicker": "Portfolio / 2026",
  "name": "Barend Blom",
  "role": "Software Developer",
  "location": "Gauteng, South Africa",
  "links": [
    { "label": "GitHub", "url": "https://github.com/BlueBeardone" },
    { "label": "LinkedIn", "url": "https://www.linkedin.com/in/barend-blom-980b53265/" },
    { "label": "itch.io", "url": "https://itch.io/profile/4shblue" }
  ],
  "contact": { "email": "barend.army@gmail.com", "phone": "+27 72 919 9443" },
  "pdfs": [
    { "label": "Download CV", "asset": "assets/pdf/Barend_Blom_CV.pdf" },
    { "label": "Download Grades", "asset": "assets/pdf/GR12_Graduation_Marks.pdf" }
  ],
  "tabs": ["Skills", "History", "About"]
}
```

The email row in the identity panel is generated from `contact.email` and is not a `links` entry.

`assets/data/skills.json` — `_hint`, `highlight: "Specialised in full-stack development"`, and `items` in this order: C# & .NET / Advanced application development; Web / HTML5, CSS3, JavaScript (ES6+); Databases / MySQL, SQL Server, MongoDB; Python / Data analysis and automation; Game development / Unity, Unreal Engine; Frontend frameworks / React, Vue.js; Backend / Node.js, Express; Cloud / Azure, AWS; DevOps / Docker, CI/CD pipelines; Emerging tech / VR, AR, drone programming; Temporal / Durable code execution.

`assets/data/history.json` — three groups: `Education` (one entry: "BelgiumCampus iTversity — Software Engineering", meta "2023 — present"), `Work Experience` (VR and Drone Technologies — Software Developer, meta "2025"; Freelance Developer, meta "2024 — present"; Eps-Mathu — Junior Developer, meta "2026 — present"), and `Achievements` (four entries with `title` only, `meta` and `description` empty strings): contributed to projects on GitHub; participated in 3 hackathons and a few game jams; completed technical webinars on emerging technologies; completed the Temporal Fundamentals Certification.

`assets/data/about.json` — `intro`: "Creative problem-solver with a passion for game development and interactive experiences." Groups: `Personal Interests` ("Game development: indie projects in Unreal Engine and Unity", "Technology exploration: VR, drone tech, AI and emerging technologies"), `Values` ("Committed to writing clean, maintainable code and building digital experiences that make a difference."), `Currently Learning` ("Advanced Unity development", "Raspberry Pi development and electronics", "Cloud computing with AWS", "Advanced machine learning", "Temporal for durable code that does not depend on external services").

`assets/data/theme.json` — the full colour, layout, type and matrix object from Task 3.

- [ ] **Step 5: Write the failing repository tests**

```dart
test('loads all five files into typed content', () async {
  final content = await ContentRepository(loader: fakeLoader).load();
  expect(content.profile.role, 'Software Developer');
  expect(content.profile.links.map((l) => l.label), ['GitHub', 'LinkedIn', 'itch.io']);
  expect(content.profile.links.last.url, 'https://itch.io/profile/4shblue');
  expect(content.skills.items, hasLength(11));
  expect(content.history.groups.map((g) => g.title),
      ['Education', 'Work Experience', 'Achievements']);
  expect(content.about.groups.map((g) => g.title),
      ['Personal Interests', 'Values', 'Currently Learning']);
});

test('malformed JSON surfaces the file name', () async {
  expect(
    () => ContentRepository(loader: (key) async => key.endsWith('profile.json') ? '{"name": ' : '{}').load(),
    throwsA(isA<DataException>().having((e) => e.file, 'file', 'assets/data/profile.json')),
  );
});
```

Also assert that `load()` on the real bundled files passes (`ContentRepository(loader: rootBundle.loadString)` inside `TestWidgetsFlutterBinding.ensureInitialized()`), so a typo in a shipped JSON file fails a test.

- [ ] **Step 6: Run and watch fail**

Run: `flutter test test/data/content_repository_test.dart`
Expected: FAIL — `ContentRepository` not defined.

- [ ] **Step 7: Implement models and `ContentRepository`**

`ContentRepository.load()` reads each path in `files`, `jsonDecode`s it inside `try/catch` (wrapping `FormatException` into `DataException(file, '', e.message)`), asserts the root is a `Map`, and constructs the five model objects. `HistoryEntry.meta` and `.description` use `readOptionalString`.

- [ ] **Step 8: Run tests**

Run: `flutter test test/data/`
Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add lib/models lib/data assets/data test/data pubspec.yaml
git commit -m "feat: typed content models and JSON-backed repository"
```

---

### Task 3: Theme file and `ThemeData` mapping

**Files:**
- Create: `lib/theme/app_theme.dart`
- Modify: `lib/models/site_theme.dart`
- Test: `test/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: `SiteTheme.fromJson`, `DataException`, `readString`, `readMap`.
- Produces:
  - `class SiteColors { final Color background, text, muted, hairline, accent, accentSecondary, panel; }`
  - `class SiteLayout { final double breakpoint, maxContentWidth, pagePadding, identityWidthFactor; }`
  - `class SiteTypography { final double heroDesktop, heroMobile, nameTracking, bodySize, smallSize; }`
  - `class MatrixConfig { final bool enabled; final double opacity, speed, fontSize, maxLayerOpacity; final int trailLength; final Color color; }`
  - `class SiteTheme { final SiteColors colors; final SiteLayout layout; final SiteTypography type; final MatrixConfig matrix; }`
  - `Color parseHexColor(String value)` — accepts `#RRGGBB` and `#AARRGGBB`, throws `FormatException` on anything else.
  - `ThemeData buildThemeData(SiteTheme theme)` — dark `ColorScheme` from those colours, `fontFamily: 'Inter'`, text styles at the theme's sizes.

- [ ] **Step 1: Write failing tests**

```dart
test('parses 6- and 8-digit hex', () {
  expect(parseHexColor('#4ADE80'), const Color(0xFF4ADE80));
  expect(parseHexColor('#14FFFFFF'), const Color(0x14FFFFFF));
  expect(() => parseHexColor('green'), throwsFormatException);
});

test('theme uses the JSON accent and breakpoint', () {
  final themeJson = jsonDecode(File('assets/data/theme.json').readAsStringSync())
      as Map<String, dynamic>;
  final theme = SiteTheme.fromJson(themeJson, file: 'theme.json');
  expect(theme.colors.accent, const Color(0xFF4ADE80));
  expect(theme.layout.breakpoint, 900);
  expect(theme.matrix.maxLayerOpacity, 0.28);
  expect(buildThemeData(theme).colorScheme.brightness, Brightness.dark);
});
```

- [ ] **Step 2: Run and watch fail.** `flutter test test/theme/app_theme_test.dart`

- [ ] **Step 3: Write `assets/data/theme.json`**

```json
{
  "_hint": "Colours, sizes and matrix settings. Colours are #RRGGBB or #AARRGGBB.",
  "colors": {
    "background": "#07090A", "text": "#EEF2F0", "muted": "#8EA79A",
    "hairline": "#14FFFFFF", "accent": "#4ADE80", "accentSecondary": "#22D3EE",
    "panel": "#0B0F0D"
  },
  "layout": { "breakpoint": 900, "maxContentWidth": 1200, "pagePadding": 24, "identityWidthFactor": 0.4 },
  "type": { "heroDesktop": 88, "heroMobile": 44, "nameTracking": -2, "bodySize": 15, "smallSize": 12 },
  "matrix": {
    "enabled": true, "opacity": 1.0, "speed": 1.0, "fontSize": 16,
    "color": "#4ADE80", "trailLength": 8, "maxLayerOpacity": 0.28
  }
}
```

- [ ] **Step 4: Implement `SiteTheme` parsing and `buildThemeData`.** Numbers are read with a local `readDouble` helper that accepts `int` and `double` and wraps bad values in `DataException`.

- [ ] **Step 5: Bundle the fonts.** Download Inter regular/500/700 and Space Grotesk 700 as `.ttf` into `assets/fonts/` (from the `google/fonts` GitHub repo, e.g. `ofl/inter/Inter[opsz,wght].ttf` and `ofl/spacegrotesk/SpaceGrotesk[wght].ttf`). Declare families `Inter` and `SpaceGrotesk` in `pubspec.yaml` with the downloaded files. Verify each file is non-empty (`ls -l assets/fonts`). If the download is unavailable, set `fontFamily: null` in `buildThemeData` and record that in the README — do not add a network font dependency.

- [ ] **Step 6: Run tests, analyze, commit.**

```bash
flutter test test/theme && flutter analyze
git add assets/data/theme.json assets/fonts lib/models/site_theme.dart lib/theme test/theme pubspec.yaml
git commit -m "feat: theme tokens and ThemeData from data/theme.json"
```

---

### Task 4: Matrix rain logic and painter

**Files:**
- Create: `lib/ui/matrix_rain.dart`, `lib/ui/matrix_background.dart`
- Test: `test/ui/matrix_rain_test.dart`

**Interfaces:**
- Consumes: `MatrixConfig`.
- Produces:
  - `const String kMatrixAlphabet` — Katakana + digits + A–Z.
  - `class MatrixGlyph { final int column; final double y; final String char; final int layer; final double fontSize; }`
  - `class MatrixRain { MatrixRain({required double width, required double height, required MatrixConfig config, int? seed}); void resize(double width, double height); void advance(double dtSeconds); List<MatrixGlyph> get glyphs; List<MatrixGlyph> trailFor(int column); double layerOpacity(int layer); }`
  - `class MatrixBackground extends StatefulWidget { const MatrixBackground({required this.config, required this.child}); }` — paints the rain behind `child`.

- [ ] **Step 1: Write failing tests**

```dart
test('one column per 16 logical pixels', () {
  final rain = MatrixRain(width: 320, height: 800, config: cfg, seed: 1);
  expect(rain.glyphs, hasLength(20));
});

test('advance moves a column down', () {
  final rain = MatrixRain(width: 160, height: 800, config: cfg, seed: 1);
  final before = rain.glyphs.first.y;
  rain.advance(1.0);
  expect(rain.glyphs.first.y, greaterThan(before));
});

test('a column that passes 1.5x the height wraps to the top', () {
  final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
  for (var i = 0; i < 200; i++) { rain.advance(0.5); }
  expect(rain.glyphs.every((g) => g.y < 150), isTrue);
});

test('trail never exceeds trailLength and head is first', () {
  final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
  for (var i = 0; i < 30; i++) { rain.advance(0.2); }
  expect(rain.trailFor(0).length, lessThanOrEqualTo(cfg.trailLength));
  expect(rain.trailFor(0).first.char, rain.glyphs.firstWhere((g) => g.column == 0).char);
});

test('layer opacity is capped at maxLayerOpacity', () {
  final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
  expect(rain.layerOpacity(3), lessThanOrEqualTo(cfg.maxLayerOpacity));
  expect(rain.layerOpacity(0), lessThan(rain.layerOpacity(3)));
});

test('resize rebuilds the column count', () {
  final rain = MatrixRain(width: 160, height: 100, config: cfg, seed: 1);
  rain.resize(320, 100);
  expect(rain.glyphs, hasLength(20));
});
```

- [ ] **Step 2: Run and watch fail.** `flutter test test/ui/matrix_rain_test.dart`

- [ ] **Step 3: Implement `MatrixRain`**

Columns are spaced `config.fontSize` apart (16). Each column: y in units of font size, speed `0.5 + rand*1.5`, fontSize `fontSize + rand*8`, layer `0–3`. `advance` adds `speed * dt * 60 / fontSize` to y, resets to a negative y when `y * fontSize > height * 1.5`, and pushes the new glyph onto that column's ring buffer trimmed to `trailLength`. `layerOpacity(i)` returns `const [0.08, 0.15, 0.21, 0.28][i] * config.opacity` clamped to `config.maxLayerOpacity`.

- [ ] **Step 4: Implement `MatrixBackground`**

`Stack` with a `RepaintBoundary` + `CustomPaint` sized to the viewport, then `child`. `AnimationController` (`vsync`, `Duration.zero` repeat) calling `rain.advance(dt)` and `setState`. Stop on `AppLifecycleState.paused`/`hidden`, resume on `resumed`, dispose the controller. If `!config.enabled`, paint nothing. If `MediaQuery.disableAnimationsOf(context)` is true, do not start the ticker and paint a single static frame. Painter draws head glyphs at `layerOpacity(layer)` and trail glyphs at `layerOpacity * (1 - index/trailLength) * 0.6`, font `ui-monospace`.

- [ ] **Step 5: Widget test with animations disabled**

```dart
testWidgets('reduced motion paints without a ticker', (tester) async {
  await tester.pumpWidget(MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: MaterialApp(home: MatrixBackground(config: cfg, child: const SizedBox())),
  ));
  await tester.pump(const Duration(seconds: 1));
  expect(tester.takeException(), isNull);
  expect(find.byType(CustomPaint), findsWidgets);
});
```

Add it to `test/ui/matrix_rain_test.dart`.

- [ ] **Step 6: Run tests, analyze, commit.**

```bash
flutter test test/ui && flutter analyze
git add lib/ui/matrix_rain.dart lib/ui/matrix_background.dart test/ui
git commit -m "feat: matrix rain background with reduced-motion support"
```

---

### Task 5: Identity panel

**Files:**
- Create: `lib/ui/identity_panel.dart`, `lib/ui/widgets/hairline.dart`, `lib/ui/widgets/link_row.dart`, `lib/ui/widgets/pdf_button.dart`, `lib/data/launcher.dart`
- Test: `test/ui/identity_panel_test.dart`

**Interfaces:**
- Consumes: `Profile`, `SiteTheme`, `buildThemeData`.
- Produces:
  - `class IdentityPanel extends StatelessWidget { const IdentityPanel({required this.profile, required this.theme, this.onOpenLink, this.onDownloadPdf}); }` — `onOpenLink` is `void Function(String url)` and `onDownloadPdf` is `void Function(String asset)`; both default to `openUrl` and `downloadAsset` from `lib/data/launcher.dart`.
  - `class Hairline extends StatelessWidget { const Hairline({this.color}); }` — 1px divider at the theme hairline colour.
  - `class LinkRow extends StatelessWidget { const LinkRow({required this.label, required this.url, this.onTap}); }` — label, arrow `↗`, hairline underneath; tap with empty URL does nothing.
  - `class PdfButton extends StatelessWidget { const PdfButton({required this.label, required this.asset, this.onTap}); }`
  - `lib/data/launcher.dart`: `Future<void> openUrl(String url)`, `Future<void> downloadAsset(String asset)`, and `String resolveAssetUrl(Uri base, String asset)` returning `base.resolve('assets/$asset').toString()`.

- [ ] **Step 1: Write failing tests**

```dart
testWidgets('renders name, role and location from data', (tester) async {
  await tester.pumpWidget(wrap(IdentityPanel(profile: profile, theme: theme)));
  expect(find.text('Barend Blom'), findsOneWidget);
  expect(find.textContaining('Software Developer'), findsOneWidget);
  expect(find.textContaining('Gauteng, South Africa'), findsOneWidget);
  expect(find.text('Portfolio / 2026'), findsOneWidget);
});

testWidgets('each link row opens its URL in order, email last', (tester) async {
  final opened = <String>[];
  await tester.pumpWidget(wrap(IdentityPanel(profile: profile, theme: theme, onOpenLink: opened.add)));
  expect(find.text('GitHub'), findsOneWidget);
  await tester.tap(find.text('LinkedIn'));
  expect(opened, ['https://www.linkedin.com/in/barend-blom-980b53265/']);
  expect(find.text('barend.army@gmail.com'), findsOneWidget);
});

testWidgets('a link with an empty URL taps without crashing', (tester) async {
  final opened = <String>[];
  final broken = profileWith(links: [const LinkItem(label: 'Broken', url: '')]);
  await tester.pumpWidget(wrap(IdentityPanel(profile: broken, theme: theme, onOpenLink: opened.add)));
  await tester.tap(find.text('Broken'));
  expect(opened, isEmpty);
  expect(tester.takeException(), isNull);
});

testWidgets('long role text wraps on a 320px phone', (tester) async {
  tester.view.physicalSize = const Size(320, 900);
  tester.view.devicePixelRatio = 1.0;
  final long = profileWith(role: 'Software Developer and full-stack engineer with a very long descriptor');
  await tester.pumpWidget(wrap(IdentityPanel(profile: long, theme: theme)));
  expect(tester.takeException(), isNull);
});

test('asset URLs resolve against the page base', () {
  expect(resolveAssetUrl(Uri.parse('http://x/'), 'assets/pdf/cv.pdf'),
      'http://x/assets/assets/pdf/cv.pdf');
  expect(resolveAssetUrl(Uri.parse('http://x/sub/'), 'assets/pdf/cv.pdf'),
      'http://x/sub/assets/assets/pdf/cv.pdf');
});
```

Add `profileWith`, `sampleProfile`, `sampleTheme` and `wrap` to `test/support/fixtures.dart`: `wrap` returns `MaterialApp(theme: buildThemeData(theme), home: Scaffold(body: SizedBox(width: 900, child: child)))`; `profileWith` copies `sampleProfile` with named overrides via `copyWith`-style constructor arguments. Add `addTearDown(tester.view.resetPhysicalSize)` wherever a test sets `tester.view.physicalSize`.

- [ ] **Step 2: Run and watch fail.** `flutter test test/ui/identity_panel_test.dart`

- [ ] **Step 3: Implement the widgets**

Layout: `Column(crossAxisAlignment: start)` — kicker (letter-spaced, muted, small — render the JSON text as-is, never `toUpperCase()`, so the string on screen matches the file), name (`SpaceGrotesk`, `theme.type.heroDesktop` on desktop / `heroMobile` when width < breakpoint, tracking `nameTracking`, height 0.95), role+location line (muted, separated by ` · `), `SizedBox(height: 28)`, link rows (GitHub, LinkedIn, itch.io, then email from `contact.email` as `mailto:`; phone rendered as a muted non-tappable line under them), `Spacer`/sized gap, two `PdfButton`s side by side, each `Expanded`. All text `maxLines: null`, no `overflow: ellipsis`.

`openUrl`/`downloadAsset` live in `lib/data/launcher.dart` with a conditional import:

```dart
import 'launcher_stub.dart' if (dart.library.js_interop) 'launcher_web.dart';
```

`launcher_web.dart` opens `Uri.base.resolve(url)` in a new tab for links, and for PDFs creates an `HTMLAnchorElement` with `download` set and clicks it; `launcher_stub.dart` throws `UnsupportedError`. `resolveAssetUrl` is pure and lives in `launcher.dart` (testable on VM).

- [ ] **Step 4: Run tests, analyze, commit.**

```bash
flutter test test/ui/identity_panel_test.dart && flutter analyze
git add lib/ui/identity_panel.dart lib/ui/widgets lib/data/launcher*.dart test/ui/identity_panel_test.dart
git commit -m "feat: identity panel with links and PDF downloads"
```

---

### Task 6: Content panel, tab row, section rows

**Files:**
- Create: `lib/ui/content_panel.dart`, `lib/ui/tab_row.dart`, `lib/ui/widgets/numbered_row.dart`
- Test: `test/ui/content_panel_test.dart`

**Interfaces:**
- Consumes: `Skills`, `History`, `About`, `Profile.tabs`, `SiteTheme`.
- Produces:
  - `class ContentPanel extends StatefulWidget { const ContentPanel({required this.skills, required this.history, required this.about, required this.tabs, required this.theme}); }`
  - `class TabRow extends StatelessWidget { const TabRow({required this.labels, required this.selected, required this.onSelect, required this.accent}); }`
  - `class NumberedRow extends StatelessWidget { const NumberedRow({required this.index, required this.title, this.meta, this.description, this.trailing}); }`

- [ ] **Step 1: Write failing tests**

```dart
testWidgets('opens on the first tab and shows only skills', (tester) async {
  await tester.pumpWidget(wrap(ContentPanel(...)));
  expect(find.text('C# & .NET'), findsOneWidget);
  expect(find.text('BelgiumCampus iTversity — Software Engineering'), findsNothing);
});

testWidgets('tapping History swaps content and hides skills', (tester) async {
  await tester.pumpWidget(wrap(ContentPanel(...)));
  await tester.tap(find.text('History'));
  await tester.pumpAndSettle();
  expect(find.text('BelgiumCampus iTversity — Software Engineering'), findsOneWidget);
  expect(find.text('C# & .NET'), findsNothing);
});

testWidgets('tab labels come from data, not code', (tester) async {
  await tester.pumpWidget(wrap(ContentPanel(tabs: const ['One', 'Two', 'Three'], ...)));
  expect(find.text('One'), findsOneWidget);
  expect(find.text('Skills'), findsNothing);
});

testWidgets('arrow keys move between tabs', (tester) async {
  await tester.pumpWidget(wrap(ContentPanel(...)));
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
  await tester.pumpAndSettle();
  expect(find.text('BelgiumCampus iTversity — Software Engineering'), findsOneWidget);
});

testWidgets('entries with empty meta and description render title only', (tester) async {
  // History tab, Achievements group; assert no empty-text row widgets and no exception
  expect(tester.takeException(), isNull);
});
```

Use `wrap` and `sampleContent` from `test/support/fixtures.dart` (created in Task 5) — `sampleContent` holds the shape of the real JSON from Task 2, so the `...` above becomes `skills: sampleContent.skills, history: sampleContent.history, about: sampleContent.about, tabs: sampleContent.profile.tabs, theme: sampleContent.theme`.

- [ ] **Step 2: Run and watch fail.**

Run: `flutter test test/ui/content_panel_test.dart`
Expected: FAIL — `ContentPanel` not defined.

- [ ] **Step 3: Implement `TabRow`** — `Row` of text buttons, small letter-spaced, labels rendered exactly as supplied in `tabs`; selected uses accent colour plus a 2px accent underline via `AnimatedContainer`; wrapped in `Focus` + `Shortcuts` handling left/right arrows, Enter/Space.

- [ ] **Step 4: Implement `ContentPanel`** — `AnimatedSwitcher(duration: 200ms, transitionBuilder: FadeTransition + SlideTransition(0.02 down))` keyed by tab index. Skills view: `NumberedRow` per skill (`title` weight 600, `description` as the muted detail) then the highlight line with an accent left border. History view: per group, a small uppercase muted group title, then entries. About view: intro paragraph, then per group a title and `•` bullets.

- [ ] **Step 5: Run tests, analyze, commit.**

```bash
flutter test test/ui/content_panel_test.dart && flutter analyze
git add lib/ui/content_panel.dart lib/ui/tab_row.dart lib/ui/widgets/numbered_row.dart test/ui/content_panel_test.dart
git commit -m "feat: tabbed content panel for skills, history and about"
```

---

### Task 7: Responsive portfolio page

**Files:**
- Create: `lib/ui/portfolio_page.dart`
- Test: `test/ui/portfolio_page_test.dart`

**Interfaces:**
- Consumes: `SiteContent`, `IdentityPanel`, `ContentPanel`, `MatrixBackground`, `Hairline`.
- Produces: `class PortfolioPage extends StatelessWidget { const PortfolioPage({required this.content}); }`

- [ ] **Step 1: Write failing tests**

```dart
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
  final stack = tester.widget<Stack>(find.byType(Stack).first);
  expect(stack.children.length, greaterThanOrEqualTo(2));
});
```

Add `pumpAt` to `test/support/fixtures.dart`: it sets `tester.view.physicalSize` and `devicePixelRatio`, registers `addTearDown(tester.view.reset)`, and pumps `PortfolioApp(content: sampleContent)`.

- [ ] **Step 2: Run and watch fail.**

Run: `flutter test test/ui/portfolio_page_test.dart`
Expected: FAIL — `PortfolioPage` not defined.

- [ ] **Step 3: Implement `PortfolioPage`**

`MatrixBackground` wrapping a `LayoutBuilder`. Desktop: centred `ConstrainedBox(maxWidth: layout.maxContentWidth)`, `Row(crossAxisAlignment: stretch)` with `Expanded(flex: 4, IdentityPanel)` + `Hairline` (vertical, via `SizedBox(width: 1)` + coloured container) + `Expanded(flex: 6, scrollable ContentPanel)`. Mobile: `SingleChildScrollView` with padding, identity panel, horizontal `Hairline`, content panel. Use `MediaQuery.sizeOf(context).width >= layout.breakpoint` for the switch.

- [ ] **Step 4: Run tests, analyze, commit.**

```bash
flutter test test/ui/portfolio_page_test.dart && flutter analyze
git add lib/ui/portfolio_page.dart test/ui/portfolio_page_test.dart
git commit -m "feat: responsive split-editorial portfolio page"
```

---

### Task 8: Error view and app bootstrap

**Files:**
- Create: `lib/ui/error_view.dart`, `lib/app.dart`
- Modify: `lib/main.dart`
- Test: `test/app_test.dart`

**Interfaces:**
- Consumes: `ContentRepository`, `DataException`, `PortfolioPage`, `buildThemeData`.
- Produces:
  - `class ErrorView extends StatelessWidget { const ErrorView({required this.error}); }`
  - `class PortfolioApp extends StatelessWidget { const PortfolioApp({required this.content}); }`
  - `Future<void> main()` — `WidgetsFlutterBinding.ensureInitialized()`, then `runApp` with a `FutureBuilder` that renders a centred spinner, then `PortfolioApp` or `ErrorView`.

- [ ] **Step 1: Write failing tests**

```dart
testWidgets('a data error shows the file, path and message', (tester) async {
  final error = DataException(file: 'assets/data/profile.json', path: 'profile.name', message: 'expected string, got int');
  await tester.pumpWidget(MaterialApp(home: ErrorView(error: error)));
  expect(find.textContaining('assets/data/profile.json'), findsOneWidget);
  expect(find.textContaining('profile.name'), findsOneWidget);
  expect(find.textContaining('expected string'), findsOneWidget);
});

testWidgets('a valid load shows the portfolio', (tester) async {
  await tester.pumpWidget(PortfolioApp(content: sampleContent));
  expect(find.text('Barend Blom'), findsOneWidget);
});

testWidgets('a failing repository shows ErrorView, never a blank page', (tester) async {
  await tester.pumpWidget(bootstrapWith(FailingRepository()));
  await tester.pumpAndSettle();
  expect(find.byType(ErrorView), findsOneWidget);
});
```

Add `Future<void> pumpPortfolio(WidgetTester tester, SiteContent content)` helper in `test/support/`.

Add `sampleContent`, `FailingRepository` (its `load()` throws a `DataException`) and `bootstrapWith` to `test/support/fixtures.dart`; `bootstrapWith` wraps a repository in the same `FutureBuilder` bootstrap used by `main()`.

- [ ] **Step 2: Run and watch fail.**

- [ ] **Step 3: Implement `ErrorView`** — dark page, accent heading "Something is off in your data", then monospace blocks for file, field path and message, then the line "Fix the JSON file above and restart. Check for a missing quote or a trailing comma." Set the document title to "Portfolio — data error" in `initState` (no-op acceptable on VM tests).

- [ ] **Step 4: Implement `app.dart` and `main.dart`** — `PortfolioApp` builds `MaterialApp(theme: buildThemeData(content.theme), debugShowCheckedModeBanner: false, home: PortfolioPage(content: content))`. `main.dart` keeps the `FutureBuilder` and wraps any thrown `DataException` in `ErrorView`; unexpected exceptions get wrapped into a `DataException(file: 'unknown', path: '', message: e.toString())`.

- [ ] **Step 5: Run the whole suite.** `flutter test` — expect all green.

- [ ] **Step 6: Commit.**

```bash
git add lib/app.dart lib/main.dart lib/ui/error_view.dart test/app_test.dart test/support
git commit -m "feat: app bootstrap and readable data error screen"
```

---

### Task 9: Web metadata, Render config, README, final verification

**Files:**
- Modify: `web/index.html`, `web/manifest.json`, `README.md`
- Create: `render.yaml`, `scripts/render-build.sh`
- Test: manual + `flutter build web` inspection

**Interfaces:**
- Consumes: everything above.
- Produces: a deployable static site and instructions.

- [ ] **Step 1: Write `web/index.html` metadata** — `<title>Barend Blom — Software Developer</title>`, `<meta name="description" content="Portfolio of Barend Blom, software developer in Gauteng, South Africa.">`, `<meta name="theme-color" content="#07090A">`, body background `#07090A` so the first paint is not white, and an inline SVG favicon (same emoji trick as the old site).

- [ ] **Step 2: Write `scripts/render-build.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
FLUTTER_VERSION=3.47.0
if [ ! -x "$HOME/flutter/bin/flutter" ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter pub get
flutter build web --release --base-href /
```

`chmod +x scripts/render-build.sh`.

- [ ] **Step 3: Write `render.yaml`**

```yaml
services:
  - type: web
    name: barend-portfolio
    runtime: static
    buildCommand: bash scripts/render-build.sh
    staticPublishPath: build/web
    envVars:
      - key: FLUTTER_VERSION
        value: 3.47.0
    headers:
      - path: /assets/*
        name: Cache-Control
        value: public, max-age=31536000, immutable
```

- [ ] **Step 4: Rewrite `README.md`** — what it is; how to edit content (three lines pointing at `assets/data/`); `flutter pub get`, `flutter run -d chrome`, `flutter build web`; Render: static site, build command `bash scripts/render-build.sh`, publish `build/web`; note that Render has no Flutter SDK, so the script installs 3.47.0, and that swapping in a CI-built artifact works too.

- [ ] **Step 5: Verify the production build**

```bash
flutter build web --release --base-href /
test -f build/web/index.html && test -f build/web/assets/assets/data/profile.json
test -f "build/web/assets/assets/pdf/Barend_Blom_CV.pdf"
grep -c "Software Developer" build/web/assets/assets/data/profile.json
```

Expected: all exist; grep returns 1.

- [ ] **Step 6: Run the site and check by eye**

```bash
flutter run -d chrome
```

Check: rain moves; name and role read correctly; three tabs switch with a fade; GitHub/LinkedIn/itch.io open in new tabs; both PDFs download; resize the window narrow and confirm the layout stacks with no overflow stripes.

- [ ] **Step 7: Final full verification**

```bash
flutter analyze && flutter test
```

Expected: "No issues found" and all tests pass.

- [ ] **Step 8: Commit**

```bash
git add web scripts render.yaml README.md .gitignore
git commit -m "chore: deploy config, web metadata and README"
```
