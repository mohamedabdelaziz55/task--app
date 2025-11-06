import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/network/storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../users_provider.dart';
import '../../domain/repositories/user_repository.dart';
import 'profile_view.dart';

class EditProfileView extends ConsumerStatefulWidget {
  final UserEntity user;

  const EditProfileView({super.key, required this.user});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  XFile? _selectedImage;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate() && widget.user.id != null) {
      final updateData = <String, dynamic>{};
      
      // Update email if changed
      if (_emailController.text.trim() != widget.user.email) {
        updateData['email'] = _emailController.text.trim();
      }
      
      // Update password if provided
      if (_passwordController.text.trim().isNotEmpty) {
        updateData['password'] = _passwordController.text.trim();
      }
      
      // Note: login_count and last_login_at are typically server-managed fields

      if (updateData.isNotEmpty || _selectedImage != null) {
        // Always use patchUser (PATCH) for profile updates
        final repository = ref.read(userRepositoryProvider);
        try {
          final updatedUser = await repository.patchUser(
            widget.user.id!,
            updateData,
            profileImage: _selectedImage,
          );
          
          // Update the view model state
          ref.read(userViewModelProvider.notifier).setSelectedUser(updatedUser);
          
          // Update StorageService if email changed
          if (updateData.containsKey('email')) {
            await StorageService().saveUserEmail(updateData['email']);
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(updatedUser);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update profile: ${e.toString()}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        // No changes made
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No changes to save'),
              backgroundColor: AppColors.secondaryText,
            ),
          );
        }
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: userState.isLoading ? null : _handleSave,
            child: userState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.tertiaryBackground,
            height: 1,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _selectedImage != null
                      ? Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty
                          ? Image.network(
                              widget.user.photoUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.image,
                                    color: AppColors.primaryText,
                                    size: 64,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.primaryText,
                                size: 64,
                              ),
                            ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: _pickImage,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.tertiaryBackground),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile Photo',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email',
                hint: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              AppTextField(
                label: 'Password',
                hint: 'Leave empty to keep current password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) {
                  // Password is optional - only validate if provided
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                  }
                  return null;
                },
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
