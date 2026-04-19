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
  Future<void> logout() {
    return datasource.logout();
  }

  @override
  Stream<User?> authStateChanges() {
    return datasource.authStateChanges();
  }
}
