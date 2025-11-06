import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
  }) : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await checkAuthStatusUseCase();
      if (isLoggedIn) {
        state = state.copyWith(isAuthenticated: true);
      }
    } catch (e) {
      // Silent fail on startup check
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authEntity = await loginUseCase(email, password);
      
      if (authEntity.accessToken != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: authEntity.message ?? 'Login failed',
        );
      }
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(String email, String password, String username, {XFile? profileImage}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authEntity = await registerUseCase(email, password, username, profileImage: profileImage);
      
      if (authEntity.accessToken != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: authEntity.message ?? 'Registration failed',
        );
      }
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      error: null,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

