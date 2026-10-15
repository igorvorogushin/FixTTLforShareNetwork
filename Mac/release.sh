#!/usr/bin/env bash
# Builds TTL Fix for macOS, signs it with Developer ID, packs it into a DMG, notarizes and staples it.
#   Mac/release.sh            -> dist/TTL-Fix-macOS.dmg
# One-time setup, asks for an app-specific password from appleid.apple.com:
#   Mac/release.sh --setup [apple-id]
# Override the profile with TTLFIX_NOTARY_PROFILE=<name>.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEAM_ID="7NHKFV93JQ"
NOTARY_PROFILE="${TTLFIX_NOTARY_PROFILE:-ttlfix-notary}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [ "${1:-}" = "--setup" ]; then
  exec xcrun notarytool store-credentials "$NOTARY_PROFILE" --apple-id "${2:-igorvorogushin1@gmail.com}" --team-id "$TEAM_ID"
fi

IDENTITY="$(security find-identity -v -p codesigning | awk -F'"' "/Developer ID Application: .*\\($TEAM_ID\\)/ {print \$2; exit}")"
[ -n "$IDENTITY" ] || { echo "!! no 'Developer ID Application' identity for team $TEAM_ID in the keychain" >&2; exit 1; }
xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1 || {
  echo "!! notarytool profile '$NOTARY_PROFILE' is missing — see the setup note at the top of this script" >&2; exit 1; }

WORK="$ROOT/build/release"
DIST="$ROOT/dist"
APP="$WORK/Build/Products/Release/TTL Fix.app"
DMG="$DIST/TTL-Fix-macOS.dmg"
rm -rf "$WORK" && mkdir -p "$WORK" "$DIST"

echo "==> building ($IDENTITY)"
xcodebuild -project "$ROOT/Mac/TTLFix.xcodeproj" -scheme 'TTL Fix' -configuration Release \
  -derivedDataPath "$WORK" -destination 'generic/platform=macOS' ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_STYLE=Manual "CODE_SIGN_IDENTITY=$IDENTITY" DEVELOPMENT_TEAM="$TEAM_ID" PROVISIONING_PROFILE_SPECIFIER= \
  ENABLE_HARDENED_RUNTIME=YES CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO "OTHER_CODE_SIGN_FLAGS=--timestamp" \
  -quiet build

codesign --verify --deep --strict "$APP"
SIGNATURE="$(codesign -dv "$APP" 2>&1)"
grep -q "TeamIdentifier=$TEAM_ID" <<<"$SIGNATURE" && grep -q 'flags=0x10000(runtime)' <<<"$SIGNATURE" \
  || { echo "!! app is not signed with Developer ID + hardened runtime:"; echo "$SIGNATURE"; exit 1; } >&2

echo "==> packaging DMG"
STAGE="$WORK/dmg"
mkdir -p "$STAGE" && ditto "$APP" "$STAGE/TTL Fix.app" && ln -s /Applications "$STAGE/Applications"
rm -f "$DMG"
hdiutil create -quiet -volname "TTL Fix" -srcfolder "$STAGE" -fs HFS+ -format UDZO -imagekey zlib-level=9 "$DMG"
codesign --sign "$IDENTITY" --timestamp "$DMG"

echo "==> notarizing (the first submission for a new app can take a while)"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" | tee "$WORK/notary.log"
ID="$(awk '/^  id:/ {print $2; exit}' "$WORK/notary.log")"
[ -n "$ID" ] || { echo "!! no submission id in the notarytool output" >&2; exit 1; }
# Waiting is retried: a dropped connection while polling must not lose a submission that is still in progress.
STATUS=""
for _ in $(seq 1 60); do
  xcrun notarytool wait "$ID" --keychain-profile "$NOTARY_PROFILE" --timeout 3h >/dev/null 2>&1 || true
  STATUS="$(xcrun notarytool info "$ID" --keychain-profile "$NOTARY_PROFILE" 2>/dev/null | awk -F': ' '/^  status:/ {print $2}')"
  [ -n "$STATUS" ] && [ "$STATUS" != "In Progress" ] && break
  echo "    still waiting ($(date +%H:%M), status: ${STATUS:-no connection})"
  sleep 30
done
[ "$STATUS" = "Accepted" ] || {
  echo "!! notarization status: ${STATUS:-unknown}. Details: xcrun notarytool log $ID --keychain-profile $NOTARY_PROFILE" >&2; exit 1; }

xcrun stapler staple -q "$DMG"
spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG"
echo "==> $DMG"
