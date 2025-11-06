import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';
import 'data/datasources/user_remote_datasource.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/get_users_usecase.dart';
import 'domain/usecases/get_user_by_id_usecase.dart';
import 'domain/usecases/update_user_usecase.dart';
import 'presentation/viewmodels/user_view_model.dart';

// Data Sources
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRemoteDataSourceImpl(apiClient);
});

// Repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Cases
final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUsersUseCase(repository);
});

final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserByIdUseCase(repository);
});

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateUserUseCase(repository);
});

// ViewModel
final userViewModelProvider =
    StateNotifierProvider<UserViewModel, UserState>((ref) {
  return UserViewModel(
    getUsersUseCase: ref.watch(getUsersUseCaseProvider),
    getUserByIdUseCase: ref.watch(getUserByIdUseCaseProvider),
    updateUserUseCase: ref.watch(updateUserUseCaseProvider),
  );
});
