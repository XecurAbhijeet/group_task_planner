import 'package:flutter/material.dart';
import 'package:group_task_planner/core/constants/app_colors.dart';
import 'package:group_task_planner/widgets/user_avatar.dart';

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.userName,
    required this.points,
    required this.tasksCompleted,
  });

  final int rank;
  final String userName;
  final int points;
  final int tasksCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$rank',
              style: theme.textTheme.titleMedium?.copyWith(
                color: rank <= 3 ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            UserAvatar(name: userName, size: 40),
          ],
        ),
        title: Text(
          userName,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '$tasksCompleted tasks completed',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          '$points pts',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
