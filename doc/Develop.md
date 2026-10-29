# How to set up the SDK for development

## Setup your local environment

Set up your local environment for developing a Flutter app by using their [guide](https://docs.flutter.dev/get-started/install).

Use Flutter 3.44.8 / Dart 3.12.2 for SDK development and code generation, as
CI does. The generator/test dependency graph requires newer SDK pins than the
runtime consumer minimum. Do not override Flutter's pinned dependencies to
make the development graph resolve on an older SDK.

To validate consumers, switch to Flutter 3.35.0 / Dart 3.9.0 and run
`dart tool/check_minimum_consumer.dart`. It creates a temporary consumer with
no overrides, checks the public widget API, configuration encoding and navigation
boundaries, and runs the Hive 2 upgrade fixture. The configuration cases execute
the generated JavaScript with Node.js 18 or newer.
It never launches the widget or contacts a Chatwoot installation.

## Clone the repository

Clone the [chatwoot-flutter-sdk](https://github.com/chatwoot/chatwoot-flutter-sdk) repository.

```bash
git clone git@github.com:chatwoot/chatwoot-flutter-sdk.git
```

## Run the example project for developing

Go to the example directory in the repository.

```
cd <path-to>/chatwoot-flutter-sdk/example
```

### Add the latest dependencies

```
flutter pub get
```

This command helps to add all the latest dependencies listed in the pubspec. yaml file.

### Integration guide

After the above steps, you can follow [how to use steps](https://github.com/chatwoot/chatwoot-flutter-sdk#3-how-to-use).

### Run the project

Use any of the methods mentioned below for running a sample project.

#### Run using terminal

```
flutter run
```

The example waits for an explicit website token before connecting. Run it with
your test inbox and instance:

```bash
flutter run --dart-define=CHATWOOT_WEBSITE_TOKEN=your-test-inbox-token \
  --dart-define=CHATWOOT_BASE_URL=https://your-test-instance.example
```

**NB:** If there is no device connected or the simulator is not open, this will open in your default browser.

#### Run using XCode or Android Studio (Tested with IOS only)

**IOS**

If you are using IOS, Open the XCode app in macOS and go to the ios directory in the example app.

```
cd user/chatwoot-flutter-sdk/example/ios
```

And try installing [cocoapods](https://cocoapods.org/) and then try to run build.

**Android**

If you are using Android, Open Android Studio and try build.

### Help

**NB:**
If you are facing ` Error: Member not found: 'packageRoot'.` while running flutter then try running the commands mentioned below.

```
flutter pub upgrade
```

or

```
flutter channel stable
flutter upgrade
flutter pub upgrade
```

### Ensure correctness

If you want to check the correctness of the code try running the commands below.

```
dart run build_runner clean
dart run build_runner build
node --test test/webview_widget/*.test.cjs
flutter test --concurrency=1
flutter analyze
dart pub publish --dry-run --ignore-warnings
```

The JavaScript bridge and generated-file regression tests use Node.js 18 or
newer and can run without Flutter. The package dry run does not publish or
upload a release. Confirm that its file list includes the generated `lib/`
parts, then test a consumer app before releasing. Review every warning; the
flag allows the expected dirty-source warning after code generation in CI.
The root `build.yaml` limits generation to SDK sources and tests so native
example plugin symlinks are not scanned as package source files.

Use Java 17 for the Android example. It pins NDK 28.2.13676358 to match the JNI
plugin and allows a 4 GiB Gradle heap for Flutter's native artifact transforms.
The root CI job compiles its debug APK. After `flutter pub get`, validate its
native builds separately from the root unit tests:

```bash
cd example
flutter build apk --debug
flutter build ios --no-codesign
```

On a test device or simulator, check initial widget loading, user/locale/custom
attributes, attachment selection/cancel/upload, and an upgrade retaining an
existing conversation. Use a non-production Chatwoot inbox for these checks.
