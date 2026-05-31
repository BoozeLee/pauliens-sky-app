#!/usr/bin/env bash
set -euo pipefail

# iOS build script for Paulien's Sky
# Requires: macOS with Xcode 15+, Flutter SDK, CocoaPods

echo "=== Paulien's Sky iOS Build ==="

# 1. Verify macOS environment
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: iOS builds require macOS with Xcode." >&2
  exit 1
fi

if ! command -v xcodebuild &>/dev/null; then
  echo "ERROR: Xcode is not installed. Install from the App Store." >&2
  exit 1
fi

if ! command -v flutter &>/dev/null; then
  echo "ERROR: Flutter SDK not found." >&2
  exit 1
fi

# 2. Set defaults
CONFIGURATION="${CONFIGURATION:-release}"
EXPORT_METHOD="${EXPORT_METHOD:-app-store}"
CERT_BASE64="${CERT_BASE64:-}"
CERT_PASSWORD="${CERT_PASSWORD:-}"
PROVISION_PROFILE_BASE64="${PROVISION_PROFILE_BASE64:-}"
KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-tempkeychain}"

# 3. Import signing certificates if provided
if [[ -n "$CERT_BASE64" ]]; then
  echo "Importing signing certificate..."
  CERT_PATH=/tmp/build_cert.p12
  PROFILE_PATH=/tmp/build_profile.mobileprovision
  KEYCHAIN_PATH=/tmp/build.keychain

  echo "$CERT_BASE64" | base64 --decode > "$CERT_PATH"

  security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
  security set-keychain-settings -lut 3600 "$KEYCHAIN_PATH"
  security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

  security import "$CERT_PATH" -P "$CERT_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
  security list-keychain -d user -s "$KEYCHAIN_PATH"

  if [[ -n "$PROVISION_PROFILE_BASE64" ]]; then
    echo "$PROVISION_PROFILE_BASE64" | base64 --decode > "$PROFILE_PATH"
    mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
    UUID=$(grep -A1 'UUID' "$PROFILE_PATH" | grep -oE '[A-F0-9-]{36}' | head -1)
    cp "$PROFILE_PATH" "$HOME/Library/MobileDevice/Provisioning Profiles/$UUID.mobileprovision"
  fi

  rm -f "$CERT_PATH" "$PROFILE_PATH"
fi

# 4. Flutter setup
echo "Running flutter pub get..."
flutter pub get

# 5. CocoaPods
echo "Installing CocoaPods dependencies..."
cd ios
pod install --repo-update
cd ..

# 6. Build IPA
echo "Building $CONFIGURATION IPA..."
flutter build ipa --$CONFIGURATION --export-method "$EXPORT_METHOD"

echo ""
echo "=== Build complete ==="
echo "IPA: $(find build/ios/ipa -name '*.ipa' 2>/dev/null | head -1)"
echo "App: build/ios/iphoneos/Runner.app"
