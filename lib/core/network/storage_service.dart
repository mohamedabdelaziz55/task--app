import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/user_entity.dart';

class StorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresInKey = 'expires_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  // Save access token
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Save refresh token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Save expires in
  Future<void> saveExpiresIn(int expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_expiresInKey, expiresIn);
  }

  // Get expires in
  Future<int?> getExpiresIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_expiresInKey);
  }

  // Save user ID (as String for UUID)
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Save user email
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  // Get user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_expiresInKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Get token (for backward compatibility with API client)
  Future<String?> getToken() async {
    return await getAccessToken();
  }
  Future<UserEntity> getUserEntity() async {
    final prefs = await SharedPreferences.getInstance();
    return UserEntity(
      id: prefs.getString(_userIdKey),
      email: prefs.getString(_userEmailKey),
      photoUrl: null,
      loginCount: null,
      createdAt: null,
      updatedAt: null,
    );
  }
}

