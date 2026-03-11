import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_task_planner/core/utils/date_utils.dart';
import 'package:group_task_planner/features/auth/providers/auth_providers.dart';
import 'package:group_task_planner/features/groups/providers/groups_providers.dart';
import 'package:group_task_planner/features/tasks/repository/tasks_repository.dart';
import 'package:group_task_planner/models/task_log_model.dart';
import 'package:group_task_planner/models/task_model.dart';
import 'package:group_task_planner/services/firestore_service.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository(
    firestore: FirestoreService(),
    auth: ref.watch(authRepositoryProvider),
  );
});

final groupTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final groupId = ref.watch(selectedGroupIdProvider);
  if (groupId == null) return Stream.value([]);
  return ref.watch(tasksRepositoryProvider).watchTasksForGroup(groupId);
});

final groupTaskLogsProvider = StreamProvider<List<TaskLogModel>>((ref) {
  final groupId = ref.watch(selectedGroupIdProvider);
  if (groupId == null) return Stream.value([]);
  return ref.watch(tasksRepositoryProvider).watchTaskLogsForGroup(groupId);
});

/// Latest log per task id (any date) for display "Last completed by X at Y".
final latestLogByTaskIdProvider = Provider<AsyncValue<Map<String, TaskLogModel?>>>((ref) {
  final logsAsync = ref.watch(groupTaskLogsProvider);
  return logsAsync.when(
    data: (logs) {
      final byTask = <String, TaskLogModel?>{};
      for (final log in logs) {
        if (!byTask.containsKey(log.taskId)) byTask[log.taskId] = log;
      }
      return AsyncValue.data(byTask);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// For each task id, whether it was completed today.
final completedTodayByTaskIdProvider = Provider<AsyncValue<Map<String, bool>>>((ref) {
  final logsAsync = ref.watch(groupTaskLogsProvider);
  return logsAsync.when(
    data: (logs) {
      final map = <String, bool>{};
      for (final log in logs) {
        if (log.dateKey == todayKey) map[log.taskId] = true;
      }
      return AsyncValue.data(map);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Current user's streak per task id for the selected group.
final currentUserStreaksByTaskIdProvider = StreamProvider<Map<String, int>>((ref) {
  final groupId = ref.watch(selectedGroupIdProvider);
  if (groupId == null) return Stream.value({});
  return ref.watch(tasksRepositoryProvider).watchCurrentUserStreaksByTaskId(groupId);
});
