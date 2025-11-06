import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_auth_and_profile/features/users/presentation/views/user_deteils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../users_provider.dart';
import '../widgets/user_list_item.dart';
import 'profile_view.dart';

class UsersView extends ConsumerStatefulWidget {
  const UsersView({super.key});

  @override
  ConsumerState<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends ConsumerState<UsersView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userViewModelProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: const Text('Users'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.tertiaryBackground,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: userState.isLoading
                ? const AppLoadingIndicator()
                : userState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userState.error!,
                              style: const TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(userViewModelProvider.notifier).loadUsers();
                              },
                              child: const Text('Retry', style: TextStyle(color: Colors.white),),
                            ),
                          ],
                        ),
                      )
                    : userState.filteredUsers.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(userViewModelProvider.notifier).loadUsers();
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 64,
                                        color: AppColors.secondaryText,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchController.text.isNotEmpty
                                            ? 'No users found'
                                            : 'No users available',
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          ref.read(userViewModelProvider.notifier).loadUsers();
                                        },
                                        child: const Text(
                                          'Refresh',
                                          style: TextStyle(color: AppColors.primaryText),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(userViewModelProvider.notifier).loadUsers();
                            },
                            child: ListView.builder(
                              itemCount: userState.filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = userState.filteredUsers[index];
                                return UserListItem(
                                  user: user,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => UserDeteils(user: user),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

