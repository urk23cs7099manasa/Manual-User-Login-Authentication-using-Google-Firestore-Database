# Student Records — SQLite

A Flutter app for saving and viewing student records using a local SQLite
database. Each record contains a student's name, registration number,
department, and marks.

## Features

- Add student records with form validation.
- Restrict marks to values from 0 to 100.
- Persist records locally in SQLite.
- List saved records, newest first.
- Keep registration numbers unique.
- Use the `sqflite_common_ffi_web` SQLite implementation when running on web.

## Requirements

- Flutter SDK installed and configured.
- Dart SDK `^3.13.7` (see `pubspec.yaml`).
- For Android, an Android SDK/emulator or a connected device.
- For web, Chrome or another supported browser.

Check your Flutter setup with:

```bash
flutter doctor
```

## Run

Install dependencies and run on a connected device or emulator:

```bash
flutter pub get
flutter run
```

To run in Chrome:

```bash
dart run sqflite_common_ffi_web:setup --sqlite3-wasm-url=https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.5.2/sqlite3.wasm
flutter run -d chrome
```

The setup command generates the SQLite WebAssembly binary and shared worker
required by the web database implementation. The WASM URL is pinned to the
SQLite 3.5.2 version resolved in `pubspec.lock`; if that version changes,
update the URL to the matching SQLite release and rerun setup.

To list available targets:

```bash
flutter devices
```

## Test and analyze

```bash
flutter test
flutter analyze
```

Widget tests use `sqflite_common_ffi` to provide a local SQLite database
factory without requiring a device or emulator.

## Build

Build an Android APK or a web release:

```bash
flutter build apk
flutter build web
```

Other platforms may need additional SDKs and SQLite setup. See the
[Flutter deployment guide](https://docs.flutter.dev/deployment).

## Data and database

The app creates a `students` table with these columns:

| Column | Type | Details |
| --- | --- | --- |
| `id` | Integer | Auto-incrementing primary key |
| `name` | Text | Required |
| `regNo` | Text | Required and unique |
| `department` | Text | Required |
| `marks` | Real | Required; app accepts values from 0 to 100 |

On native platforms, the database is named `student_records.db`. The web
implementation uses `student_records_web.db`. Records are stored locally on
the device/browser and are not synchronized to a server.

## Project structure

```text
lib/
  main.dart             App UI, SQLite initialization, and record operations
test/
  widget_test.dart      Student form and required-field validation test
```
