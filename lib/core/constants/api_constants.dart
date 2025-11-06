class ApiConstants {
  static const String baseUrl = 'http://2.56.246.249:25570';
  
  // Auth Endpoints
  static const String register = '/register';
  static const String login = '/login';
  
  // User Endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
}

