# Student Records — Cloud Firestore

A Flutter app for adding and viewing student records stored in a Cloud
Firestore collection. Records include a student's name, registration number,
department, marks, and creation timestamp.

## Features

- Validates required student fields and marks from 0 to 100.
- Saves records to the Firestore `students` collection.
- Uses the uppercased registration number as the document ID.
- Shows records in real time, sorted by registration number.
- Displays Firestore read and write errors in the app.
- Includes Firestore-backed widget tests using an in-memory fake.

## Requirements

- Flutter SDK and Dart SDK `^3.13.7`.
- A Firebase project with Cloud Firestore enabled.
- A registered Firebase Web app for Chrome, or Android app for Android.
- Firestore security rules that authorize the app's reads and writes.

The app does not implement user authentication. Do not deploy rules that allow
unrestricted public access; configure authentication and suitable rules before
using this app with real student data.

## Configure Firebase

1. Create a Firebase project and enable Cloud Firestore.
2. Register a Web app and/or Android app in Firebase project settings.
3. Copy the configuration template:

   ```powershell
   Copy-Item firebase_config.example.json firebase_config.json
   ```

4. Fill `firebase_config.json` with the values from the Firebase app settings:
   - `FIREBASE_API_KEY`
   - `FIREBASE_MESSAGING_SENDER_ID`
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_WEB_APP_ID` for web
   - `FIREBASE_ANDROID_APP_ID` for Android
   - `FIREBASE_AUTH_DOMAIN` and `FIREBASE_STORAGE_BUCKET` when provided

`firebase_config.json` is ignored by Git. Firebase client configuration is
not a substitute for Firestore security rules; never put service-account
credentials or other server secrets in the Flutter app.

## Run

Install dependencies, then run with the local Firebase configuration:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=firebase_config.json
```

For Android:

```bash
flutter run -d <device-id> --dart-define-from-file=firebase_config.json
```

If Firebase configuration is missing for the selected platform, the app
displays setup guidance instead of attempting an unconfigured connection.

## Test and analyze

```bash
flutter test
flutter analyze
```

Tests use `fake_cloud_firestore`, so they do not need a live Firebase project
or network connection.

## Build

```bash
flutter build web --dart-define-from-file=firebase_config.json
flutter build apk --dart-define-from-file=firebase_config.json
```

See the [Flutter deployment guide](https://docs.flutter.dev/deployment) for
platform-specific setup.

## Firestore data model

Collection: `students`

Each document ID is the uppercase registration number and contains:

| Field | Type | Description |
| --- | --- | --- |
| `name` | String | Student name |
| `registrationNumber` | String | Uppercase registration number |
| `department` | String | Department |
| `marks` | Number | Mark from 0 to 100 |
| `createdAt` | Timestamp | Firestore server timestamp |

Saving a record with an existing registration number replaces that document.

## Project structure

```text
lib/
  main.dart             App UI and Firestore reads/writes
  firebase_options.dart Firebase options from compile-time configuration
firebase_config.example.json
                        Template for local Firebase configuration
test/
  widget_test.dart      Configuration, validation, and save tests
```
