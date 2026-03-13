# Smart Class Check-in & Learning Reflection App

Flutter MVP for class attendance and participation reflection using QR scan + GPS + form input, with local storage and optional Firebase sync.

## Features

- Home navigation for check-in, finish class, and records view
- Check-in flow (before class):
	- Scan QR
	- Capture GPS
	- Input previous topic, expected topic, mood (1-5)
- Finish Class flow (after class):
	- Scan QR
	- Capture GPS
	- Input learned today + feedback
- Data persistence:
	- Local: `shared_preferences`
	- Cloud (optional): Firestore via Firebase
- Records screen showing local and Firebase records

## Tech Stack

- Flutter / Dart
- `mobile_scanner` for QR
- `geolocator` for location
- `shared_preferences` for local persistence
- `firebase_core` + `cloud_firestore` for cloud sync

## Project Structure

- `lib/screens/` UI screens
- `lib/services/storage_service.dart` local storage service
- `lib/services/firebase_service.dart` Firebase initialization + Firestore save/read
- `lib/firebase_options.dart` Firebase configuration from `.env` (web) or native config fallback
- `firebase.json` Firebase Hosting config
- `.firebaserc` Firebase project alias config
- `firestore.rules` Firestore rules used for exam demo

## Prerequisites

- Flutter SDK (3.3+ recommended)
- Dart SDK (included with Flutter)
- Android Studio / VS Code + device/emulator
- For Firebase sync:
	- Firebase project
	- Firestore enabled
	- Required variables (in `.env` for web):
		- `FIREBASE_API_KEY`
		- `FIREBASE_APP_ID`
		- `FIREBASE_MESSAGING_SENDER_ID`
		- `FIREBASE_PROJECT_ID`
	- Optional variables:
		- `FIREBASE_AUTH_DOMAIN`
		- `FIREBASE_STORAGE_BUCKET`
		- `FIREBASE_MEASUREMENT_ID`
		- `FIREBASE_IOS_BUNDLE_ID`

## Setup

1. Clone repository and enter project directory:

	 ```bash
	 cd smart_class_app
	 ```

2. Install dependencies:

	 ```bash
	 flutter pub get
	 ```

3. Configure `.firebaserc`:

	- Current default project is already set to `smartclass-6ecbc`.

4. Configure `.env` with your Firebase web values.

5. Run app (web example):

	```bash
	flutter run -d chrome --dart-define-from-file=.env
	```

## Run

1. Check connected devices:

	 ```bash
	 flutter devices
	 ```

2. Start app:

	 ```bash
	 flutter run
	 ```

For web, use:

```bash
flutter run -d chrome --dart-define-from-file=.env
```

## Validation / Quality

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Firebase Behavior Notes

- App always saves records locally first.
- App then attempts Firebase save:
	- If Firebase initializes successfully, data is saved to Firestore collections:
		- `checkins`
		- `finishes`
	- If Firebase is not configured, local save still works and UI shows fallback message.

## Firestore Collections

- `checkins`
- `finishes`

## Firebase Deployment (Exam Deliverable)

1. Build Flutter web with Firebase values:

```bash
flutter build web --dart-define-from-file=.env
```

2. Install Firebase CLI (if not already installed):

```bash
npm install -g firebase-tools
```

3. Login and deploy:

```bash
firebase login
firebase deploy --only firestore:rules,hosting
```

4. Submit generated Hosting URL.

- Firebase URL: `https://smartclass-6ecbc.web.app`

## AI Usage Report (Short)

- Tools used: GitHub Copilot / GPT-assisted coding workflow
- AI-assisted parts:
	- Flutter screen scaffolding
	- Service integration patterns (local + Firebase)
	- README structuring
- Manually implemented/adjusted:
	- Form validation logic
	- Data model fields for check-in/finish flows
	- Error/fallback behavior and records presentation
