import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthEntity> call(String email, String password, String username, {XFile? profileImage}) async {
    try {
      return await repository.register(email, password, username, profileImage: profileImage);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

