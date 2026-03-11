import 'package:cloud_firestore/cloud_firestore.dart';

class UserTaskStatModel {
  final String id;
  final String groupId;
  final String userId;
  final String taskId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;

  const UserTaskStatModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.taskId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'user_id': userId,
      'task_id': taskId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_completed_date': lastCompletedDate != null
          ? Timestamp.fromDate(lastCompletedDate!)
          : null,
    };
  }

  factory UserTaskStatModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final lastCompleted = data['last_completed_date'] as Timestamp?;
    return UserTaskStatModel(
      id: doc.id,
      groupId: data['group_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      taskId: data['task_id'] as String? ?? '',
      currentStreak: (data['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (data['longest_streak'] as num?)?.toInt() ?? 0,
      lastCompletedDate: lastCompleted?.toDate(),
    );
  }
}
