# JAXX AI - Phase 1 (build in Termux)

## 1. What is in this zip

- `lib/`, `test/`, `pubspec.yaml`: the app source code (Phase 1).
- `build_termux.sh`: a script that generates the Android folder, sets the
  package name `com.jaxxai.assistant`, runs checks, and builds the APK.

The zip does not include `android/`. Flutter generates it for you, because
it contains Gradle files that must match your installed Flutter version.

## 2. Honest expectations about Termux

Building an Android APK inside Termux is possible but fragile. It needs
the Android SDK, the Android build tools (aapt2), Java, and Flutter, all
of which were built for desktop Linux. Expect problems on some phones.

- Running the app code, `flutter analyze`, and `flutter test` in Termux is
  more likely to work.
- If `flutter build apk` fails, the reliable fallback is to copy this folder
  to a computer, or to a GitHub repository, and build there. The same
  `flutter build apk --release` command works there.

I have not been able to run a build myself, so do not assume it succeeds.
Paste any error output back and we will fix it.

## 3. One-time Termux setup

Install the basic tools:

```bash
pkg update && pkg upgrade -y
pkg install -y git unzip openjdk-17 aapt2
termux-setup-storage
```

Install Flutter. The Termux-friendly route is a community Flutter build for
Termux or a proot Ubuntu, because Google's official Flutter download is
built for x86 desktop Linux. Check the current instructions for the
Termux Flutter setup, install Flutter, then confirm:

```bash
flutter --version
flutter doctor
```

Accept Android licences if `flutter doctor` asks:

```bash
flutter doctor --android-licenses
```

## 4. Unzip and build

```bash
cd ~/storage/downloads
unzip jaxx_ai.zip -d ~/projects
cd ~/projects/jaxx_ai
bash build_termux.sh
```

The APK will be at:

```
build/app/outputs/flutter-apk/app-release.apk
```

Open that file on your phone to install it. Android will ask you to allow
installs from unknown sources. That is normal for a personal build.

## 5. Test it

1. The home screen shows an animated orb, the greeting, and "Talk to JAXX".
2. Open Settings from the top-right icon.
3. Open chat, send a message, and confirm JAXX replies honestly that its
   AI brain is not connected yet.

## 6. Known limitations in Phase 1

- No AI, voice, app launching, YouTube, Screen Control, Code Lab, or memory.
- Chat is not saved between launches.
- Not tested on a physical device by the author.
