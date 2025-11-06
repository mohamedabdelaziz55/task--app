import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../widgets/login_form.dart';
import '../viewmodels/auth_view_model.dart';
import '../../auth_provider.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  Future<void> _handleLogin(String email, String password) async {
    await ref.read(authViewModelProvider.notifier).login(email, password);

    final authState = ref.read(authViewModelProvider);
    
    if (authState.isAuthenticated && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.users);
    } else if (authState.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Log In',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Welcome text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                'Welcome back',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Login Form
            Expanded(
              child: LoginForm(
                onLogin: (email, password) => _handleLogin(email, password),
                isLoading: authState.isLoading,
              ),
            ),

            // Sign up button
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.register);
                },
                child: const Text(
                  'New User Sign Up',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

