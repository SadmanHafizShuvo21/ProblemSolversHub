import '../entities/user.dart';

abstract class AuthRepository {
  /// Sign up with email and password
  Future<User> signup({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login with email and password
  Future<User> login({required String email, required String password});

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Get current logged-in user
  Future<User?> getCurrentUser();

  /// Logout
  Future<void> logout();

  /// Check if user is logged in
  Stream<User?> authStateChanges();
}
