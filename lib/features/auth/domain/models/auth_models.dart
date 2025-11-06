class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });
}

class RegisterRequest {
  final String email;
  final String password;
  final String username;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.username,
  });
}

