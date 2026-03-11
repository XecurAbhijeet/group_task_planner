import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:group_task_planner/core/constants/app_colors.dart';
import 'package:group_task_planner/features/groups/providers/groups_providers.dart';
import 'package:group_task_planner/models/group_score_model.dart';
import 'package:group_task_planner/services/firestore_service.dart';
import 'package:group_task_planner/widgets/leaderboard_tile.dart';

final _firestore = FirestoreService();

final groupScoresStreamProvider = StreamProvider.autoDispose<List<GroupScoreModel>>((ref) {
  final groupId = ref.watch(selectedGroupIdProvider);
  if (groupId == null) return Stream.value([]);
  return _firestore.groupScores
      .where('group_id', isEqualTo: groupId)
      .orderBy('points', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => GroupScoreModel.fromFirestore(d)).toList());
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(selectedGroupProvider);
    final scoresAsync = ref.watch(groupScoresStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: groupAsync.whenOrNull(
          data: (g) => Text('${g?.name ?? 'Group'} · Leaderboard'),
        ) ?? const Text('Leaderboard'),
      ),
      body: groupAsync.when(
        data: (group) {
          if (group == null) {
            return const Center(child: Text('Select a group'));
          }
          return scoresAsync.when(
            data: (scores) {
              if (scores.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.leaderboard_rounded,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No scores yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                );
              }
              return LeaderboardContent(scores: scores);
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

class LeaderboardContent extends ConsumerWidget {
  const LeaderboardContent({super.key, required this.scores});

  final List<GroupScoreModel> scores;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = FirestoreService();
    return FutureBuilder<Map<String, String>>(
      future: _loadNames(firestore, scores.map((s) => s.userId).toList()),
      builder: (context, nameSnap) {
        final names = nameSnap.data ?? {};
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: scores.length,
          itemBuilder: (context, index) {
            final score = scores[index];
            final name = names[score.userId] ?? score.userId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LeaderboardTile(
                rank: index + 1,
                userName: name,
                points: score.points,
                tasksCompleted: score.tasksCompleted,
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>> _loadNames(
    FirestoreService firestore,
    List<String> userIds,
  ) async {
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
