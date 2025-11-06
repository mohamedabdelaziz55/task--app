import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../network/storage_service.dart';
import '../errors/exceptions.dart';

class ApiClient {
  late Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor to include token in requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            _storageService.clearAll();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, bool isMultipart = false}) async {
    try {
      if (isMultipart && data is FormData) {
        // For multipart requests, don't set Content-Type header
        // Dio will set it automatically with boundary
        return await _dio.post(
          path,
          data: data,
          options: Options(
            headers: {
              'Accept': 'application/json',
            },
          ),
        );
      }
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, bool isMultipart = false}) async {
    try {
      if (isMultipart && data is FormData) {
        return await _dio.put(
          path,
          data: data,
          options: Options(
            headers: {
              'Accept': 'application/json',
            },
          ),
        );
      }
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Future<Response> patch(String path, {dynamic data, bool isMultipart = false}) async {
    try {
      if (isMultipart && data is FormData) {
        // For multipart requests, don't set Content-Type header
        // Dio will set it automatically with boundary
        return await _dio.patch(
          path,
          data: data,
          options: Options(
            headers: {
              'Accept': 'application/json',
            },
          ),
        );
      }
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data['message'] ?? 
                     error.response?.statusMessage ?? 
                     'An error occurred';
      return ServerException(message);
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Connection timeout. Please check your internet connection.');
    } else if (error.type == DioExceptionType.connectionError) {
      return NetworkException('No internet connection. Please check your network.');
    } else {
      return NetworkException(error.message ?? 'An unexpected error occurred');
    }
  }
}

