# How to set up the SDK for development

## Setup your local environment

Set up your local environment for developing a Flutter app by using their [guide](https://docs.flutter.dev/get-started/install).

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
flutter pub run build_runner clean
flutter pub run build_runner--delete-conflicting-outputs
flutter test
flutter analyze
```
