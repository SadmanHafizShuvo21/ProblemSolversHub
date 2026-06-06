import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:problem_solvers_hub/firebase_options.dart';

/// Firebase initialization service
/// 
/// This service handles all Firebase-related initialization and provides
/// a single point of configuration for the entire application.
/// 
/// Best Practices:
/// - Centralized Firebase configuration
/// - Comprehensive error handling with detailed logging
/// - Platform-specific initialization
/// - Graceful degradation on initialization failure
/// - Monitoring and analytics hooks
class FirebaseInitializationService {
  static final FirebaseInitializationService _instance =
      FirebaseInitializationService._internal();

  factory FirebaseInitializationService() {
    return _instance;
  }

  FirebaseInitializationService._internal();

  bool _initialized = false;
  bool _initializationFailed = false;
  String? _initializationError;

  /// Check if Firebase has been initialized
  bool get isInitialized => _initialized;

  /// Check if Firebase initialization failed
  bool get hasInitializationFailed => _initializationFailed;

  /// Get initialization error message if any
  String? get initializationError => _initializationError;

  /// Initialize Firebase with comprehensive error handling
  ///
  /// This method:
  /// 1. Validates platform compatibility
  /// 2. Initializes Firebase Core with platform-specific options
  /// 3. Logs initialization status
  /// 4. Handles initialization failures gracefully
  /// 5. Returns initialization status
  Future<bool> initialize() async {
    if (_initialized) {
      debugPrint('✅ Firebase already initialized');
      return true;
    }

    try {
      debugPrint('🔥 Starting Firebase initialization...');
      debugPrint('📱 Platform: ${_getPlatformName()}');

      if (defaultTargetPlatform == TargetPlatform.linux) {
        _initializationFailed = true;
        _initializationError =
            'Firebase desktop support is not available on Linux with the current plugin versions.';
        debugPrint('❌ Firebase initialization skipped: Linux is not supported.');
        return false;
      }

      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _initialized = true;
      _initializationFailed = false;
      _initializationError = null;

      debugPrint('✅ Firebase initialized successfully');
      debugPrint('📊 Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');

      return true;
    } catch (e, stackTrace) {
      _initialized = false;
      _initializationFailed = true;
      _initializationError = e.toString();

      debugPrint('❌ Firebase initialization failed');
      debugPrint('Error: $e');
      debugPrint('Stacktrace: $stackTrace');

      // Log specific error types for debugging
      _logInitializationError(e, stackTrace);

      return false;
    }
  }

  /// Log specific initialization errors with helpful debugging info
  void _logInitializationError(Object error, StackTrace stackTrace) {
    if (error is FirebaseException) {
      debugPrint('🔴 FirebaseException Code: ${error.code}');
      debugPrint('🔴 FirebaseException Message: ${error.message}');
      debugPrint('🔴 Plugin: ${error.plugin}');
    } else if (error.toString().contains('channel-error')) {
      debugPrint('🔴 Channel Error - Likely cause: Missing GoogleService-Info.plist on iOS');
      debugPrint('🔴 Solution: Ensure GoogleService-Info.plist is added to Xcode project');
    } else if (error.toString().contains('PlatformException')) {
      debugPrint('🔴 Platform Exception - Check native configuration');
    }
  }

  /// Get human-readable platform name
  String _getPlatformName() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS';
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'Windows';
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      return 'Linux';
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'macOS';
    }
    return 'Unknown';
  }

  /// Get initialization error UI message
  String getErrorMessage() {
    if (!_initializationFailed) {
      return '';
    }

    if (_initializationError?.contains('channel-error') ?? false) {
      return 'Firebase configuration missing. Please check:\n'
          '- iOS: GoogleService-Info.plist in Xcode\n'
          '- Android: google-services.json in app/\n'
          '- All files properly added to project';
    }

    return 'Firebase initialization failed: $_initializationError';
  }
}
