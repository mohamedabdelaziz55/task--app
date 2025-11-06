import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<bool> call() async {
    try {
      return await repository.isLoggedIn();
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}

