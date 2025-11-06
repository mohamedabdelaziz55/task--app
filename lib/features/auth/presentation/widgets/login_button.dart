import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LoginButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppButton(
        text: 'Log In',
        onPressed: onPressed,
        isLoading: isLoading,
      ),
    );
  }
}

