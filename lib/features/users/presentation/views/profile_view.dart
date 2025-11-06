import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/auth_provider.dart';
import '../../domain/entities/user_entity.dart';
import 'edit_profile_view.dart';

class ProfileView extends ConsumerWidget {
  final UserEntity user;
  final bool showAppBar;
  final VoidCallback? onRefresh;

  const ProfileView({
    super.key,
    required this.user,
    this.showAppBar = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar:  AppBar(
              backgroundColor: AppColors.primaryBackground,
              elevation: 0,

              title: const Text('Profile'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: AppColors.tertiaryBackground,
                  height: 1,
                ),
              ),
            )
      ,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 64,
              backgroundColor: AppColors.tertiaryBackground,
              backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null || user.photoUrl!.isEmpty
                  ? Text(
                      user.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.email ?? 'Unknown',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Shield Preferences Section
            _ShieldPreferencesSection(user: user),
            
            const SizedBox(height: 24),
            
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditProfileView(user: user),
                      ),
                    ).then((updatedUser) {
                      // Refresh profile if callback is provided
                      if (onRefresh != null) {
                        onRefresh!();
                      }
                    });
                  },
                  icon: const Icon(Icons.edit, color: AppColors.primaryText),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: AppColors.tertiaryBackground,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Show confirmation dialog
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.secondaryBackground,
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: AppColors.primaryText),
                        ),
                        content: const Text(
                          'Are you sure you want to logout?',
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.secondaryText),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true && context.mounted) {
                      await ref.read(authViewModelProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.login,
                          (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: AppColors.error,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ShieldPreferencesSection extends StatelessWidget {
  final UserEntity user;

  const _ShieldPreferencesSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.tertiaryBackground,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _ProfileInfoItem(
            icon: Icons.email,
            label: 'Email',
            value: user.email ?? 'Not provided',
          ),
          if (user.id != null) ...[
            const SizedBox(height: 16),
            _ProfileInfoItem(
              icon: Icons.badge,
              label: 'User ID',
              value: user.id!,
            ),
          ],
          if (user.loginCount != null) ...[
            const SizedBox(height: 16),
            _ProfileInfoItem(
              icon: Icons.login,
              label: 'Login Count',
              value: user.loginCount.toString(),
            ),
          ],
          if (user.createdAt != null) ...[
            const SizedBox(height: 16),
            _ProfileInfoItem(
              icon: Icons.calendar_today,
              label: 'Account Created',
              value: _formatDate(user.createdAt!),
            ),
          ],
          if (user.updatedAt != null) ...[
            const SizedBox(height: 16),
            _ProfileInfoItem(
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatDate(user.updatedAt!),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.secondaryText,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
