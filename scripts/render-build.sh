#!/usr/bin/env bash
set -euo pipefail

# Render's build image has no Flutter SDK, so install the pinned version once
# per build and then produce the static site.
FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.0}"
FLUTTER_DIR="${HOME}/flutter"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
flutter --version
flutter pub get
flutter build web --release --base-href /
