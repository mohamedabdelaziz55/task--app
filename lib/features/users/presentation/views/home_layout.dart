import 'package:flutter/material.dart';
import 'package:task_auth_and_profile/features/users/presentation/views/profile_view.dart';
import 'package:task_auth_and_profile/features/users/presentation/views/users_view.dart';
import '../../../../core/network/storage_service.dart';
import '../../domain/entities/user_entity.dart' as users_entity;
import '../widgets/bottom_nav_bar.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {

  int currentIndex = 0;
  users_entity.UserEntity? currentUser;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    loadUser();
    // Initialize pages with placeholder
    _pages = [
      UsersView(),
      const SizedBox(), // Placeholder until user is loaded
    ];
  }

  void loadUser() async {
    final authUser = await StorageService().getUserEntity();
    // Convert auth UserEntity to users UserEntity
    setState(() {
      currentUser = users_entity.UserEntity(
        id: authUser.id,
        email: authUser.email,
        photoUrl: authUser.photoUrl,
        loginCount: authUser.loginCount,
        createdAt: authUser.createdAt,
        updatedAt: authUser.updatedAt,
      );
      // Update pages with actual profile view
      _pages[1] = ProfileView(
        user: currentUser!,
        showAppBar: false,
        onRefresh: refreshProfile,
      );
    });
  }

  void refreshProfile() {
    loadUser();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
