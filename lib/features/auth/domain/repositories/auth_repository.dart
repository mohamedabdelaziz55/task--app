import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';

import 'package:image_picker/image_picker.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String email, String password);
  Future<AuthEntity> register(String email, String password, String username, {XFile? profileImage});
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
}

