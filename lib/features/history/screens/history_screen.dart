import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_task_planner/core/constants/app_colors.dart';
import 'package:group_task_planner/features/groups/providers/groups_providers.dart';
import 'package:group_task_planner/features/tasks/providers/tasks_providers.dart';
import 'package:group_task_planner/models/task_log_model.dart';
import 'package:group_task_planner/services/firestore_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(selectedGroupProvider);
    final logsAsync = ref.watch(groupTaskLogsProvider);
    final tasksAsync = ref.watch(groupTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: groupAsync.whenOrNull(
          data: (g) => Text('${g?.name ?? 'Group'} · History'),
        ) ?? const Text('History'),
      ),
      body: groupAsync.when(
        data: (group) {
          if (group == null) {
            return const Center(child: Text('Select a group'));
          }
          return logsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No activity yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                );
              }
              return tasksAsync.when(
                data: (tasks) {
                  final taskMap = {for (final t in tasks) t.id: t};
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final task = taskMap[log.taskId];
                      return HistoryLogTile(
                        log: log,
                        taskTitle: task?.title ?? 'Task',
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, st) => Center(child: Text(e.toString())),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, st) => Center(child: Text(e.toString())),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class HistoryLogTile extends ConsumerWidget {
  const HistoryLogTile({
    super.key,
    required this.log,
    required this.taskTitle,
  });

  final TaskLogModel log;
  final String taskTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = FirestoreService();
    return FutureBuilder<String>(
      future: _userName(firestore, log.completedBy),
      builder: (context, snap) {
        final name = snap.data ?? log.completedBy;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.3),
              child: const Icon(Icons.check_circle, color: AppColors.primary),
            ),
            title: Text(
              '$name — $taskTitle',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            subtitle: Text(
              DateFormat.MMMd().add_jm().format(log.completedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        );
      },
    );
  }

  Future<String> _userName(FirestoreService firestore, String userId) async {
    final doc = await firestore.userDoc(userId).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['name'] as String? ?? userId;
    }
    return userId;
  }
}
