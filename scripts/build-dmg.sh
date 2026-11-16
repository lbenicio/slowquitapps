#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist}"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$ROOT_DIR/SlowQuitApps/SlowQuitApps-Info.plist")"
BUILD_DIR="$ROOT_DIR/.build/release-$VERSION-$(date +%Y%m%d%H%M%S)"
TEAM_ID="${DEVELOPMENT_TEAM:-}"
SIGNING_IDENTITY="${SIGNING_IDENTITY:-}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid app version in Info.plist: $VERSION" >&2
    exit 2
fi
if [[ ! "$TEAM_ID" =~ ^[A-Z0-9]{10}$ ]]; then
    echo "Set DEVELOPMENT_TEAM to the 10-character Apple Developer Team ID." >&2
    exit 2
fi
if [[ -z "$SIGNING_IDENTITY" ]]; then
    echo "Set SIGNING_IDENTITY to a Developer ID Application certificate name or SHA-1." >&2
    exit 2
fi

mkdir -p "$BUILD_DIR" "$DIST_DIR"
ARCHIVE_PATH="$BUILD_DIR/SlowQuitApps.xcarchive"
APP_PATH="$ARCHIVE_PATH/Products/Applications/SlowQuitApps.app"
SOURCE_ARCHIVE="$DIST_DIR/SlowQuitApps-$VERSION-source.tar.gz"
DMG_PATH="$DIST_DIR/SlowQuitApps-$VERSION.dmg"
STAGING_DIR="$BUILD_DIR/dmg-root"

if [[ -e "$SOURCE_ARCHIVE" || -e "$DMG_PATH" ]]; then
    echo "A release artifact for version $VERSION already exists in $DIST_DIR." >&2
    exit 2
fi

xcodebuild \
    -quiet \
    -project "$ROOT_DIR/SlowQuitApps.xcodeproj" \
    -scheme SlowQuitApps \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -archivePath "$ARCHIVE_PATH" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
    DEVELOPMENT_TEAM="$TEAM_ID" \
    ENABLE_HARDENED_RUNTIME=YES \
    archive

if [[ ! -d "$APP_PATH" ]]; then
    echo "Xcode archive did not contain the expected app: $APP_PATH" >&2
    exit 1
fi
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

tar \
    --exclude='./.git' \
    --exclude='./.build' \
    --exclude='./dist' \
    --exclude='*/.DS_Store' \
    --exclude='./.DS_Store' \
    --exclude='./LICENSE.yxy' \
    --exclude='*/xcuserdata' \
    --exclude='*/xcshareddata' \
    --exclude='*.xcuserstate' \
    -czf "$SOURCE_ARCHIVE" \
    -C "$ROOT_DIR" .

mkdir -p "$STAGING_DIR"
ditto "$APP_PATH" "$STAGING_DIR/SlowQuitApps.app"
ln -s /Applications "$STAGING_DIR/Applications"
cp "$ROOT_DIR/LICENSE.txt" "$STAGING_DIR/LICENSE.txt"
cp "$SOURCE_ARCHIVE" "$STAGING_DIR/SlowQuitApps-$VERSION-source.tar.gz"
cat > "$STAGING_DIR/README.txt" <<EOF
SlowQuitApps $VERSION

Drag SlowQuitApps.app to Applications. The matching complete source archive
and GPL license are included in this disk image.

This app requires Accessibility permission to observe keyboard events and
handle Cmd-Q locally. It does not transmit keystrokes.
EOF

hdiutil create \
    -volname "SlowQuitApps $VERSION" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"
codesign --force --sign "$SIGNING_IDENTITY" --timestamp "$DMG_PATH"
codesign --verify --strict --verbose=2 "$DMG_PATH"

if [[ "${NOTARIZE:-0}" == "1" ]]; then
    if [[ -z "${NOTARY_PROFILE:-}" ]]; then
        echo "Set NOTARY_PROFILE to a notarytool Keychain profile before notarizing." >&2
        exit 2
    fi
    xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG_PATH"
    xcrun stapler validate "$DMG_PATH"
fi

(
    cd "$DIST_DIR"
    shasum -a 256 "$(basename "$DMG_PATH")" "$(basename "$SOURCE_ARCHIVE")" > SHA256SUMS
)

echo "Created: $DMG_PATH"
echo "Source:  $SOURCE_ARCHIVE"
echo "Hashes:  $DIST_DIR/SHA256SUMS"
if [[ "${NOTARIZE:-0}" != "1" ]]; then
    echo "Notarization was not requested; the signed DMG may still trigger Gatekeeper on first launch."
fi
