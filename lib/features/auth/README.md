# Auth Feature Documentation

## Overview

The Auth feature implements Firebase Authentication with a Clean Architecture approach, providing email/password authentication, Google Sign-In, and user session management.

## Architecture

The feature follows Clean Architecture principles with three layers:

### 1. Domain Layer (`domain/`)

The domain layer contains business logic and abstractions:

- **Entities**: Core business objects
  - `User`: Represents an authenticated user with basic profile information

- **Repositories**: Abstract contracts
  - `AuthRepository`: Defines authentication operations interface

- **Use Cases**: Business logic operations
  - `SignupUsecase`: Register new user with email/password
  - `LoginUsecase`: Login existing user with credentials
  - `GoogleSigninUsecase`: Google Sign-In flow
  - `LogoutUsecase`: Logout and clear session
  - `GetCurrentUserUsecase`: Stream auth state changes

### 2. Data Layer (`data/`)

The data layer handles external data sources:

- **Models**: Data representations
  - `UserModel`: Extends `User` entity with JSON serialization for Firestore

- **Datasources**: External service abstraction
  - `FirebaseAuthDatasource`: Firebase Authentication and Firestore integration
    - Sign up with email/password
    - Login with credentials
    - Google Sign-In
    - Logout
    - Auth state stream
    - Error handling

- **Repositories**: Implementation of domain repository contracts
  - `AuthRepositoryImpl`: Implements `AuthRepository` using `FirebaseAuthDatasource`

### 3. Presentation Layer (`presentation/`)

The presentation layer handles UI and state management:

- **BLoC**: State management
  - `AuthBloc`: Manages authentication state and events
  - `AuthEvent`: User actions (signup, login, Google sign-in, logout, status check)
  - `AuthState`: State representations (initial, loading, authenticated, unauthenticated, error)

- **Screens**: UI pages
  - `LoginScreen`: Email/password login and Google Sign-In
  - `SignupScreen`: User registration with email/password
  - Both screens include form validation and error handling

## File Structure

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── firebase_auth_datasource.dart        # Firebase operations
│   ├── models/
│   │   └── user_model.dart                      # Serializable user model
│   └── repositories/
│       └── auth_repository_impl.dart            # Repository implementation
├── domain/
│   ├── entities/
│   │   └── user.dart                            # User business entity
│   ├── repositories/
│   │   └── auth_repository.dart                 # Repository interface
│   └── usecases/
│       ├── signup_usecase.dart
│       ├── login_usecase.dart
│       ├── google_signin_usecase.dart
│       ├── logout_usecase.dart
│       └── get_current_user_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart                       # BLoC state management
    │   ├── auth_event.dart                      # Events
    │   └── auth_state.dart                      # States
    └── screens/
        ├── login_screen.dart
        └── signup_screen.dart
```

## Data Flow

### Sign Up Flow

```
SignupScreen (User Input)
    ↓
AuthSignupEvent (triggered via BLoC)
    ↓
AuthBloc._onAuthSignup
    ↓
SignupUsecase (Business Logic)
    ↓
AuthRepository.signup (Contract)
    ↓
AuthRepositoryImpl.signup (Implementation)
    ↓
FirebaseAuthDatasource.signup
    ├─ Firebase Auth: Create user
    ├─ Firestore: Store user document
    └─ Return UserModel
    ↓
AuthAuthenticated State (Success)
    ↓
Redirect to Feed (via main.dart router)
```

### Login Flow

```
LoginScreen (User Input)
    ↓
AuthLoginEvent (triggered via BLoC)
    ↓
AuthBloc._onAuthLogin
    ↓
LoginUsecase (Business Logic)
    ↓
AuthRepository.login (Contract)
    ↓
AuthRepositoryImpl.login (Implementation)
    ↓
FirebaseAuthDatasource.login
    ├─ Firebase Auth: Sign in
    ├─ Firestore: Fetch user document
    └─ Return UserModel
    ↓
AuthAuthenticated State (Success)
    ↓
Redirect to Feed (via main.dart router)
```

### Google Sign-In Flow

```
LoginScreen/SignupScreen (Google Button)
    ↓
AuthGoogleSigninEvent (triggered via BLoC)
    ↓
AuthBloc._onAuthGoogleSignin
    ↓
GoogleSigninUsecase (Business Logic)
    ↓
AuthRepository.signInWithGoogle (Contract)
    ↓
AuthRepositoryImpl.signInWithGoogle (Implementation)
    ↓
FirebaseAuthDatasource.signInWithGoogle
    ├─ Google Sign-In: Get credentials
    ├─ Firebase Auth: Sign in with credential
    ├─ Firestore: Create/fetch user document
    └─ Return UserModel
    ↓
AuthAuthenticated State (Success)
    ↓
Redirect to Feed (via main.dart router)
```

### Auth State Listener

```
App Startup (main.dart)
    ↓
AuthBloc._setupAuthStateListener
    ↓
GetCurrentUserUsecase.call() (Stream)
    ↓
FirebaseAuthDatasource.authStateChanges() (Stream)
    ↓
Firebase Auth State Changes
    ├─ User found → AuthAuthenticated (emit)
    └─ No user → AuthUnauthenticated (emit)
    ↓
Router Redirect (based on auth state)
    ├─ Authenticated → Feed screen
    └─ Unauthenticated → Login screen
```

## Key Features

### 1. Form Validation

**Login Screen**:
- Email format validation
- Password minimum length (6 characters)

**Signup Screen**:
- Display name length (minimum 2 characters)
- Email format validation
- Password strength (minimum 6 characters)
- Password confirmation matching

### 2. Error Handling

Firebase Auth Exceptions are mapped to user-friendly messages:
- `user-not-found`: "No user found with this email"
- `wrong-password`: "Wrong password provided"
- `invalid-email`: "Invalid email format"
- `email-already-in-use`: "Email is already registered"
- `weak-password`: "Password is too weak"
- `user-disabled`: "User account has been disabled"

### 3. Auth State Management

The app maintains auth state through:
- **AuthBloc**: Centralized state management using BLoC pattern
- **Listener Pattern**: Real-time auth state changes via Firebase
- **Router Integration**: Automatic redirection based on auth state

### 4. User Data Persistence

User data is stored in Firestore with the following structure:

```json
{
  "id": "uid123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "photoUrl": "https://...",
  "createdAt": "2024-04-18T10:30:00Z"
}
```

### 5. Security Features

- Password visibility toggle
- Secure password storage (Firebase Auth)
- User data privacy (Firestore rules)
- Session management
- Logout clears all data

## Dependency Injection

The app uses `get_it` for service locator pattern:

```dart
// In service_locator.dart
getIt.registerSingleton<FirebaseAuthDatasource>(...)
getIt.registerSingleton<AuthRepository>(...)
getIt.registerSingleton<SignupUsecase>(...)
getIt.registerSingleton<AuthBloc>(...)
```

## BLoC Events & States

### Events

- `AuthCheckStatusEvent`: Check current auth status on app startup
- `AuthSignupEvent(email, password, displayName)`: Register new user
- `AuthLoginEvent(email, password)`: Login existing user
- `AuthGoogleSigninEvent()`: Google Sign-In
- `AuthLogoutEvent()`: Logout and clear session

### States

- `AuthInitial`: Initial state
- `AuthLoading`: Loading state (during auth operation)
- `AuthAuthenticated(user)`: User is logged in
- `AuthUnauthenticated`: User is logged out
- `AuthError(message)`: Error occurred

## Integration with Main App

### 1. Router Setup

The main app router integrates auth state:

```dart
GoRouter(
  redirect: (context, state) {
    final isAuthenticated = authState is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/signup';
    
    // Redirect logic
    if (!isAuthenticated && !isAuthRoute) return '/login';
    if (isAuthenticated && isAuthRoute) return '/';
    return null;
  },
  routes: [...]
)
```

### 2. Routes

- `/login` → LoginScreen
- `/signup` → SignupScreen
- `/` → FeedScreen (protected)
- `/post` → PostDetailScreen (protected)
- `/create` → CreatePostPage (protected)

### 3. Logout Integration

The FeedScreen includes a logout option:

```dart
PopupMenuButton(
  onSelected: (value) {
    if (value == 'logout') {
      context.read<AuthBloc>().add(const AuthLogoutEvent());
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(value: 'logout', child: Text('Logout')),
  ]
)
```

## Testing Guide

### Manual Testing

1. **Sign Up**:
   - Enter valid email, display name, and matching passwords
   - Verify redirect to Feed screen
   - Check Firestore for user document

2. **Login**:
   - Logout from Feed screen
   - Enter registered email and password
   - Verify redirect to Feed screen

3. **Google Sign-In**:
   - Click "Sign in with Google"
   - Complete Google authentication
   - Verify redirect and user data in Firestore

4. **Error Handling**:
   - Test with invalid email format
   - Try weak password
   - Use non-existent email for login
   - Verify error messages display correctly

### Unit Testing (To be implemented)

```dart
// Example test structure
group('AuthBloc', () {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(
      signupUsecase: SignupUsecase(mockAuthRepository),
      // ...
    );
  });

  test('emit [AuthLoading, AuthAuthenticated] when signup succeeds', () {
    // Test implementation
  });
});
```

## Next Steps

1. **Email Verification**: Implement email verification flow
2. **Password Reset**: Add forgot password functionality
3. **Profile Management**: Allow users to update their profile
4. **Multi-Factor Authentication (MFA)**: Add phone/authenticator MFA
5. **Social Media Linking**: Allow linking multiple auth providers
6. **Anonymous Authentication**: Allow anonymous user creation
7. **User Search**: Find and follow other users
8. **Session Management**: Handle session expiration and refresh

## Troubleshooting

### Firebase Initialization Issues

- Ensure `firebase_options.dart` is properly configured
- Check that `Firebase.initializeApp()` is called before running the app
- Verify Flutter SDK is up to date

### Google Sign-In Issues

- Verify Google Sign-In is enabled in Firebase Console
- Check OAuth configuration for your platform
- For Android: Verify SHA-1 fingerprint is registered
- For iOS: Check GoogleService-Info.plist is included

### Firestore Permission Errors

- Check Firestore rules configuration
- Ensure user is authenticated before accessing Firestore
- Verify user ID matches authorization checks in rules

### State Management Issues

- Ensure AuthBloc is provided at the top level with BlocProvider
- Check that all events are properly defined in auth_event.dart
- Verify states are emitted correctly in BLoC handlers

## References

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://resocoder.com/clean-architecture)
