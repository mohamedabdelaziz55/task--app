class UserEntity {
  final String? id;
  final String? email;
  final String? photoUrl;
  final int? loginCount;
  final String? createdAt;
  final String? updatedAt;

  const UserEntity({
    this.id,
    this.email,
    this.photoUrl,
    this.loginCount,
    this.createdAt,
    this.updatedAt,
  });
}
