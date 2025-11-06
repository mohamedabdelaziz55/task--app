import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthEntity> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final authModel = await remoteDataSource.login(request);
      
      if (authModel.accessToken != null) {
        await localDataSource.saveAccessToken(authModel.accessToken!);
        if (authModel.refreshToken != null) {
          await localDataSource.saveRefreshToken(authModel.refreshToken!);
        }
        if (authModel.expiresIn != null) {
          await localDataSource.saveExpiresIn(authModel.expiresIn!);
        }
        if (authModel.user?.id != null) {
          await localDataSource.saveUserId(authModel.user!.id!);
        }
        if (authModel.user?.email != null) {
          await localDataSource.saveUserEmail(authModel.user!.email!);
        }
      }
      
      return authModel;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AuthEntity> register(String email, String password, String username, {XFile? profileImage}) async {
    try {
      final request = RegisterRequest(email: email, password: password, username: username);
      final authModel = await remoteDataSource.register(request, profileImage: profileImage);
      
      if (authModel.accessToken != null) {
        await localDataSource.saveAccessToken(authModel.accessToken!);
        if (authModel.refreshToken != null) {
          await localDataSource.saveRefreshToken(authModel.refreshToken!);
        }
        if (authModel.expiresIn != null) {
          await localDataSource.saveExpiresIn(authModel.expiresIn!);
        }
        if (authModel.user?.id != null) {
          await localDataSource.saveUserId(authModel.user!.id!);
        }
        if (authModel.user?.email != null) {
          await localDataSource.saveUserEmail(authModel.user!.email!);
        }
      }
      
      return authModel;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localDataSource.clearAll();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await localDataSource.isLoggedIn();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await localDataSource.getToken();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    } catch (e) {
      throw CacheFailure(e.toString());
    }
  }
}

