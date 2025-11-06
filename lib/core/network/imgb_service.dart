import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImgbService {
  static const String _apiKey = '2e5da8ff7d6a0ea3fe8228bc27ffb0fb';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// Uploads an image to IMGB and returns the image URL
  /// Returns null if upload fails
  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      final dio = Dio();
      
      // Read the image file and convert to base64
      final fileBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(fileBytes);
      
      // Create form data
      final formData = FormData.fromMap({
        'key': _apiKey,
        'image': base64Image,
      });
      
      // Upload to IMGB
      final response = await dio.post(
        _uploadUrl,
        data: formData,
      );
      
      // Parse response
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          final imageData = data['data'] as Map<String, dynamic>;
          final imageUrl = imageData['url'] as String?;
          return imageUrl;
        }
      }
      
      return null;
    } catch (e) {
      print('Error uploading image to IMGB: $e');
      return null;
    }
  }
}

