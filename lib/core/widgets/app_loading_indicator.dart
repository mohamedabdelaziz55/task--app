import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const AppLoadingIndicator({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 24,
        height: size ?? 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primaryAccent,
          ),
        ),
      ),
    );
  }
}

