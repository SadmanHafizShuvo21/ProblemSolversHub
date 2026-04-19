import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Stream<User?> call() {
    return repository.authStateChanges();
  }
}
