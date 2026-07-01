#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$MOBILE_DIR"

FLUTTER_DIR=".flutter-sdk"
if [ ! -d "$FLUTTER_DIR" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi
export PATH="$(pwd)/$FLUTTER_DIR/bin:$PATH"

flutter config --enable-web --no-analytics
flutter --version
flutter pub get

if [ -z "${API_BASE_URL:-}" ] && [ -n "${API_HOST:-}" ]; then
  API_BASE_URL="https://${API_HOST}/api/v1"
fi

if [ -z "${API_BASE_URL:-}" ]; then
  echo "WARNING: API_BASE_URL is not set. The web app will fall back to dev_host or localhost."
fi

flutter build web --release \
  --dart-define=API_BASE_URL="${API_BASE_URL:-}"

echo "Flutter web build complete: $MOBILE_DIR/build/web"
