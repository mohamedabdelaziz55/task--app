import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../widgets/register_form.dart';
import '../../auth_provider.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  Future<void> _handleRegister(String email, String password, String username, dynamic profileImage) async {
    await ref.read(authViewModelProvider.notifier).register(
      email,
      password,
      username,
      profileImage: profileImage,
    );

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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Create account',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Register Form
            Expanded(
              child: RegisterForm(
                onRegister: (email, password, username, profileImage) =>
                  _handleRegister(email, password, username, profileImage),
                isLoading: authState.isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
