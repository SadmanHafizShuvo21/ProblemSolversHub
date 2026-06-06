# Extending the Authentication System - Developer Guide

## How to Add New Auth Features

This guide explains how to extend the authentication system with new features following the existing architecture.

---

## Pattern: Adding a New Authentication Feature

### Example: Add "Remember Me" Feature

#### Step 1: Update Domain Layer

**File**: `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
abstract class AuthRepository {
  // ... existing methods ...
  
  /// Save authentication preference
  Future<void> saveRememberMe(bool remember);
  
  /// Get authentication preference
  Future<bool> shouldRememberMe();
}
```

#### Step 2: Update Data Layer

**File**: `lib/features/auth/data/datasources/firebase_auth_datasource.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseAuthDatasource {
  final _secureStorage = const FlutterSecureStorage();
  
  // ... existing code ...
  
  Future<void> saveRememberMe(bool remember) async {
    try {
      await _secureStorage.write(
        key: 'remember_me',
        value: remember.toString(),
      );
    } catch (e) {
      throw Exception('Failed to save preference: $e');
    }
  }
  
  Future<bool> shouldRememberMe() async {
    try {
      final value = await _secureStorage.read(key: 'remember_me');
      return value == 'true';
    } catch (e) {
      return false;
    }
  }
}
```

**File**: `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
class AuthRepositoryImpl implements AuthRepository {
  // ... existing code ...
  
  @override
  Future<void> saveRememberMe(bool remember) {
    return datasource.saveRememberMe(remember);
  }
  
  @override
  Future<bool> shouldRememberMe() {
    return datasource.shouldRememberMe();
  }
}
```

#### Step 3: Create Riverpod Provider

**File**: `lib/features/auth/presentation/providers/auth_providers.dart`

```dart
// Remember Me Notifier
class RememberMeNotifier extends StateNotifier<bool> {
  final AuthRepository repository;

  RememberMeNotifier(this.repository) : super(false) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    state = await repository.shouldRememberMe();
  }

  Future<void> setRememberMe(bool value) async {
    await repository.saveRememberMe(value);
    state = value;
  }
}

// Provider
final rememberMeProvider = StateNotifierProvider<RememberMeNotifier, bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RememberMeNotifier(repository);
});
```

#### Step 4: Use in UI

**File**: `lib/features/auth/presentation/screens/login_screen_new.dart`

```dart
class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rememberMe = ref.watch(rememberMeProvider);
    
    return CheckboxListTile(
      value: rememberMe,
      onChanged: (value) {
        if (value != null) {
          ref.read(rememberMeProvider.notifier).setRememberMe(value);
        }
      },
      title: const Text('Remember me'),
    );
  }
}
```

---

## Pattern: Adding Email Verification

### Step 1: Update Datasource

```dart
class FirebaseAuthDatasource {
  Future<void> sendEmailVerification(firebase_auth.User user) async {
    try {
      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }
  
  Future<bool> isEmailVerified(firebase_auth.User user) async {
    await user.reload();
    return user.emailVerified;
  }
}
```

### Step 2: Create Provider

```dart
final emailVerificationProvider = 
    FutureProvider.autoDispose<bool>((ref) async {
  final user = firebase_auth.FirebaseAuth.instance.currentUser;
  if (user == null) return false;
  
  await user.reload();
  return user.emailVerified;
});
```

### Step 3: Create Screen

```dart
class EmailVerificationScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailVerified = ref.watch(emailVerificationProvider);
    
    return Scaffold(
      body: Center(
        child: emailVerified.when(
          data: (isVerified) {
            if (isVerified) {
              return const Text('Email verified!');
            }
            return ElevatedButton(
              onPressed: () {
                // Send verification email
              },
              child: const Text('Verify Email'),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => const Text('Error'),
        ),
      ),
    );
  }
}
```

---

## Pattern: Adding Social Authentication (Facebook)

### Step 1: Add Dependency

```yaml
dependencies:
  flutter_facebook_auth: ^5.0.0
```

### Step 2: Create Usecase

```dart
class FacebookSigninUsecase {
  final AuthRepository repository;

  FacebookSigninUsecase(this.repository);

  Future<User> call() async {
    return repository.signInWithFacebook();
  }
}
```

### Step 3: Update Repository

```dart
abstract class AuthRepository {
  Future<User> signInWithFacebook();
}
```

### Step 4: Update Datasource

```dart
Future<UserModel> signInWithFacebook() async {
  try {
    final facebookAuth = FacebookAuth.instance;
    final result = await facebookAuth.login();
    
    if (result.status == LoginStatus.success) {
      final accessToken = result.accessToken;
      final credential = 
          facebook_auth.FacebookAuthProvider.credential(
            accessToken?.token ?? '',
          );
      
      final userCredential = 
          await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) throw Exception('Facebook sign-in failed');
      
      // Create/update user document
      return _createOrUpdateUser(user);
    }
    
    throw Exception('Facebook sign-in cancelled');
  } catch (e) {
    throw Exception('Facebook sign-in failed: $e');
  }
}

Future<UserModel> _createOrUpdateUser(firebase_auth.User user) async {
  // Implementation...
}
```

### Step 5: Create Provider

```dart
final facebookSignInProvider = 
    StateNotifierProvider<FacebookSignInNotifier, AsyncValue<User>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return FacebookSignInNotifier(repository);
});

class FacebookSignInNotifier extends StateNotifier<AsyncValue<User>> {
  final AuthRepository repository;

  FacebookSignInNotifier(this.repository) 
    : super(const AsyncValue.data(null));

  Future<void> signInWithFacebook() async {
    try {
      state = const AsyncValue.loading();
      final user = await repository.signInWithFacebook();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        st,
      );
    }
  }
}
```

### Step 6: Use in Login Screen

```dart
SizedBox(
  height: 56,
  child: OutlinedButton.icon(
    onPressed: () {
      ref.read(facebookSignInProvider.notifier).signInWithFacebook();
    },
    icon: const Icon(Icons.facebook),
    label: const Text('Continue with Facebook'),
  ),
)
```

---

## Pattern: Adding Two-Factor Authentication

### Step 1: Create 2FA Model

```dart
class TwoFactorModel {
  final String userId;
  final bool enabled;
  final List<String> backupCodes;
  final DateTime createdAt;

  TwoFactorModel({
    required this.userId,
    required this.enabled,
    required this.backupCodes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'enabled': enabled,
    'backupCodes': backupCodes,
    'createdAt': createdAt.toIso8601String(),
  };
}
```

### Step 2: Add Firestore Collection

```dart
// In datasource
Future<void> enable2FA() async {
  try {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('User not found');

    final backupCodes = _generateBackupCodes();
    
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('security')
        .doc('2fa')
        .set({
          'enabled': true,
          'backupCodes': backupCodes,
          'createdAt': DateTime.now().toIso8601String(),
        });
  } catch (e) {
    throw Exception('Failed to enable 2FA: $e');
  }
}

List<String> _generateBackupCodes() {
  return List.generate(
    10,
    (_) => Random().nextInt(100000).toString().padLeft(6, '0'),
  );
}
```

### Step 3: Update Firestore Rules

```javascript
// firestore.rules
match /users/{userId}/security/{document=**} {
  allow read: if isAuthenticated() && isOwner(userId);
  allow write: if isAuthenticated() && isOwner(userId);
}
```

---

## Common Extension Patterns

### Adding a New Provider State

```dart
// Pattern
final featureProvider = FutureProvider<MyData>((ref) async {
  final repository = ref.watch(repositoryProvider);
  return repository.fetchData();
});

// Or with StateNotifier
class MyNotifier extends StateNotifier<AsyncValue<MyData>> {
  final Repository repository;

  MyNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> doSomething() async {
    state = const AsyncValue.loading();
    try {
      final result = await repository.doSomething();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final myProvider = 
    StateNotifierProvider<MyNotifier, AsyncValue<MyData>>((ref) {
  final repository = ref.watch(repositoryProvider);
  return MyNotifier(repository);
});
```

### Adding a New Screen

```dart
// Pattern
class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({super.key});

  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use providers
    final data = ref.watch(myProvider);
    
    return Scaffold(
      body: data.when(
        data: (item) => Text(item.toString()),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
```

### Adding Validation

```dart
// Pattern
class CustomValidator {
  static void validate(String value, String fieldName) {
    if (value.isEmpty) {
      throw ValidationException.requiredField(fieldName);
    }
    if (value.length < 3) {
      throw ValidationException(
        message: '$fieldName must be at least 3 characters',
      );
    }
  }
}

// Use in Riverpod provider
Future<void> submitForm(String value) async {
  try {
    CustomValidator.validate(value, 'Field Name');
    // Process...
  } catch (e) {
    // Handle error
  }
}
```

---

## Testing New Features

### Unit Test Example

```dart
void main() {
  group('RememberMeNotifier', () {
    test('should save remember me preference', () async {
      // Arrange
      final mockRepository = MockAuthRepository();
      final notifier = RememberMeNotifier(mockRepository);

      // Act
      await notifier.setRememberMe(true);

      // Assert
      expect(notifier.state, true);
      verify(mockRepository.saveRememberMe(true)).called(1);
    });
  });
}
```

### Widget Test Example

```dart
void main() {
  testWidgets('RememberMe checkbox works', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ProblemSolversHubApp()),
    );

    expect(find.byType(CheckboxListTile), findsOneWidget);
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
  });
}
```

---

## Best Practices for Extensions

1. **Follow Existing Patterns** - Match the architecture style
2. **Keep Separation** - Domain/Data/Presentation layers
3. **Use Riverpod** - All state management via providers
4. **Validate Input** - Use ValidationUtils pattern
5. **Handle Errors** - Proper exception handling
6. **Document Code** - Add comments for clarity
7. **Test Thoroughly** - Unit and widget tests
8. **Update Rules** - Firestore rules for new data
9. **Update Docs** - Keep guides current
10. **Review Security** - Check for vulnerabilities

---

## Checklist for New Features

- [ ] Domain layer interfaces created
- [ ] Data layer implementation done
- [ ] Riverpod providers created
- [ ] UI screens implemented
- [ ] Error handling added
- [ ] Input validation added
- [ ] Firestore rules updated
- [ ] Documentation updated
- [ ] Unit tests written
- [ ] Widget tests written
- [ ] Multi-platform tested
- [ ] Security reviewed

---

## Common Mistakes to Avoid

❌ Don't access Firebase directly - use providers  
❌ Don't forget null safety - handle all nulls  
❌ Don't skip validation - validate all inputs  
❌ Don't ignore errors - handle all exceptions  
❌ Don't hardcode values - use constants  
❌ Don't forget tests - test all flows  
❌ Don't update rules - update Firestore rules  
❌ Don't mix layers - maintain separation  

---

## Resources

- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Firebase Security](https://firebase.google.com/docs/firestore/security)
- [Clean Architecture](https://resocoder.com/clean-architecture-tdd)

---

**Version**: 1.0.0  
**Last Updated**: May 26, 2026  
**For**: ProblemSolversHub Development Team
