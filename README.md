# Student Performance App

A Flutter app for entering a student's name, registration number, and three
subject marks. It validates the form, navigates to a result screen, and
displays the total, average, and percentage.

## Features

- Validates that student details are provided.
- Restricts each subject mark to a number from 0 to 100.
- Navigates between the student form and result screens using named routes.
- Calculates total marks, average, and percentage.
- Allows returning to the form from the result screen.

## Requirements

- Flutter SDK installed and configured. The project requires Dart SDK
  `^3.13.7`, as specified in `pubspec.yaml`.
- A connected device, emulator, or supported desktop/browser target.

Check the Flutter installation with:

```bash
flutter doctor
```

## Run the app

From the project directory:

```bash
flutter pub get
flutter run
```

To select a particular connected device:

```bash
flutter devices
flutter run -d <device-id>
```

## Test and analyze

```bash
flutter test
flutter analyze
```

## Build

For example, build an Android APK or web release:

```bash
flutter build apk
flutter build web
```

Other targets may require additional platform SDKs and setup. See the
[Flutter deployment guide](https://docs.flutter.dev/deployment).

## Project structure

```text
lib/
  main.dart             App entry point and named-route configuration
  home_screen.dart      Student details form and validation
  second_screen.dart    Student results screen
  user_data_model.dart  Student data and result calculations
test/
  widget_test.dart      Form-to-results navigation widget test
```

The app's routes are configured in `lib/main.dart`. The student form,
calculation model, and result display are in the corresponding files listed
above.
