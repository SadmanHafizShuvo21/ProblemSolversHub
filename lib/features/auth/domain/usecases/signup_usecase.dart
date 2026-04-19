import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignupUsecase {
  final AuthRepository repository;

  SignupUsecase(this.repository);

  Future<User> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return repository.signup(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
