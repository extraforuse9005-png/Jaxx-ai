#!/data/data/com.termux/files/usr/bin/bash
# JAXX AI - Termux setup and APK build script (Phase 1).
# Run from inside the unzipped jaxx_ai folder:  bash build_termux.sh
set -e

echo "== JAXX AI build helper =="

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: 'flutter' is not on your PATH."
  echo "Install Flutter first (see README-TERMUX.md, section 2)."
  exit 1
fi

if [ ! -f pubspec.yaml ] || [ ! -d lib ]; then
  echo "ERROR: Run this script from the jaxx_ai project folder."
  exit 1
fi

echo "-- Flutter version:"
flutter --version | head -n 1

# Step 1: generate the Android folder (the zip does not include it).
# flutter create skips files that already exist, but we back up pubspec.yaml
# anyway so our version is always the one that is kept.
if [ ! -d android ]; then
  echo "-- Generating the android/ folder..."
  cp pubspec.yaml pubspec.yaml.bak
  flutter create --org com.jaxxai --project-name jaxx_ai --platforms=android .
  mv -f pubspec.yaml.bak pubspec.yaml
else
  echo "-- android/ folder already exists, skipping generation."
fi

# Step 2: set the package name and app label.
GRADLE_KTS="android/app/build.gradle.kts"
GRADLE_GROOVY="android/app/build.gradle"
if [ -f "$GRADLE_KTS" ]; then
  sed -i 's/applicationId = ".*"/applicationId = "com.jaxxai.assistant"/' "$GRADLE_KTS"
elif [ -f "$GRADLE_GROOVY" ]; then
  sed -i "s/applicationId \".*\"/applicationId \"com.jaxxai.assistant\"/" "$GRADLE_GROOVY"
fi
sed -i 's/android:label="[^"]*"/android:label="JAXX AI"/' android/app/src/main/AndroidManifest.xml

# Step 3: add the INTERNET permission for later Gemini phases (harmless now).
MANIFEST="android/app/src/main/AndroidManifest.xml"
if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  sed -i 's|<manifest xmlns:android="http://schemas.android.com/apk/res/android">|&\n    <uses-permission android:name="android.permission.INTERNET"/>|' "$MANIFEST"
fi

echo "-- Fetching packages..."
flutter pub get

echo "-- Running analyzer..."
flutter analyze

echo "-- Running tests..."
flutter test

echo "-- Building release APK (this can take a long time on a phone)..."
flutter build apk --release

echo
echo "Done. APK location:"
echo "  build/app/outputs/flutter-apk/app-release.apk"
