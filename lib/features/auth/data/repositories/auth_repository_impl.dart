import 'dart:typed_data';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<User> signup({
    required String email,
    required String password,
    required String displayName,
  }) {
    return datasource.signup(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  @override
  Future<User> login({required String email, required String password}) {
    return datasource.login(email: email, password: password);
  }

  @override
  Future<User> signInWithGoogle() {
    return datasource.signInWithGoogle();
  }

  @override
  Future<User?> getCurrentUser() {
    return datasource.getCurrentUser();
  }

  @override
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
  }) {
    return datasource.updateUserProfile(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      bio: bio,
      location: location,
      website: website,
      githubUsername: githubUsername,
      twitterUsername: twitterUsername,
      leetcodeUsername: leetcodeUsername,
      linkedinUsername: linkedinUsername,
      skills: skills,
      theme: theme,
      emailNotifications: emailNotifications,
      pushNotifications: pushNotifications,
      publicProfile: publicProfile,
    );
  }

  @override
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
  }) {
    return datasource.uploadProfileImage(userId: userId, bytes: bytes);
  }

  @override
  Future<void> deleteAccount() {
    return datasource.deleteAccount();
  }

  @override
  Future<void> logout() {
    return datasource.logout();
  }

  @override
  Stream<User?> authStateChanges() {
    return datasource.authStateChanges();
  }
}
