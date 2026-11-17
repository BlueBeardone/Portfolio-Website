# Flutter portfolio — design

Date: 2026-11-17
Repo: `/Users/barendblom/Personal_Projects/Portfolio-Website`

## Intent

The site is currently an Express + EJS page: one screen, matrix rain canvas,
three buttons that swap HTML blobs from `main.js`, a footer with contact details
and two PDF downloads. The person who owns it wants it rebuilt as a Flutter web
app, with all the words moved out of code into a `data/` folder they can edit by
hand, and with a fresher look. They deploy to Render themselves.

The why: the content is rewritten often (new job, new skills). Today that means
editing HTML inside a JavaScript template string. After this, it means editing a
JSON file and re-deploying.

## Goals

- A Flutter web app that builds with `flutter build web` and deploys as a static
  site on Render (no server process, no API).
- A "split editorial" layout (direction C of the mockups), keeping the matrix
  rain from the current site.
- Every piece of visible text comes from `assets/data/*.json`. No copy in Dart.
- Someone who has never seen Flutter can open `assets/data/profile.json`, change
  a string, and have it show up.
- Looks right on a phone as well as a desktop browser.
- Fast first paint; no layout shift from fonts.

## Non-goals

- No CMS, no admin page, no edit-in-browser.
- No projects tab. Links out to GitHub / itch.io are enough (human partner's
  call, made after the projects question went unanswered).
- No routing/URLs per tab. It is one page; tabs are in-page state only, so a
  shared link always opens on Skills.
- No dark/light toggle. Dark only.
- No analytics, no contact form, no backend of any kind.

## Anti-goals

- **A build that needs Node.** If Render has to run anything but a static file
  server, this failed.
- **Copy hardcoded in widgets.** If changing a job title requires touching Dart,
  this failed.
- **A silent blank page.** A malformed JSON file must show a readable error, not
  an empty screen.
- **Matrix rain that fights the text.** Readability beats the effect. If a
  visitor has to squint, the rain is too strong.
- **A phone experience that is a squashed desktop.** Panels stack; type scales.

## Constraints

- Flutter 3.47.0 / Dart 3.13.0 is installed locally; target stable web only.
- Render **static site**: publish directory `build/web`. Render's build image has
  no Flutter SDK, so the repo ships `render.yaml` plus
  `scripts/render-build.sh`, which installs the pinned Flutter version
  (3.47.0) into a cache dir and runs `flutter build web --release
  --base-href /`. The human partner can replace that with their own build
  command or a CI job; the README documents the trade-off in five lines.
- The site is served from a domain root, so the base href is `/`. Asset and PDF
  URLs are still resolved from `Uri.base` (never a hardcoded origin or absolute
  path), so a subpath mount would not 404 the PDFs.
- The two existing PDFs (`Barend_Blom_CV.pdf`, `GR12_Graduation_Marks.pdf`) keep
  working as downloads.
- Repo is public and small; keep dependencies to a minimum.
- Existing Node files are removed in the same change; git history keeps them
  (the branch is `main`, so this is a deliberate, confirmed replacement of the
  old implementation, not an experiment).

## The look

One full-bleed dark page, matrix rain behind everything, slow and dim.

Desktop (>= 900px): two panels side by side, separated by a hairline.

- **Left panel** (~40%, pinned while the right scrolls if content overflows):
  small uppercase kicker `PORTFOLIO / 2026`; name in large tight type; one muted
  line of role and location (`Software developer · Gauteng, South Africa`);
  a stacked link list — GitHub, LinkedIn, itch.io, email — each row a hairline
  with the label and a small `↗`; at the bottom, two outline buttons: Download
  CV, Download Grades.
- **Right panel**: a tab row — Skills / History / About — in small uppercase
  text, the active one in accent green with a 1px underline; below, the active
  section's content: numbered rows separated by hairlines (Skills: name on the
  left in weight 600, detail in muted text beside it, no proficiency label;
  History: numbered entries grouped under Education / Work Experience / Achievements, each with a title, a
  muted date/meta line and a description; About: a short intro paragraph, then
  bulleted groups — Personal Interests, Values, Currently Learning).

Tab switches: content fades out and the new content fades in with a small
upward slide (~180–220ms, ease-out). The tab underline slides to the new tab.
Tabs are reachable by keyboard (left/right arrows, Enter/Space).

Mobile (< 900px): one column. Identity block on top (kicker, name, role, links,
buttons), tab row underneath, content below. Left panel is not pinned; nothing
is fixed. Font sizes step down; link rows keep the hairline treatment.

Content max width ~1200px, centred, generous padding (>= 24px on phones).

## Colour and type

Dark base `#07090A`; text `#EEF2F0`; muted text `#8EA79A`; hairline
`rgba(255,255,255,0.08)`; accent green `#4ADE80`; secondary accent cyan
`#22D3EE` used sparingly (hover, underline gradient on the name).

Type: two bundled fonts (no network fetch at runtime) — a tight geometric
grotesk for headings (Space Grotesk or Inter) and the same family at 400/500 for
body. Bundle as `assets/fonts/*.woff2`/`.ttf` with weights 400/500/700. The name
is set large (desktop ~clamp 56–88px, tracking -2px), line-height ~0.95.

Everything colour and size-ish lives in `assets/data/theme.json`; the Dart
defaults mirror it so the app still runs if a key is missing.

## The matrix rain

`lib/ui/matrix_background.dart`: a `CustomPainter` on an `AnimationController`
driven ticker, one glyph per column per frame, same behaviour as the current
`matrix.js`:

- Glyph alphabet: Katakana + digits + A–Z, from a fixed string in Dart.
- Columns every ~16 logical px, each with its own y, speed (0.5–2.0), font size
  (14–24) and depth layer.
- Four depth layers; nearer layers brighter and more opaque. Current palette is
  green RGB(12,255,12) at 0.15/0.4/0.7/1.0 → in the new design capped so the
  brightest layer never exceeds ~0.28 opacity over the page background, and the
  glyph colour is the theme accent, so the rain reads as texture, not noise.
- Each frame draws, per column, a short trail: the glyph plus ~8 trailing glyphs
  at decreasing opacity. Flutter's `CustomPainter` cannot accumulate pixels the
  way the old JS canvas did, so the trail is drawn explicitly instead of relying
  on a translucent wash over a persistent buffer. This is the cheap, 60fps-safe
  option and is visually close to today; it will not be pixel-identical, and
  that is acceptable.
- Resize rebuilds the column set.
- Stop the ticker when the tab is hidden (`AppLifecycleState`) and when the
  widget is disposed.
- Respect `prefers-reduced-motion`: draw one static faint field, no animation.
- Knobs from `theme.json`: `matrix.enabled`, `matrix.opacity`, `matrix.speed`,
  `matrix.fontSize`, `matrix.color`.

## Data folder

`assets/data/` is the editable surface. Each file is plain, pretty-printed JSON
with no comments (JSON has none) and a `_hint` string at the top where a field is
not obvious. All are bundled via `pubspec.yaml` `assets:`.

```
assets/data/profile.json   name, role, location, kicker, links[], contact, pdfs[],
                           tabs[] (labels for the right-hand tab row)
assets/data/skills.json    items[ {name, detail} ], highlight
assets/data/history.json   groups[ {title, entries[ {title, meta, description} ]} ]
assets/data/about.json     intro, groups[ {title, items[]} ]
assets/data/theme.json     colors, fonts sizes, layout breakpoint, matrix knobs
```

One home per thing — no field may be expressible twice:

- **History**: Education, Work Experience and Achievements are all just
  `groups[]` entries, in display order, each with a `title`. There is no separate
  top-level `achievements` list (removed from the earlier sketch after review).
- **About**: Personal Interests, Values and Currently Learning are all
  `groups[]` entries. "Values" is a group with one paragraph item, not a separate
  top-level field.
- **Skills** is one flat numbered list — no headings, no proficiency levels
  (human partner: levels "make zero sense"). `highlight` renders as the
  "Specialised in: …" line under the list; there is no separate `intro`.
- **Tab labels** live in `profile.json` under `tabs[]`, so "no copy in Dart"
  holds for the navigation too. Structural strings that are not content — the
  error view's explanatory sentence, "Something is off in your data" — stay in
  Dart, because they exist to help the editor, not the visitor.

`profile.json` sketch:

```json
{
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
  ]
}
```

Parsing: `lib/data/content_repository.dart` loads all five files with
`rootBundle`, decodes into typed models in `lib/models/`. Required fields are
non-nullable; on a decode/validation failure the app renders `error_view.dart`
listing the file, the field path and the parser message, plus a line telling the
editor what to check. Missing optional fields fall back to defaults rather than
crashing. `role` reads `Software Developer`.

Copy of the existing content: Skills list, History (BelgiumCampus iTversity;
VR and Drone Technologies; Freelance; Eps-Mathu internship; achievements), and
About (intro, interests, values, currently learning) is migrated verbatim from
`Public/js/main.js` into these JSON files, with the emoji removed where the new
design does not use them and light copy-editing (capitalisation, "Rasberry" →
"Raspberry", "mid of 2025 – end of 2025" → "2025").

## Files and structure

```
pubspec.yaml            flutter, cupertino_icons, url_launcher
web/index.html          title, meta description, favicon, theme-color
lib/main.dart           bootstrap: load data, runApp
lib/app.dart            MaterialApp, theme from theme.json
lib/theme/app_theme.dart
lib/models/*.dart
lib/data/content_repository.dart
lib/ui/portfolio_page.dart     layout switch desktop/mobile, scroll
lib/ui/identity_panel.dart
lib/ui/content_panel.dart      tab state + AnimatedSwitcher
lib/ui/tab_row.dart
lib/ui/matrix_background.dart
lib/ui/widgets/*.dart          hairline, link_row, section_rows, pdf_button
lib/ui/error_view.dart
assets/data/*.json
assets/fonts/
assets/pdf/*.pdf
```

Removed: `app.js`, `views/`, `Public/css`, `Public/js`, `Public/images`,
`package.json`, `package-lock.json`. Kept: the PDFs (moved to `assets/pdf/`).

README rewritten: what it is, `flutter pub get`, `flutter run -d chrome`,
`flutter build web`, Render settings (build command, publish dir), and a
"how to edit your content" section that is three lines long.

`.gitignore` gains `.superpowers/` and the usual Flutter ignores
(`build/`, `.dart_tool/`).

## Decisions I am making (not the human partner's)

- **Fonts bundled, not fetched.** Render serves the files; no runtime dependency
  on Google Fonts, no FOUT, works offline.
- **No projects tab**, per the goals above.
- **One flat skills list**, no grouping headings, no proficiency words — the
  human partner rejected levels; flat also matches the mockup they approved.
- **itch.io points at the public profile**, `https://itch.io/profile/4shblue`,
  replacing the dashboard URL that the old site used.
- **Tabs are in-page only** — no `#skills` deep links in v1.
- **Locale is hardcoded en-ZA** for the date-ish strings; all dates are pre-baked
  strings in JSON, so no date formatting in Dart.
- **`url_launcher` is the only functional dependency**, plus `web` for a real
  `download` attribute on the PDF buttons (conditional import so analysis on
  other platforms still compiles). If `url_launcher` proves unnecessary it is
  dropped.
- **Phone number stays in the data file** but is only shown in the footer of the
  identity panel on desktop and in the About panel on mobile, once, not twice.
- **Old Node implementation is deleted in this change**, as the request was to
  turn the project into a Flutter project rather than to run both.

## What success looks like

Open the deployed link on a phone and on a laptop: the matrix rain moves slowly
behind the page, the name reads instantly, the three tabs switch with a fade,
every link opens in a new tab, both PDFs download, and changing
`assets/data/profile.json` then re-running `flutter run -d chrome` shows the new
text with no Dart edits.
