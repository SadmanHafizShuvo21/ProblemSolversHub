import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignupUsecase signupUsecase;
  final LoginUsecase loginUsecase;
  final GoogleSigninUsecase googleSigninUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  StreamSubscription? _authStateSubscription;

  AuthBloc({
    required this.signupUsecase,
    required this.loginUsecase,
    required this.googleSigninUsecase,
    required this.logoutUsecase,
    required this.getCurrentUserUsecase,
  }) : super(const AuthInitial()) {
    on<AuthCheckStatusEvent>(_onAuthCheckStatus);
    on<AuthSignupEvent>(_onAuthSignup);
    on<AuthLoginEvent>(_onAuthLogin);
    on<AuthGoogleSigninEvent>(_onAuthGoogleSignin);
    on<AuthLogoutEvent>(_onAuthLogout);

    // Listen to auth state changes
    _setupAuthStateListener();
  }

  /// Setup listener for auth state changes
  void _setupAuthStateListener() {
    _authStateSubscription = getCurrentUserUsecase().listen((user) {
      if (user != null) {
        // Only emit if the bloc is not closed
        if (!isClosed) {
          add(AuthCheckStatusEvent());
        }
      }
    });
  }

  /// Check current auth status
  Future<void> _onAuthCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userStream = getCurrentUserUsecase();
      final user = await userStream.first;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  /// Handle signup
  Future<void> _onAuthSignup(
    AuthSignupEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signupUsecase(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handle login
  Future<void> _onAuthLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await loginUsecase(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handle Google Sign-In
  Future<void> _onAuthGoogleSignin(
    AuthGoogleSigninEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await googleSigninUsecase();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Handle logout
  Future<void> _onAuthLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await logoutUsecase();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
