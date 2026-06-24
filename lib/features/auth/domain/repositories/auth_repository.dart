import 'dart:typed_data';

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

  /// Update the current user's profile
  Future<User> updateProfile({
    required String userId,
    required String displayName,
    String? photoUrl,
    String? bio,
    String? location,
    String? website,
    String? githubUsername,
    String? twitterUsername,
    String? leetcodeUsername,
    String? linkedinUsername,
    List<String>? skills,
    required String theme,
    required bool emailNotifications,
    required bool pushNotifications,
    required bool publicProfile,
  });

  /// Upload a profile image and return its public URL
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
  });

  /// Delete the current account
  Future<void> deleteAccount();

  /// Logout
  Future<void> logout();

  /// Check if user is logged in
  Stream<User?> authStateChanges();
}
