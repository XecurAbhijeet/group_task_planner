import 'package:flutter/material.dart';
import 'package:group_task_planner/core/constants/app_colors.dart';
import 'package:group_task_planner/models/task_log_model.dart';
import 'package:group_task_planner/models/task_model.dart';
import 'package:group_task_planner/widgets/streak_badge.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.lastLog,
    this.completedToday = false,
    this.completedByName,
    this.currentStreak,
    required this.onComplete,
  });

  final TaskModel task;
  final TaskLogModel? lastLog;
  final bool completedToday;
  final String? completedByName;
  final int? currentStreak;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (currentStreak != null && currentStreak! > 0)
                  StreakBadge(streak: currentStreak!),
              ],
            ),
            if (task.intervalHours > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Every ${task.intervalHours}h • ${task.points} pts',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (lastLog != null || completedToday) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      completedToday ? Icons.check_circle : Icons.schedule,
                      size: 16,
                      color: completedToday
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      completedToday && completedByName != null
                          ? 'Completed by $completedByName'
                          : lastLog != null
                              ? 'Last: ${DateFormat.MMMd().add_Hm().format(lastLog!.completedAt)}'
                              : 'Not completed today',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: completedToday ? null : onComplete,
                icon: Icon(completedToday ? Icons.check : Icons.done_all),
                label: Text(completedToday ? 'Done for today' : 'Complete task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
