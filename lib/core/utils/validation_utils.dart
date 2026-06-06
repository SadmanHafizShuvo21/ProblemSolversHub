import 'package:problem_solvers_hub/core/exceptions/app_exception.dart';

class ValidationUtils {
  /// Validate email format
  static void validateEmail(String email) {
    if (email.isEmpty) {
      throw ValidationException.requiredField('Email');
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      throw ValidationException.invalidEmail();
    }
  }

  /// Validate password
  static void validatePassword(String password) {
    if (password.isEmpty) {
      throw ValidationException.requiredField('Password');
    }
    
    if (password.length < 6) {
      throw ValidationException.invalidPassword(
        'Password must be at least 6 characters long',
      );
    }
  }

  /// Validate display name
  static void validateDisplayName(String displayName) {
    if (displayName.isEmpty) {
      throw ValidationException.requiredField('Display name');
    }
    
    if (displayName.length < 2) {
      throw ValidationException.invalidPassword(
        'Display name must be at least 2 characters long',
      );
    }
    
    if (displayName.length > 50) {
      throw ValidationException.invalidPassword(
        'Display name cannot exceed 50 characters',
      );
    }
  }

  /// Validate passwords match
  static void validatePasswordsMatch(String password, String confirmPassword) {
    if (password != confirmPassword) {
      throw ValidationException.passwordsDoNotMatch();
    }
  }

  /// Validate login form
  static void validateLoginForm(String email, String password) {
    validateEmail(email);
    validatePassword(password);
  }

  /// Validate signup form
  static void validateSignupForm(
    String email,
    String password,
    String confirmPassword,
    String displayName,
  ) {
    validateEmail(email);
    validatePassword(password);
    validatePasswordsMatch(password, confirmPassword);
    validateDisplayName(displayName);
  }
}
