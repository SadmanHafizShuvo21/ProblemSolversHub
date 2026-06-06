import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_initialization_service.dart';

/// Firebase initialization state
class FirebaseInitializationState {
  final bool isInitializing;
  final bool isInitialized;
  final bool hasError;
  final String? errorMessage;

  FirebaseInitializationState({
    this.isInitializing = false,
    this.isInitialized = false,
    this.hasError = false,
    this.errorMessage,
  });

  factory FirebaseInitializationState.initializing() => FirebaseInitializationState(
        isInitializing: true,
      );

  factory FirebaseInitializationState.success() => FirebaseInitializationState(
        isInitialized: true,
      );

  factory FirebaseInitializationState.error(String message) =>
      FirebaseInitializationState(
        hasError: true,
        errorMessage: message,
      );

  factory FirebaseInitializationState.initial() => FirebaseInitializationState();
}

/// Firebase initialization provider
/// 
/// This provider manages the Firebase initialization state and is used by
/// the app to show appropriate UI during initialization, success, or error states.
final firebaseInitializationProvider =
    StateNotifierProvider<FirebaseInitializationNotifier, FirebaseInitializationState>(
  (ref) => FirebaseInitializationNotifier(),
);

class FirebaseInitializationNotifier extends StateNotifier<FirebaseInitializationState> {
  FirebaseInitializationNotifier() : super(FirebaseInitializationState.initial());

  /// Initialize Firebase
  Future<void> initialize() async {
    state = FirebaseInitializationState.initializing();

    try {
      final service = FirebaseInitializationService();
      final success = await service.initialize();

      if (success) {
        state = FirebaseInitializationState.success();
      } else {
        state = FirebaseInitializationState.error(
          service.getErrorMessage(),
        );
      }
    } catch (e) {
      state = FirebaseInitializationState.error(
        'Unexpected error during Firebase initialization: $e',
      );
    }
  }
}
