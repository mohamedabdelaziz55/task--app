import '../../../../core/network/storage_service.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveExpiresIn(int expiresIn);
  Future<int?> getExpiresIn();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveUserEmail(String email);
  Future<String?> getUserEmail();
  Future<void> clearAll();
  Future<bool> isLoggedIn();
  // For backward compatibility
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final StorageService storageService;

  AuthLocalDataSourceImpl(this.storageService);

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await storageService.saveAccessToken(token);
    } catch (e) {
      throw CacheException('Failed to save access token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await storageService.getAccessToken();
    } catch (e) {
      throw CacheException('Failed to get access token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await storageService.saveRefreshToken(token);
    } catch (e) {
      throw CacheException('Failed to save refresh token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await storageService.getRefreshToken();
    } catch (e) {
      throw CacheException('Failed to get refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> saveExpiresIn(int expiresIn) async {
    try {
      await storageService.saveExpiresIn(expiresIn);
    } catch (e) {
      throw CacheException('Failed to save expires in: ${e.toString()}');
    }
  }

  @override
  Future<int?> getExpiresIn() async {
    try {
      return await storageService.getExpiresIn();
    } catch (e) {
      throw CacheException('Failed to get expires in: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserId(String userId) async {
    try {
      await storageService.saveUserId(userId);
    } catch (e) {
      throw CacheException('Failed to save user ID: ${e.toString()}');
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return await storageService.getUserId();
    } catch (e) {
      throw CacheException('Failed to get user ID: ${e.toString()}');
    }
  }

  @override
  Future<void> saveUserEmail(String email) async {
    try {
      await storageService.saveUserEmail(email);
    } catch (e) {
      throw CacheException('Failed to save user email: ${e.toString()}');
    }
  }

  @override
  Future<String?> getUserEmail() async {
    try {
      return await storageService.getUserEmail();
    } catch (e) {
      throw CacheException('Failed to get user email: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await storageService.clearAll();
    } catch (e) {
      throw CacheException('Failed to clear storage: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await storageService.isLoggedIn();
    } catch (e) {
      throw CacheException('Failed to check login status: ${e.toString()}');
    }
  }

  @override
  Future<String?> getToken() async {
    return await getAccessToken();
  }
}

