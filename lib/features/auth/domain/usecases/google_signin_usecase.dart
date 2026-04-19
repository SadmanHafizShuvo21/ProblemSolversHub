import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GoogleSigninUsecase {
  final AuthRepository repository;

  GoogleSigninUsecase(this.repository);

  Future<User> call() {
    return repository.signInWithGoogle();
  }
}
