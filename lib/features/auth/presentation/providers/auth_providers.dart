import 'dart:async';

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
    _authSubscription = repository.authStateChanges().listen(
      (user) {
        state = AsyncValue.data(user);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(
          error is Exception ? error : Exception(error.toString()),
          stackTrace,
        );
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      final user = await repository.login(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = const AsyncValue.loading();
      final user = await repository.signup(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      final user = await repository.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
    }
  }

  Future<void> logout() async {
    try {
      state = const AsyncValue.loading();
      await repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(
        e is Exception ? e : Exception(e.toString()),
        stackTrace,
      );
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
