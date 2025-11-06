import 'user_entity.dart';

class AuthEntity {
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final UserEntity? user;
  final String? message;

  const AuthEntity({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.user,
    this.message,
  });
}
