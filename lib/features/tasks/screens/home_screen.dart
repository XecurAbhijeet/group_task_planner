import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:group_task_planner/core/constants/app_colors.dart';
import 'package:group_task_planner/features/groups/providers/groups_providers.dart';
import 'package:group_task_planner/features/tasks/providers/tasks_providers.dart';
import 'package:group_task_planner/models/task_model.dart';
import 'package:group_task_planner/services/firestore_service.dart';
import 'package:group_task_planner/widgets/task_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(selectedGroupProvider);
    final tasksAsync = ref.watch(groupTasksProvider);
    final latestLogs = ref.watch(latestLogByTaskIdProvider);
    final completedToday = ref.watch(completedTodayByTaskIdProvider);
    final streaksAsync = ref.watch(currentUserStreaksByTaskIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: groupAsync.whenOrNull(
          data: (g) => Text(g?.name ?? 'Task Tracker'),
        ) ?? const Text('Task Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_rounded),
            onPressed: () => context.push('/group-selection'),
          ),
        ],
      ),
      body: groupAsync.when(
        data: (group) {
          if (group == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_off_rounded, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text('No group selected'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/group-selection'),
                    child: const Text('Choose group'),
                  ),
                ],
              ),
            );
          }
          return tasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 80,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No tasks yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first task',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.push('/manage-tasks'),
                          icon: const Icon(Icons.add),
                          label: const Text('Create task'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final latestMap = latestLogs.valueOrNull ?? {};
              final completedMap = completedToday.valueOrNull ?? {};
              final streaksMap = streaksAsync.valueOrNull ?? {};
              final names = <String, String>{};
              return FutureBuilder<Map<String, String>>(
                future: _loadUserNames(
                  ref,
                  latestMap.values
                      .where((e) => e != null)
                      .map((e) => e!.completedBy)
                      .where((id) => id.isNotEmpty)
                      .toSet()
                      .toList(),
                ),
                builder: (context, nameSnap) {
                  if (nameSnap.hasData) {
                    for (final e in nameSnap.data!.entries) {
                      names[e.key] = e.value;
                    }
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final lastLog = latestMap[task.id];
                      final doneToday = completedMap[task.id] ?? false;
                      final completedByName = doneToday && lastLog != null
                          ? (names[lastLog.completedBy] ?? lastLog.completedBy)
                          : null;
                      final streak = streaksMap[task.id];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TaskCard(
                          task: task,
                          lastLog: lastLog,
                          completedToday: doneToday,
                          completedByName: completedByName,
                          currentStreak: streak,
                          onComplete: () => _completeTask(ref, task),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, st) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(e.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(groupTasksProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }

  Future<void> _completeTask(WidgetRef ref, TaskModel task) async {
    try {
      await ref.read(tasksRepositoryProvider).completeTask(
            taskId: task.id,
            groupId: task.groupId,
            task: task,
          );
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<Map<String, String>> _loadUserNames(
    WidgetRef ref,
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};
    final firestore = FirestoreService();
    final map = <String, String>{};
    for (final id in userIds) {
      final doc = await firestore.userDoc(id).get();
      if (doc.exists && doc.data() != null) {
        map[id] = doc.data()!['name'] as String? ?? id;
      } else {
        map[id] = id;
      }
    }
    return map;
  }
}
