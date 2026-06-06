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

/// Auth state stream provider - watches auth state changes
final authStateProvider = StreamProvider<dynamic>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// Auth status boolean provider
final authStatusProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user != null;
});
