import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/imgb_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUserById(String id);
  Future<UserModel> updateUser(String id, Map<String, dynamic> data);
  Future<UserModel> patchUser(String id, Map<String, dynamic> data, {XFile? profileImage});
  Future<void> deleteUser(String id);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await apiClient.get(ApiConstants.users);
      print('[API] response: ${response.data}');
      if (response.data is Map && response.data['users'] is List) {
        final list = response.data['users'] as List;
        print('users fetched: ${list.length}');
        return list
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      if (response.data is List) {
        final list = response.data as List;
        print('users fetched (direct list): ${list.length}');
        return list
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await apiClient.get(ApiConstants.userById(id));
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put(
        ApiConstants.userById(id),
        data: data,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> patchUser(String id, Map<String, dynamic> data, {XFile? profileImage}) async {
    try {
      // Upload image to IMGB first if provided
      if (profileImage != null) {
        final imageUrl = await ImgbService.uploadImage(profileImage);
        if (imageUrl == null) {
          throw ServerException('Failed to upload image to IMGB');
        }
        // Add image URL to data
        data['profile_image'] = imageUrl;
      }
      
      // Send JSON request with image URL using PATCH
      final response = await apiClient.patch(
        ApiConstants.userById(id),
        data: data,
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await apiClient.delete(ApiConstants.userById(id));
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

