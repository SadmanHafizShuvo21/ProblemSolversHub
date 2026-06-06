# ProblemSolversHub

[![Flutter](https://img.shields.io/badge/flutter-%2302569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue)](#)

ProblemSolversHub is a Flutter application for creating, sharing and
discovering problem-solving posts. It includes authentication, a feed,
post creation, and integrations with Firebase for backend services.

## Features

- User authentication (email / social providers)
- Create, edit and view posts
- Feed of posts with basic sorting/refresh
- Firebase integration (Auth, Firestore, Storage, Analytics)
- Platform support: Android, iOS, Linux, macOS, Windows, Web

## Architecture & Conventions

- Modular `features/` directory (e.g. `auth`, `create`, `feed`, `post`, `posts`)
- `core/` contains app-wide utilities (`service_locator.dart`, theme, etc.)
- `shared/` holds common models and helpers used across features
- Dependency injection via the service locator in `lib/core/service_locator.dart`

## Project Structure (important folders)

- `lib/` — main Dart source
  - `core/` — app core (DI, theme)
  - `features/` — feature modules (auth, create, feed, post, posts)
  - `shared/` — shared models and utilities
  - `ui/` — app entry `app.dart`, screens and widgets
- `assets/`, `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/` — platform folders

There are several repository notes to help with configuration:

- Firebase setup: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- Authentication notes: [AUTH_QUICK_REFERENCE.md](AUTH_QUICK_REFERENCE.md)
- Auth implementation details: [AUTH_IMPLEMENTATION.md](AUTH_IMPLEMENTATION.md)
- Navigation guidance: [NAVIGATION_UPDATE.md](NAVIGATION_UPDATE.md)

## Prerequisites

- Flutter SDK (stable). See https://docs.flutter.dev/get-started/install
- Dart (bundled with Flutter)
- Firebase CLI (for local emulators and project setup)

## Developer Quickstart

These steps get a developer up and running quickly for local development.

1. Ensure you have Flutter installed and on `PATH`.

```bash
flutter --version
flutter pub get
```

2. Start Firebase emulators (if using Firestore/Functions locally):

```bash
firebase emulators:start --only firestore,auth
```

3. Run the app on your preferred device/emulator:

```bash
flutter run
```

4. Useful dev commands:

```bash
flutter analyze
flutter test
flutter format .
```

## Local setup

1. Clone the repository

```bash
git clone <repo-url>
cd ProblemSolversHub
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure Firebase

This project includes `firebase_options.dart` and `google-services.json` as
examples. Follow [FIREBASE_SETUP.md](FIREBASE_SETUP.md) to register your
Firebase project, generate platform configuration files and place them in
the appropriate platform folders.

## Run the app

Run on a connected device or emulator:

```bash
flutter run
```

To run for a specific platform (Android example):

```bash
flutter run -d android
```

## Build

Android APK:

```bash
flutter build apk --release
```

iOS (macOS machine required):

```bash
flutter build ios --release
```

## Tests & Analysis

Run unit/widget tests:

```bash
flutter test
```

Analyze the project:

```bash
flutter analyze
```

Format code:

```bash
flutter format .
```

## Contributing

- Please open issues or pull requests for bugs and feature requests.
- Follow the existing code style and run `flutter analyze` and
  `flutter test` before submitting PRs.

If you need to change Firebase configuration or authentication flows, start
by reading [FIREBASE_SETUP.md](FIREBASE_SETUP.md) and
[AUTH_IMPLEMENTATION.md](AUTH_IMPLEMENTATION.md).

## Useful Links

- Flutter docs: https://docs.flutter.dev/
- Firebase docs: https://firebase.google.com/docs

---

If you'd like, I can also:

- add badges (build, coverage)
- generate a short developer quickstart section
- update other markdown docs with cross-links
