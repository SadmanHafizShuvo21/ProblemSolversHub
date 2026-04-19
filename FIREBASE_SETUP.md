# Firebase Authentication Setup Guide

This document provides step-by-step instructions to set up Firebase Authentication for the ProblemSolvers Hub app.

## Overview

The app implements Firebase Authentication with the following features:
- Email & Password Sign Up
- Email & Password Login
- Google Sign-In
- Logout functionality
- User data persistence in Firestore
- Auth state management with BLoC

## Prerequisites

1. Flutter SDK installed (v3.9.2 or higher)
2. Firebase CLI installed: `npm install -g firebase-tools`
3. A Google Cloud Platform (GCP) account

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter your project name (e.g., `problem-solvers-hub`)
4. Accept the terms and click "Create project"
5. Wait for the project to be created
6. Click "Continue"

## Step 2: Set Up Firebase Authentication

### Enable Email/Password Authentication
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Email/Password** provider
3. Enable both:
   - ☑ Email/Password
   - ☑ Email link (passwordless sign-in) [Optional]
4. Click "Save"

### Enable Google Sign-In
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Google**
3. Toggle to enable it
4. Select the project support email
5. Click "Save"

### (Optional) Enable Other Providers
You can also enable:
- Facebook
- GitHub
- Twitter/X
- Apple Sign-In (iOS)
- Microsoft

## Step 3: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose your region (select closest to your users)
4. Start in **Test mode** (for development)
   - Read/write allowed for all documents
   - **Important**: Change to production mode before deploying to production
5. Click "Enable"

### Create Firestore Rules (Production)

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - only users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Posts collection - authenticated users can read all, write their own
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.authorId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.authorId == request.auth.uid;
    }
    
    // Comments collection
    match /posts/{postId}/comments/{commentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.authorId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.authorId == request.auth.uid;
    }
  }
}
```

## Step 4: Configure Flutter Fire CLI

1. Install the CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Run the configuration wizard:
   ```bash
   cd "c:\Users\Sadman\Desktop\ProblemSolver Hub"
   flutterfire configure
   ```

3. When prompted:
   - Select your Firebase project
   - Select the platforms you want to configure (Windows, Android, iOS, Web, macOS)
   - The tool will generate `firebase_options.dart` with your credentials

## Step 5: Configure Google Sign-In

### For Android:

1. In Firebase Console, go to **Project Settings** → **Service Accounts**
2. Click "Generate New Private Key" and save the JSON file
3. Copy the `client_id` from the downloaded JSON file

### For iOS:

1. In Firebase Console, go to **Project Settings**
2. Under iOS apps, find your app and click the Config button
3. Download the `GoogleService-Info.plist` file
4. In Xcode, add it to the project

### For Web:

1. Google Sign-In is configured via Firebase Console
2. Add authorized domains:
   - Go to **Authentication** → **Settings** → **Authorized domains**
   - Add your domain (e.g., `localhost:3000` for local testing)

### For Windows:

1. Google Sign-In requires OAuth 2.0 credentials
2. Go to [Google Cloud Console](https://console.cloud.google.com/)
3. Create OAuth 2.0 Desktop credentials
4. Note: This is optional for development

## Step 6: Update firebase_options.dart

After running `flutterfire configure`, the file `lib/firebase_options.dart` will be automatically updated with your credentials. **Do not manually edit this file unless necessary.**

If you need to manually add credentials:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'your-project-id',
  databaseURL: 'https://your-project-id.firebaseio.com',
  storageBucket: 'your-project-id.appspot.com',
);
```

## Step 7: Install Dependencies

```bash
flutter pub get
```

## Step 8: Test the App

```bash
flutter run -d windows
# or
flutter run -d android
# or
flutter run -d ios
```

### Testing Flows:

1. **Sign Up Flow**:
   - Navigate to Sign Up screen
   - Enter email, display name, and password
   - Verify user is created in Firestore

2. **Login Flow**:
   - Navigate to Login screen
   - Enter registered email and password
   - Verify redirect to Feed screen

3. **Google Sign-In**:
   - Click "Sign in with Google" button
   - Complete Google authentication
   - Verify user is created/logged in

4. **Logout**:
   - From Feed screen, access settings/profile
   - Click logout
   - Verify redirect to Login screen

## Step 9: Environment Variables (Optional but Recommended)

Create a `.env` file in your project root:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
```

Then load it in your app using `flutter_dotenv` package.

## Troubleshooting

### Error: "Firebase app not initialized"
- Ensure `Firebase.initializeApp()` is called in `main()` with `WidgetsFlutterBinding.ensureInitialized()`
- Check that `firebase_options.dart` has correct credentials

### Error: "Google Sign-In failed"
- Verify Google Sign-In is enabled in Firebase Console
- Check that Google credentials are properly configured
- For Android: Ensure SHA-1 fingerprint is added to Firebase

### Error: "Permission denied" on Firestore
- Check Firestore rules
- Ensure user is authenticated before accessing Firestore
- In development, temporarily use test mode

### Error: "User not found" or "Wrong password"
- Verify the user exists in Firebase Authentication
- Check email/password are correct
- Use Firebase Console to reset password if needed

## Security Best Practices

1. **Never commit credentials**:
   - Add `firebase_options.dart` to `.gitignore` in production
   - Use environment variables for sensitive data

2. **Enable Production Firestore Rules**:
   - Restrict access to authenticated users only
   - Use user IDs for authorization

3. **Use HTTPS for all communications**
   - Firebase automatically uses HTTPS

4. **Implement Email Verification**:
   ```dart
   await FirebaseAuth.instance.currentUser?.sendEmailVerification();
   ```

5. **Implement Password Reset**:
   ```dart
   await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
   ```

6. **Enable Multi-Factor Authentication (MFA)**:
   - Consider implementing MFA for production apps

7. **Sanitize User Input**:
   - Validate email format
   - Enforce strong password requirements
   - Prevent injection attacks

## Project Structure

```
lib/
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── firebase_auth_datasource.dart
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── usecases/
│       │       ├── signup_usecase.dart
│       │       ├── login_usecase.dart
│       │       ├── google_signin_usecase.dart
│       │       ├── logout_usecase.dart
│       │       └── get_current_user_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── auth_bloc.dart
│           │   ├── auth_event.dart
│           │   └── auth_state.dart
│           └── screens/
│               ├── login_screen.dart
│               └── signup_screen.dart
├── core/
│   └── service_locator.dart
└── firebase_options.dart
```

## Next Steps

1. Complete the Firebase setup following this guide
2. Run `flutterfire configure` to generate credentials
3. Update Firestore rules for production
4. Test all authentication flows
5. Implement email verification (optional)
6. Implement password reset (optional)
7. Consider implementing profile management features

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Authentication Best Practices](https://firebase.google.com/docs/auth/best-practices)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)

## Support

For issues or questions:
1. Check [FlutterFire GitHub Issues](https://github.com/firebase/flutterfire/issues)
2. Review [Firebase Documentation](https://firebase.google.com/docs)
3. Check Flutter community forums or Stack Overflow
