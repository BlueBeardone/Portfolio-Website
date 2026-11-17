# Portfolio — Barend Blom

My personal portfolio: a single-page Flutter web app with a matrix-rain
background and a split editorial layout. Everything you read on the page comes
from the JSON files in `assets/data/`.

## Editing your content

All the copy lives in `assets/data/`:

| File | What it controls |
|------|------------------|
| `profile.json` | Name, role, location, links, email/phone, PDF buttons, tab labels |
| `skills.json` | The Skills tab |
| `history.json` | The History tab (Education, Work Experience, Achievements) |
| `about.json` | The About tab |
| `theme.json` | Colours, sizes, and the matrix rain settings |

Edit a file, save, and the dev server hot-reloads. If you break the JSON, the
page shows an error naming the file and field instead of going blank.

The PDFs are in `assets/pdf/`. Replace them in place and keep the file names in
`profile.json` in sync.

## Running it locally

```bash
flutter pub get
flutter run -d chrome
```

## Building

```bash
flutter build web --release --base-href /
```

The static site lands in `build/web`.

## Deploying on Render

Render's build image does not include the Flutter SDK, so `scripts/render-build.sh`
installs the pinned version (3.47.0) and then builds:

- Type: **Static Site**
- Build command: `bash scripts/render-build.sh`
- Publish directory: `build/web`

`render.yaml` is included if you prefer a Blueprint. If you would rather not
install the SDK on every deploy, build `build/web` in CI and publish that
artifact instead — the publish settings stay the same.

## Tests

```bash
flutter test
flutter analyze
```

Tests cover the JSON readers and error paths, the matrix simulation, the
identity panel, the tab row, the responsive layout, and the bootstrap.
