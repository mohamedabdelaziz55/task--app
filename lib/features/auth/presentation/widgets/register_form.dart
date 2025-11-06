import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/constants/app_colors.dart';

class RegisterForm extends StatefulWidget {
  final Function(String email, String password, String username, XFile? profileImage) onRegister;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onRegister,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      // Handle error silently or show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      widget.onRegister(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
        _selectedImage,
      );
    }
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _usernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppTextField(
              hint: 'Email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            AppTextField(
              hint: 'Password',
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: _passwordValidator,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.secondaryText,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            AppTextField(
              hint: 'Confirm password',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              validator: _confirmPasswordValidator,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.secondaryText,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            AppTextField(
              hint: 'Username',
              controller: _usernameController,
              validator: _usernameValidator,
            ),
            _ProfilePhotoPlaceholder(
              selectedImage: _selectedImage,
              onTap: _pickImage,
              onRemove: _selectedImage != null
                  ? () {
                      setState(() {
                        _selectedImage = null;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                text: 'Create account',
                onPressed: _handleRegister,
                isLoading: widget.isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhotoPlaceholder extends StatelessWidget {
  final XFile? selectedImage;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _ProfilePhotoPlaceholder({
    this.selectedImage,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.tertiaryBackground,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.image,
                      color: AppColors.primaryText,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                selectedImage != null ? 'Change profile photo' : 'Add profile photo',
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                ),
              ),
            ),
            if (selectedImage != null && onRemove != null)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}

