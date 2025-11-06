import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/imgb_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(LoginRequest request);
  Future<AuthModel> register(RegisterRequest request, {XFile? profileImage});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthModel> login(LoginRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AuthModel> register(RegisterRequest request, {XFile? profileImage}) async {
    try {
      // Upload image to IMGB first if provided
      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await ImgbService.uploadImage(profileImage);
        if (imageUrl == null) {
          throw ServerException('Failed to upload image to IMGB');
        }
      }
      
      // Create request data with image URL if available
      final requestData = <String, dynamic>{
        'email': request.email,
        'password': request.password,
        'username': request.username,
      };
      
      if (imageUrl != null) {
        requestData['profile_image'] = imageUrl;
      }
      
      // Send JSON request with image URL
      final response = await apiClient.post(
        ApiConstants.register,
        data: requestData,
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

