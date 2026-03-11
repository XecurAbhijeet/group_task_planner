import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_task_planner/features/auth/repository/auth_repository.dart';
import 'package:group_task_planner/models/user_model.dart';
import 'package:group_task_planner/services/firebase_auth_service.dart';
import 'package:group_task_planner/services/firestore_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authService: FirebaseAuthService(),
    firestoreService: FirestoreService(),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

final userProfileProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  return ref.watch(authRepositoryProvider).getUser(userId);
});

final currentUserProfileProvider = Provider<AsyncValue<UserModel?>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const AsyncValue.data(null);
  return ref.watch(userProfileProvider(userId));
});
