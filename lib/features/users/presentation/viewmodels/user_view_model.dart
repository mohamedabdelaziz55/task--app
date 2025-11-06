import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';

class UserViewModel extends StateNotifier<UserState> {
  final GetUsersUseCase getUsersUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateUserUseCase updateUserUseCase;

  UserViewModel({
    required this.getUsersUseCase,
    required this.getUserByIdUseCase,
    required this.updateUserUseCase,
  }) : super(UserState.initial());

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final users = await getUsersUseCase();
      print(' Users fetched: ${users.length}');

      state = state.copyWith(
        users: users,
        filteredUsers: users,
        isLoading: false,
        error: null,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadUserById(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await getUserByIdUseCase(id);
      state = state.copyWith(
        selectedUser: user,
        isLoading: false,
        error: null,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedUser = await updateUserUseCase(id, data);
      final users = state.users.map((u) => u.id == id ? updatedUser : u).toList();
      
      state = state.copyWith(
        users: users,
        filteredUsers: users,
        selectedUser: updatedUser,
        isLoading: false,
        error: null,
      );
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setSelectedUser(UserEntity? user) {
    state = state.copyWith(selectedUser: user);
  }

  void filterUsers(String searchTerm) {
    if (searchTerm.isEmpty) {
      state = state.copyWith(filteredUsers: state.users);
      return;
    }

    final filtered = state.users.where((user) {
      final email = user.email?.toLowerCase() ?? '';
      final id = user.id?.toLowerCase() ?? '';
      final search = searchTerm.toLowerCase();
      
      return email.contains(search) || id.contains(search);
    }).toList();

    state = state.copyWith(filteredUsers: filtered);
  }
}

class UserState {
  final List<UserEntity> users;
  final List<UserEntity> filteredUsers;
  final UserEntity? selectedUser;
  final bool isLoading;
  final String? error;

  UserState({
    required this.users,
    required this.filteredUsers,
    this.selectedUser,
    required this.isLoading,
    this.error,
  });

  factory UserState.initial() {
    return UserState(
      users: [],
      filteredUsers: [],
      isLoading: false,
      error: null,
    );
  }

  UserState copyWith({
    List<UserEntity>? users,
    List<UserEntity>? filteredUsers,
    UserEntity? selectedUser,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      selectedUser: selectedUser ?? this.selectedUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

