import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Custom exception for authentication errors
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
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Sign up with email and password
  Future<UserModel> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) throw AuthException('User creation failed');

      // Update display name
      await user.updateDisplayName(displayName);
      await user.reload();

      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );

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
      if (user == null) throw AuthException('Login failed');

      // Fetch user data from Firestore
      final doc = await _firestore.collection(_usersCollection).doc(user.uid).get();
      if (!doc.exists) throw AuthException('User data not found');

      return UserModel.fromJson(doc.data()!);
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
      if (googleUser == null) throw AuthException('Google sign-in cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) throw AuthException('Google sign-in failed');

      // Check if user exists in Firestore
      final doc = await _firestore.collection(_usersCollection).doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }

      // Create new user document
      final userModel = UserModel(
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

      final doc = await _firestore.collection(_usersCollection).doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthException('Logout failed: $e');
    }
  }

  /// Upload a profile image and return its download URL
  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
  }) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/$userId/profile_photo.jpg');

      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw AuthException('Failed to upload profile image: $e');
    }
  }

  /// Update user profile data in Auth and Firestore
  Future<UserModel> updateUserProfile({
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
  }) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('No authenticated user found');
      }

      final updateData = <String, dynamic>{
        'displayName': displayName,
        'bio': bio,
        'location': location,
        'website': website,
        'githubUsername': githubUsername,
        'twitterUsername': twitterUsername,
        'leetcodeUsername': leetcodeUsername,
        'linkedinUsername': linkedinUsername,
        'skills': skills ?? [],
        'theme': theme,
        'emailNotifications': emailNotifications,
        'pushNotifications': pushNotifications,
        'publicProfile': publicProfile,
      };

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      await firebaseUser.updateDisplayName(displayName);
      if (photoUrl != null) {
        await firebaseUser.updatePhotoURL(photoUrl);
      }
      await firebaseUser.reload();

      await _firestore.collection(_usersCollection).doc(userId).set(
            updateData,
            SetOptions(merge: true),
          );

      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (!doc.exists) {
        throw AuthException('User document not found after update');
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Update failed: $e');
    }
  }

  /// Delete user account and Firestore document
  Future<void> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('No authenticated user found');
      }

      await firebaseUser.delete();
      await _googleSignIn.signOut();
      await _firestore.collection(_usersCollection).doc(firebaseUser.uid).delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AuthException('Account deletion failed: $e');
    }
  }

  /// Stream of auth state changes
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final doc = await _firestore
            .collection(_usersCollection)
            .doc(firebaseUser.uid)
            .get();
        if (!doc.exists) return null;
        return UserModel.fromJson(doc.data()!);
      } catch (e) {
        return null;
      }
    });
  }

  /// Handle Firebase Auth exceptions and return user-friendly messages
  AuthException _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          'No user found with this email address',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return AuthException(
          'The password you entered is incorrect',
          code: 'wrong-password',
        );
      case 'invalid-email':
        return AuthException(
          'Please enter a valid email address',
          code: 'invalid-email',
        );
      case 'user-disabled':
        return AuthException(
          'This account has been disabled',
          code: 'user-disabled',
        );
      case 'email-already-in-use':
        return AuthException(
          'This email is already registered',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return AuthException(
          'Password must be at least 6 characters',
          code: 'weak-password',
        );
      case 'operation-not-allowed':
        return AuthException(
          'This operation is not allowed',
          code: 'operation-not-allowed',
        );
      case 'too-many-requests':
        return AuthException(
          'Too many login attempts. Please try again later',
          code: 'too-many-requests',
        );
      case 'network-request-failed':
        return AuthException(
          'Network error. Please check your connection',
          code: 'network-request-failed',
        );
      default:
        return AuthException(
          e.message ?? 'Authentication failed',
          code: e.code,
        );
    }
  }
}
