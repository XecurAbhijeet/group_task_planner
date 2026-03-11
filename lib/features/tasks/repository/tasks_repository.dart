import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_task_planner/core/utils/date_utils.dart' as app_date_utils;
import 'package:group_task_planner/features/auth/repository/auth_repository.dart';
import 'package:group_task_planner/models/group_score_model.dart';
import 'package:group_task_planner/models/task_log_model.dart';
import 'package:group_task_planner/models/task_model.dart';
import 'package:group_task_planner/models/user_task_stat_model.dart';
import 'package:group_task_planner/services/firestore_service.dart';

class TasksRepository {
  TasksRepository({
    FirestoreService? firestore,
    AuthRepository? auth,
  })  : _firestore = firestore ?? FirestoreService(),
        _auth = auth ?? AuthRepository();

  final FirestoreService _firestore;
  final AuthRepository _auth;

  Future<TaskModel> createTask({
    required String groupId,
    required String title,
    required int intervalHours,
    required int points,
  }) async {
    final userId = _auth.currentUserId;
    if (userId == null) throw Exception('Not authenticated');
    final task = TaskModel(
      id: '',
      groupId: groupId,
      title: title,
      intervalHours: intervalHours,
      points: points,
      createdBy: userId,
      createdAt: DateTime.now(),
    );
    final ref = await _firestore.tasks.add(task.toMap());
    await _firestore.tasks.doc(ref.id).update({
      'created_at': FieldValue.serverTimestamp(),
    });
    return TaskModel(
      id: ref.id,
      groupId: task.groupId,
      title: task.title,
      intervalHours: task.intervalHours,
      points: task.points,
      createdBy: task.createdBy,
      createdAt: DateTime.now(),
    );
  }

  Stream<List<TaskModel>> watchTasksForGroup(String groupId) {
    return _firestore.tasks
        .where('group_id', isEqualTo: groupId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TaskModel.fromFirestore(d)).toList());
  }

  Future<TaskLogModel?> getLatestLogForTask(String taskId, String dateKey) async {
    final snap = await _firestore.taskLogs
        .where('task_id', isEqualTo: taskId)
        .where('date_key', isEqualTo: dateKey)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return TaskLogModel.fromFirestore(snap.docs.first);
  }

  Future<bool> isTaskCompletedToday(String taskId) async {
    final log = await getLatestLogForTask(taskId, app_date_utils.todayKey);
    return log != null;
  }

  Future<TaskLogModel?> getLatestLogForTaskAnyDate(String taskId) async {
    final snap = await _firestore.taskLogs
        .where('task_id', isEqualTo: taskId)
        .orderBy('completed_at', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return TaskLogModel.fromFirestore(snap.docs.first);
  }

  Future<UserTaskStatModel?> getOrCreateUserTaskStat({
    required String groupId,
    required String userId,
    required String taskId,
  }) async {
    final snap = await _firestore.userTaskStats
        .where('group_id', isEqualTo: groupId)
        .where('user_id', isEqualTo: userId)
        .where('task_id', isEqualTo: taskId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return UserTaskStatModel.fromFirestore(snap.docs.first);
    }
    final stat = UserTaskStatModel(
      id: '',
      groupId: groupId,
      userId: userId,
      taskId: taskId,
      currentStreak: 0,
      longestStreak: 0,
    );
    final ref = await _firestore.userTaskStats.add(stat.toMap());
    return UserTaskStatModel(
      id: ref.id,
      groupId: stat.groupId,
      userId: stat.userId,
      taskId: stat.taskId,
      currentStreak: stat.currentStreak,
      longestStreak: stat.longestStreak,
    );
  }

  Future<GroupScoreModel?> getOrCreateGroupScore(String groupId, String userId) async {
    final snap = await _firestore.groupScores
        .where('group_id', isEqualTo: groupId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return GroupScoreModel.fromFirestore(snap.docs.first);
    }
    final score = GroupScoreModel(
      id: '',
      groupId: groupId,
      userId: userId,
      points: 0,
      tasksCompleted: 0,
    );
    final ref = await _firestore.groupScores.add(score.toMap());
    return GroupScoreModel(
      id: ref.id,
      groupId: score.groupId,
      userId: score.userId,
      points: score.points,
      tasksCompleted: score.tasksCompleted,
    );
  }

  Future<void> completeTask({
    required String taskId,
    required String groupId,
    required TaskModel task,
  }) async {
    final userId = _auth.currentUserId;
    if (userId == null) throw Exception('Not authenticated');
    final today = app_date_utils.todayKey;
    final existing = await getLatestLogForTask(taskId, today);
    if (existing != null) throw Exception('Task already completed today');

    final now = DateTime.now();
    final log = TaskLogModel(
      id: '',
      taskId: taskId,
      groupId: groupId,
      completedBy: userId,
      completedAt: now,
      dateKey: today,
    );
    await _firestore.taskLogs.add(log.toMap());

    final stat = await getOrCreateUserTaskStat(
      groupId: groupId,
      userId: userId,
      taskId: taskId,
    );
    final lastDate = stat?.lastCompletedDate;
    int newStreak = 1;
    if (lastDate != null && app_date_utils.isYesterday(lastDate)) {
      newStreak = (stat!.currentStreak + 1);
    }
    final newLongest = newStreak > (stat?.longestStreak ?? 0)
        ? newStreak
        : (stat?.longestStreak ?? 0);
    if (stat != null) {
      await _firestore.userTaskStats.doc(stat.id).update({
        'current_streak': newStreak,
        'longest_streak': newLongest,
        'last_completed_date': Timestamp.fromDate(now),
      });
    } else {
      final newStat = UserTaskStatModel(
        id: '',
        groupId: groupId,
        userId: userId,
        taskId: taskId,
        currentStreak: newStreak,
        longestStreak: newLongest,
        lastCompletedDate: now,
      );
      final ref = await _firestore.userTaskStats.add(newStat.toMap());
      await _firestore.userTaskStats.doc(ref.id).update({
        'last_completed_date': Timestamp.fromDate(now),
      });
    }

    final scoreDoc = await getOrCreateGroupScore(groupId, userId);
    if (scoreDoc != null) {
      await _firestore.groupScores.doc(scoreDoc.id).update({
        'points': FieldValue.increment(task.points),
        'tasks_completed': FieldValue.increment(1),
      });
    } else {
      await _firestore.groupScores.add({
        'group_id': groupId,
        'user_id': userId,
        'points': task.points,
        'tasks_completed': 1,
      });
    }
  }

  Stream<List<TaskLogModel>> watchTaskLogsForGroup(String groupId, {int limit = 50}) {
    return _firestore.taskLogs
        .where('group_id', isEqualTo: groupId)
        .orderBy('completed_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskLogModel.fromFirestore(d)).toList());
  }

  Stream<Map<String, int>> watchCurrentUserStreaksByTaskId(String groupId) {
    final userId = _auth.currentUserId;
    if (userId == null) return Stream.value({});
    return _firestore.userTaskStats
        .where('group_id', isEqualTo: groupId)
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final map = <String, int>{};
      for (final doc in snap.docs) {
        final stat = UserTaskStatModel.fromFirestore(doc);
        map[stat.taskId] = stat.currentStreak;
      }
      return map;
    });
  }
}
