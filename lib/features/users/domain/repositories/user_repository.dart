import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers();
  Future<UserEntity> getUserById(String id);
  Future<UserEntity> updateUser(String id, Map<String, dynamic> data);
  Future<UserEntity> patchUser(String id, Map<String, dynamic> data, {XFile? profileImage});
  Future<void> deleteUser(String id);
}

