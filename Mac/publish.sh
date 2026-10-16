#!/usr/bin/env bash
# Publishes the already notarized dist/TTL-Fix-macOS.dmg (made by Mac/release.sh) to the site's /downloads/.
# Refuses a DMG that is not Developer ID signed or not notarized; staples the ticket if it is missing.
# Also run from Xcode: scheme "Publish", Product > Build.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEAM_ID="7NHKFV93JQ"
DMG="$ROOT/dist/TTL-Fix-macOS.dmg"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

[ -f "$ROOT/deploy/config.sh" ] || { echo "error: deploy/config.sh not found (deploy/ is kept local only)" >&2; exit 1; }
source "$ROOT/deploy/config.sh"
[ -f "$DMG" ] || { echo "error: $DMG not found — run Mac/release.sh first" >&2; exit 1; }

echo "==> checking $DMG"
codesign --verify --strict "$DMG"
# Captured first: piping into `grep -q` lets codesign die of SIGPIPE, which pipefail reports as a failure.
SIGNATURE="$(codesign -dv "$DMG" 2>&1)"
grep -q "TeamIdentifier=$TEAM_ID" <<<"$SIGNATURE" \
  || { echo "error: DMG is not signed with Developer ID ($TEAM_ID)" >&2; exit 1; }
# Notarized but not stapled (e.g. release.sh was interrupted after "Accepted"): fetch the ticket from Apple now.
if ! xcrun stapler validate -q "$DMG"; then
  echo "==> no ticket stapled, fetching it from Apple"
  xcrun stapler staple -q "$DMG" && xcrun stapler validate -q "$DMG" \
    || { echo "error: Apple has no notarization ticket for this DMG — notarize it first (Mac/release.sh)" >&2; exit 1; }
fi

echo "==> uploading -> $SERVER:$DOWNLOADS_DIR"
ssh "${SSH_OPTS[@]}" "$SERVER" "mkdir -p $DOWNLOADS_DIR"
# Upload under a temporary name, then rename: a download in progress never sees a half-written file.
rsync -tz -e "ssh ${SSH_OPTS[*]}" "$DMG" "$SERVER:$DOWNLOADS_DIR/TTL-Fix-macOS.dmg.part"
ssh "${SSH_OPTS[@]}" "$SERVER" "cd $DOWNLOADS_DIR && mv TTL-Fix-macOS.dmg.part TTL-Fix-macOS.dmg && chmod 644 TTL-Fix-macOS.dmg"

# The site's download button must point at the DMG too.
"$ROOT/deploy/deploy_site.sh"

curl -fsSI -o /dev/null -w "    %{http_code} /downloads/TTL-Fix-macOS.dmg\n" "https://$DOMAIN/downloads/TTL-Fix-macOS.dmg"
echo "==> https://$DOMAIN/downloads/TTL-Fix-macOS.dmg"
