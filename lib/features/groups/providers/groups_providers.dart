import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_task_planner/features/auth/providers/auth_providers.dart';
import 'package:group_task_planner/features/groups/repository/groups_repository.dart';
import 'package:group_task_planner/models/group_model.dart';
import 'package:group_task_planner/services/firestore_service.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository(
    firestore: FirestoreService(),
    auth: ref.watch(authRepositoryProvider),
  );
});

final userGroupsProvider = FutureProvider<List<GroupModel>>((ref) {
  return ref.watch(groupsRepositoryProvider).getGroupsForUser();
});

final selectedGroupIdProvider = StateProvider<String?>((ref) => null);

final selectedGroupProvider = StreamProvider<GroupModel?>((ref) {
  final groupId = ref.watch(selectedGroupIdProvider);
  if (groupId == null) return Stream.value(null);
  return ref.watch(groupsRepositoryProvider).watchGroup(groupId);
});
