# IMPLEMENTATION GUIDE: Critical Fixes

This document provides step-by-step implementation instructions for fixing all critical and major issues identified in the technical review.

---

## FIX #1: Remove Firebase Keys & Implement Environment Variables

### Step 1: Rotate Firebase Keys Immediately

1. Go to Firebase Console: https://console.firebase.google.com
2. Navigate to Project Settings → Service Accounts
3. Generate new keys for all platforms
4. Update `firebase_options.dart` with NEW keys

### Step 2: Create .env File

Create `lib/.env` (do NOT commit):

```
FIREBASE_API_KEY=YOUR_NEW_API_KEY_HERE
FIREBASE_APP_ID=YOUR_NEW_APP_ID_HERE
FIREBASE_MESSAGING_SENDER_ID=YOUR_NEW_SENDER_ID_HERE
FIREBASE_PROJECT_ID=YOUR_PROJECT_ID
FIREBASE_AUTH_DOMAIN=YOUR_AUTH_DOMAIN
FIREBASE_STORAGE_BUCKET=YOUR_STORAGE_BUCKET
```

### Step 3: Update .gitignore

```bash
echo "lib/.env" >> .gitignore
echo "*.env" >> .gitignore
```

### Step 4: Add flutter_dotenv to pubspec.yaml

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

### Step 5: Update main.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: 'lib/.env');
  
  // ... rest of main
}
```

### Step 6: Create Secure Firebase Options

Replace `firebase_options.dart` with environment-based configuration:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
    final projectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
    final appId = dotenv.env['FIREBASE_APP_ID'] ?? '';
    final messagingSenderId = dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
    final authDomain = dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
    final storageBucket = dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: authDomain,
        storageBucket: storageBucket,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
        );
      // ... other platforms
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }
}
```

---

## FIX #2: Fix Router Redirect Race Condition

### Solution: Use AuthCheckScreen as Initial Route

Replace `lib/core/router/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/auth_check_screen.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/login_screen_new.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/signup_screen_new.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:problem_solvers_hub/ui/app.dart';

class AppRouter {
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: '/auth-check',
      // No redirect here - let AuthCheckScreen handle routing
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Page Not Found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/auth-check'),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      routes: [
        // Auth Check / Splash Screen (initial route)
        GoRoute(
          path: '/auth-check',
          builder: (context, state) => const AuthCheckScreen(),
        ),

        // Login Screen
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Signup Screen
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // Forgot Password Screen
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Home / Main App Screen (Protected)
        GoRoute(
          path: '/',
          builder: (context, state) => const AppShell(),
        ),
      ],
    );
  }
}

// Riverpod provider for the GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});
```

---

## FIX #3: Remove Service Locator & Adopt Riverpod

### Step 1: Create Comprehensive Riverpod Providers File

Create/replace `lib/core/providers/service_providers.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:problem_solvers_hub/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:problem_solvers_hub/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:problem_solvers_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/signup_usecase.dart';

// Firebase instances
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// Data Sources
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(firebaseAuthDataSourceProvider));
});

// Use Cases
final signupUsecaseProvider = Provider<SignupUsecase>((ref) {
  return SignupUsecase(ref.watch(authRepositoryProvider));
});

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
});

final googleSigninUsecaseProvider = Provider<GoogleSigninUsecase>((ref) {
  return GoogleSigninUsecase(ref.watch(authRepositoryProvider));
});

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  return LogoutUsecase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  return GetCurrentUserUsecase(ref.watch(authRepositoryProvider));
});
```

### Step 2: Delete service_locator.dart

```bash
rm lib/core/service_locator.dart
```

### Step 3: Update main.dart

Remove all service locator setup:

```dart
// REMOVE these lines:
// import 'package:problem_solvers_hub/core/service_locator.dart';
// 
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   setupServiceLocator(); // DELETE THIS LINE
//   
//   // ... rest of main
// }
```

### Step 4: Update pubspec.yaml

Remove unused get_it:

```yaml
# dev_dependencies:
#   get_it: ^7.6.4  # REMOVE THIS
```

---

## FIX #4: Consolidate State Management to Riverpod Only

### Step 1: Remove All BLoC References

```bash
# Remove BLoC files (but keep the logic, migrate to Riverpod)
rm -r lib/features/auth/presentation/bloc/
```

### Step 2: Create Riverpod Auth Notifier

Create `lib/features/auth/presentation/providers/auth_notifier.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:problem_solvers_hub/features/auth/domain/entities/user.dart';
import 'package:problem_solvers_hub/features/auth/domain/repositories/auth_repository.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/login_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/logout_usecase.dart';
import 'package:problem_solvers_hub/features/auth/domain/usecases/signup_usecase.dart';

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final SignupUsecase signupUsecase;
  final LoginUsecase loginUsecase;
  final GoogleSigninUsecase googleSigninUsecase;
  final LogoutUsecase logoutUsecase;
  final AuthRepository repository;

  AuthNotifier({
    required this.signupUsecase,
    required this.loginUsecase,
    required this.googleSigninUsecase,
    required this.logoutUsecase,
    required this.repository,
  }) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    state = await AsyncValue.guard(() => repository.getCurrentUser());
  }

  Future<void> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => signupUsecase(
      email: email,
      password: password,
      displayName: displayName,
    ));
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
      loginUsecase(email: email, password: password)
    );
  }

  Future<void> googleSignIn() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => googleSigninUsecase());
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await logoutUsecase();
      return null;
    });
  }
}

// Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(
    signupUsecase: ref.watch(signupUsecaseProvider),
    loginUsecase: ref.watch(loginUsecaseProvider),
    googleSigninUsecase: ref.watch(googleSigninUsecaseProvider),
    logoutUsecase: ref.watch(logoutUsecaseProvider),
    repository: ref.watch(authRepositoryProvider),
  );
});

// Convenience providers
final currentUserProvider = FutureProvider<User?>((ref) async {
  return ref.watch(authRepositoryProvider).getCurrentUser();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
```

### Step 3: Update pubspec.yaml

Remove flutter_bloc:

```yaml
# Remove these lines:
# flutter_bloc: ^8.1.5
# equatable: ^2.0.5
```

---

## FIX #5: Add Comprehensive Error Handling

### Create Error Types

Create `lib/core/errors/exceptions.dart`:

```dart
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException({required String message, String? code})
      : super(message: message, code: code);
}

class FirestoreException extends AppException {
  FirestoreException({required String message, String? code})
      : super(message: message, code: code);
}

class NetworkException extends AppException {
  NetworkException({required String message, String? code})
      : super(message: message, code: code);
}

class ValidationException extends AppException {
  ValidationException({required String message, String? code})
      : super(message: message, code: code);
}
```

---

## FIX #6: Complete Missing Riverpod Providers

Complete `lib/features/auth/presentation/providers/auth_providers.dart`:

```dart
// Add missing providers
final logoutProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  await repository.logout();
});

final googleSignInProvider = FutureProvider<User?>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.signInWithGoogle();
});
```

---

## Implementation Checklist

- [ ] FIX #1: Firebase keys removed and regenerated
- [ ] FIX #2: Router fixed with AuthCheckScreen
- [ ] FIX #3: Service locator removed
- [ ] FIX #4: BLoC removed, migrated to Riverpod
- [ ] FIX #5: Error handling implemented
- [ ] FIX #6: Riverpod providers completed
- [ ] All tests passing
- [ ] App runs without errors
- [ ] Navigation working correctly
- [ ] Authentication flow working
- [ ] Code analysis clean (flutter analyze)

---

## Verification Commands

```bash
# Check for errors
flutter analyze

# Format code
dart format .

# Run app
flutter run

# Run tests (if available)
flutter test
```

---

**END OF IMPLEMENTATION GUIDE**
