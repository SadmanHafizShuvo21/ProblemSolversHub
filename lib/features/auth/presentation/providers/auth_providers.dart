import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:problem_solvers_hub/core/service_locator.dart';
import 'package:problem_solvers_hub/features/auth/domain/entities/user.dart';
import 'package:problem_solvers_hub/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository repository;
  late final StreamSubscription<User?> _authSubscription;

  AuthNotifier(this.repository) : super(const AsyncValue.loading()) {
    // Initialize with the current user from repository
    _initializeAuthState();
  }

  /// Initialize auth state by fetching current user and setting up subscription
  Future<void> _initializeAuthState() async {
    try {
      // First, try to get the current user
      final currentUser = await repository.getCurrentUser();
      if (!isMounted) return;

      if (currentUser != null) {
        state = AsyncValue.data(currentUser);
        debugPrint('✅ Auth: Current user loaded: ${currentUser.email}');
      } else {
        state = const AsyncValue.data(null);
        debugPrint('✅ Auth: No current user');
      }
    } catch (e, stackTrace) {
      if (!isMounted) return;
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
      debugPrint('❌ Auth: Error loading current user: $e');
    }

    // Then, set up the subscription to listen for future changes
    _setupAuthSubscription();
  }

  /// Setup subscription to auth state changes
  void _setupAuthSubscription() {
    _authSubscription = repository.authStateChanges().listen(
      (user) {
        if (!isMounted) return;
        
        if (user != null) {
          // User is logged in, update state
          state = AsyncValue.data(user);
          debugPrint('✅ Auth: Auth state changed - user: ${user.email}');
        } else {
          // User logged out or stream returned null
          state.maybeWhen(
            data: (currentUser) {
              // Only clear if we currently have no user
              // If we have a logged-in user and stream returns null (error), keep existing user
              if (currentUser == null) {
                state = const AsyncValue.data(null);
                debugPrint('✅ Auth: Auth state changed - user logged out');
              } else {
                debugPrint('⚠️  Auth: Stream returned null, but user still logged in');
              }
            },
            orElse: () {
              // Not in data state, set to null
              state = const AsyncValue.data(null);
              debugPrint('✅ Auth: Auth state changed - user logged out');
            },
          );
        }
      },
      onError: (error, stackTrace) {
        if (!isMounted) return;
        state = AsyncValue.error(
          error is Exception ? error : Exception(error.toString()),
          stackTrace,
        );
        debugPrint('❌ Auth: Auth state error: $error');
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Auth: Login attempt for $email');
      state = const AsyncValue.loading();
      final user = await repository.login(email: email, password: password);
      if (!isMounted) return;
      state = AsyncValue.data(user);
      debugPrint('✅ Auth: Login successful for ${user.email}');
    } catch (e, stackTrace) {
      if (!isMounted) return;
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
      debugPrint('❌ Auth: Login failed: $e');
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      debugPrint('🔐 Auth: Signup attempt for $email');
      state = const AsyncValue.loading();
      final user = await repository.signup(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (!isMounted) return;
      state = AsyncValue.data(user);
      debugPrint('✅ Auth: Signup successful for ${user.email}');
    } catch (e, stackTrace) {
      if (!isMounted) return;
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
      debugPrint('❌ Auth: Signup failed: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🔐 Auth: Google sign-in attempt');
      state = const AsyncValue.loading();
      final user = await repository.signInWithGoogle();
      if (!isMounted) return;
      state = AsyncValue.data(user);
      debugPrint('✅ Auth: Google sign-in successful for ${user.email}');
    } catch (e, stackTrace) {
      if (!isMounted) return;
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
      debugPrint('❌ Auth: Google sign-in failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('🔐 Auth: Logout attempt');
      state = const AsyncValue.loading();
      await repository.logout();
      if (!isMounted) return;
      state = const AsyncValue.data(null);
      debugPrint('✅ Auth: Logout successful');
    } catch (e, stackTrace) {
      if (!isMounted) return;
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
      debugPrint('❌ Auth: Logout failed: $e');
    }
  }

  /// Check if the state notifier is still mounted and active
  bool get isMounted => !this.mounted ? false : true;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
