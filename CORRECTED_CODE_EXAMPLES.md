# Corrected Code Examples - Ready to Use

This file contains complete, corrected code for all the major files that need to be updated.

---

## 1. Corrected main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:problem_solvers_hub/ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: 'lib/.env');
  } catch (e) {
    debugPrint('⚠️  Warning: .env file not found: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization error: $e');
    
    // Show error to user instead of crashing
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Initialization Error'),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Failed to initialize app: $e',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(
    const ProviderScope(
      child: ProblemSolversHubApp(),
    ),
  );
}
```

---

## 2. Corrected app_router.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/auth_check_screen.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/login_screen_new.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/signup_screen_new.dart';
import 'package:problem_solvers_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:problem_solvers_hub/ui/app.dart';

/// Application Router Configuration
class AppRouter {
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      // Start with auth check screen
      initialLocation: '/auth-check',
      
      // No redirect at root level - AuthCheckScreen handles routing
      redirect: (context, state) {
        // Router-level redirect can be null
        // Navigation is handled by AuthCheckScreen
        return null;
      },
      
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
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
          name: 'auth-check',
          builder: (context, state) => const AuthCheckScreen(),
        ),

        // Login Screen
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Signup Screen
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // Forgot Password Screen
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Home / Main App Screen (Protected)
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const AppShell(),
        ),
      ],
    );
  }
}

/// Riverpod provider for the GoRouter
final goRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});
```

---

## 3. Corrected Firebase Auth DataSource

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Custom exception for auth errors
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Firebase Authentication Data Source
class FirebaseAuthDatasource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  static const String _usersCollection = 'users';

  FirebaseAuthDatasource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Sign up with email and password
  Future<UserModel> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('User creation failed');
      }

      // Update display name
      await user.updateDisplayName(displayName);
      await user.reload();

      // Create user model
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Signup failed: $e');
    }
  }

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Login failed');
      }

      // Fetch user data from Firestore
      final userModel = await _getUserFromFirestore(user.uid);
      if (userModel == null) {
        throw AuthException('User data not found');
      }

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: $e');
    }
  }

  /// Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign-in cancelled by user');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Google sign-in failed');
      }

      // Check if user exists in Firestore
      var userModel = await _getUserFromFirestore(user.uid);

      if (userModel == null) {
        // Create new user document
        userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .set(userModel.toJson());
      }

      return userModel;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google sign-in failed: $e');
    }
  }

  /// Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return _getUserFromFirestore(user.uid);
    } catch (e) {
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Logout failed: $e');
    }
  }

  /// Stream of auth state changes
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        return await _getUserFromFirestore(firebaseUser.uid);
      } catch (e) {
        return null;
      }
    });
  }

  /// Helper: Get user from Firestore
  Future<UserModel?> _getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  AuthException _handleAuthException(firebase_auth.FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => AuthException(
        'No account found with this email address',
        code: 'user-not-found',
      ),
      'wrong-password' => AuthException(
        'The password you entered is incorrect',
        code: 'wrong-password',
      ),
      'invalid-email' => AuthException(
        'Please enter a valid email address',
        code: 'invalid-email',
      ),
      'user-disabled' => AuthException(
        'This account has been disabled',
        code: 'user-disabled',
      ),
      'email-already-in-use' => AuthException(
        'This email is already registered',
        code: 'email-already-in-use',
      ),
      'weak-password' => AuthException(
        'Password must be at least 6 characters',
        code: 'weak-password',
      ),
      'operation-not-allowed' => AuthException(
        'This operation is not allowed',
        code: 'operation-not-allowed',
      ),
      'too-many-requests' => AuthException(
        'Too many login attempts. Please try again later',
        code: 'too-many-requests',
      ),
      'network-request-failed' => AuthException(
        'Network error. Please check your connection',
        code: 'network-request-failed',
      ),
      _ => AuthException(
        e.message ?? 'Authentication failed',
        code: e.code,
      ),
    };
  }
}
```

---

## 4. Corrected service_providers.dart

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

// ==================== Firebase Instances ====================

/// Firebase Authentication instance
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

/// Firestore instance
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Google Sign-In instance
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

// ==================== Data Sources ====================

/// Firebase Authentication Data Source
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

// ==================== Repositories ====================

/// Authentication Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(datasource);
});

// ==================== Use Cases ====================

/// Sign up use case
final signupUsecaseProvider = Provider<SignupUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupUsecase(repository);
});

/// Login use case
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUsecase(repository);
});

/// Google sign in use case
final googleSigninUsecaseProvider = Provider<GoogleSigninUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GoogleSigninUsecase(repository);
});

/// Logout use case
final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUsecase(repository);
});

/// Get current user use case
final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUsecase(repository);
});

// ==================== State Providers ====================

/// Current user future provider
final currentUserProvider = FutureProvider<dynamic>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});

/// Auth state stream provider
final authStateProvider = StreamProvider<dynamic>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Auth status boolean provider
final authStatusProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user != null;
});
```

---

## 5. Corrected pubspec.yaml

```yaml
name: problem_solvers_hub
description: "A new Flutter project."
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  
  # Routing
  go_router: ^17.2.1
  
  # Firebase
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.1.0
  firebase_storage: ^12.1.0
  firebase_analytics: ^11.1.0
  google_sign_in: ^6.2.1
  
  # State Management (Riverpod only)
  flutter_riverpod: ^2.4.0
  riverpod: ^2.4.0
  
  # Environment variables
  flutter_dotenv: ^5.1.0
  
  # Utilities
  intl: ^0.19.0
  validators: ^3.0.0
  connectivity_plus: ^5.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0

flutter:
  uses-material-design: true
```

---

## 6. Updated .gitignore

Add to your `.gitignore`:

```
# Environment variables
.env
lib/.env
*.env

# Firebase
google-services.json
GoogleService-Info.plist

# Secrets
.env.*.local

# Build
build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
```

---

## 7. Example Login Screen Using Riverpod

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:problem_solvers_hub/core/extensions/validation_extension.dart';
import 'package:problem_solvers_hub/core/providers/service_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final loginUsecase = ref.read(loginUsecaseProvider);
    
    try {
      final user = await loginUsecase(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted && user != null) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Text(
                'ProblemSolvers Hub',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Solve Problems, Share Solutions',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 60),
              
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!value!.isValidEmail()) return 'Invalid email format';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Password is required';
                  if (value!.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              
              // Signup Link
              TextButton(
                onPressed: () => context.go('/signup'),
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 8. Validation Extension

Create `lib/core/extensions/validation_extension.dart`:

```dart
extension StringValidation on String {
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(this);
  }

  bool isStrongPassword() {
    return length >= 8 &&
        contains(RegExp(r'[A-Z]')) &&
        contains(RegExp(r'[0-9]')) &&
        contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool isValidURL() {
    try {
      Uri.parse(this);
      return startsWith('http://') || startsWith('https://');
    } catch (e) {
      return false;
    }
  }
}
```

---

## Usage Notes

1. **Update imports** in all files after migration
2. **Run `flutter pub get`** to fetch dependencies
3. **Run `flutter analyze`** to check for errors
4. **Run `flutter run`** to test the app

---

**END OF CORRECTED CODE EXAMPLES**
