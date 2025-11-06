import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    try {
      await repository.logout();
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}

