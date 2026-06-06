/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Exception? originalException;

  AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Authentication-related exceptions
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    Exception? originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  /// Email already in use
  factory AuthException.emailAlreadyInUse() {
    return AuthException(
      message: 'This email is already registered. Please login or use a different email.',
      code: 'email-already-in-use',
    );
  }

  /// User not found
  factory AuthException.userNotFound() {
    return AuthException(
      message: 'No account found with this email. Please sign up first.',
      code: 'user-not-found',
    );
  }

  /// Wrong password
  factory AuthException.wrongPassword() {
    return AuthException(
      message: 'Incorrect password. Please try again.',
      code: 'wrong-password',
    );
  }

  /// Invalid email
  factory AuthException.invalidEmail() {
    return AuthException(
      message: 'Please enter a valid email address.',
      code: 'invalid-email',
    );
  }

  /// Weak password
  factory AuthException.weakPassword() {
    return AuthException(
      message: 'Password must be at least 6 characters long.',
      code: 'weak-password',
    );
  }

  /// User disabled
  factory AuthException.userDisabled() {
    return AuthException(
      message: 'Your account has been disabled. Please contact support.',
      code: 'user-disabled',
    );
  }

  /// Generic auth error
  factory AuthException.generic(String message) {
    return AuthException(
      message: message,
      code: 'auth-error',
    );
  }

  /// Network error
  factory AuthException.networkError() {
    return AuthException(
      message: 'Network error. Please check your internet connection.',
      code: 'network-error',
    );
  }

  /// Operation cancelled
  factory AuthException.operationCancelled() {
    return AuthException(
      message: 'Operation cancelled.',
      code: 'operation-cancelled',
    );
  }
}

/// Firestore-related exceptions
class FirestoreException extends AppException {
  FirestoreException({
    required String message,
    String? code,
    Exception? originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  /// Generic Firestore error
  factory FirestoreException.generic(String message) {
    return FirestoreException(
      message: message,
      code: 'firestore-error',
    );
  }

  /// Document not found
  factory FirestoreException.documentNotFound() {
    return FirestoreException(
      message: 'Document not found.',
      code: 'document-not-found',
    );
  }

  /// Permission denied
  factory FirestoreException.permissionDenied() {
    return FirestoreException(
      message: 'You do not have permission to access this resource.',
      code: 'permission-denied',
    );
  }
}

/// Validation-related exceptions
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
    Exception? originalException,
  }) : super(
    message: message,
    code: code,
    originalException: originalException,
  );

  /// Email validation error
  factory ValidationException.invalidEmail() {
    return ValidationException(
      message: 'Please enter a valid email address.',
      code: 'invalid-email',
    );
  }

  /// Password validation error
  factory ValidationException.invalidPassword(String reason) {
    return ValidationException(
      message: 'Invalid password: $reason',
      code: 'invalid-password',
    );
  }

  /// Required field error
  factory ValidationException.requiredField(String fieldName) {
    return ValidationException(
      message: '$fieldName is required.',
      code: 'required-field',
    );
  }

  /// Passwords do not match
  factory ValidationException.passwordsDoNotMatch() {
    return ValidationException(
      message: 'Passwords do not match.',
      code: 'passwords-do-not-match',
    );
  }
}
