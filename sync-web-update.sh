#!/usr/bin/env bash
# Re-syncs an updated MindPulse web app source into this mobile wrapper's
# www/ folder, without touching www/config.js (your backend URL) or any of
# the native android/ios wrapper setup.
#
# Usage:
#   ./sync-web-update.sh /path/to/your/updated/mindpulse-main
#
# Then run `npx cap sync` to push the change into android/ and ios/, and
# rebuild (Android Studio / Xcode, or push to GitHub for the Actions
# workflows to build it).

set -euo pipefail

SRC="${1:-}"
if [ -z "$SRC" ] || [ ! -d "$SRC" ]; then
  echo "Usage: $0 /path/to/updated/mindpulse-main"
  echo "  (the folder containing your updated index.html, app.js, styles.css, etc.)"
  exit 1
fi

DEST="$(cd "$(dirname "$0")" && pwd)/www"

# Files that come from your web app source and should be overwritten.
FILES=(
  "index.html"
  "app.js"
  "styles.css"
  "manifest.webmanifest"
  "service-worker.js"
)

echo "Syncing web app files from: $SRC"
echo "                       into: $DEST"
echo

for f in "${FILES[@]}"; do
  if [ -f "$SRC/$f" ]; then
    cp -v "$SRC/$f" "$DEST/$f"
  else
    echo "  (skipping $f - not found in source folder)"
  fi
done

# Copy any logo/image assets too (won't overwrite config.js since it's not in this list)
for img in "$SRC"/*.png "$SRC"/*.jpg "$SRC"/*.svg; do
  [ -e "$img" ] || continue
  cp -v "$img" "$DEST/"
done

echo
echo "Done. www/config.js was left untouched."
echo "Next steps:"
echo "  1. Re-check app.js still uses 'window.MINDPULSE_CONFIG?.API_URL' as the"
echo "     first fallback for API_URL, and still guards the service worker"
echo "     registration with '&& !window.Capacitor' (in case your edits"
echo "     re-generated app.js from scratch and dropped those two tweaks)."
echo "  2. Run: npx cap sync"
echo "  3. Rebuild in Android Studio / Xcode, or push to GitHub."
