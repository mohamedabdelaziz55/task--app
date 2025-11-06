import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/views/login_view.dart';
import 'features/auth/presentation/views/register_view.dart';
import 'features/auth/auth_provider.dart';
import 'features/users/presentation/views/home_layout.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'User Profile Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      routes: {
        AppRoutes.login: (context) => const LoginView(),
        AppRoutes.register: (context) => const RegisterView(),
        AppRoutes.users: (context) => const HomeLayout(),
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    // Check if user is authenticated
    if (authState.isAuthenticated) {
      return const HomeLayout();
    } else {
      return const LoginView();
    }
  }
}
