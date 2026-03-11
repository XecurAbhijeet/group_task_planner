import 'package:cloud_firestore/cloud_firestore.dart';

class GroupScoreModel {
  final String id;
  final String groupId;
  final String userId;
  final int points;
  final int tasksCompleted;

  const GroupScoreModel({
    required this.id,
    required this.groupId,
    required this.userId,
    this.points = 0,
    this.tasksCompleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'user_id': userId,
      'points': points,
      'tasks_completed': tasksCompleted,
    };
  }

  factory GroupScoreModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GroupScoreModel(
      id: doc.id,
      groupId: data['group_id'] as String? ?? '',
      userId: data['user_id'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      tasksCompleted: (data['tasks_completed'] as num?)?.toInt() ?? 0,
    );
  }

  GroupScoreModel copyWith({
    String? id,
    String? groupId,
    String? userId,
    int? points,
    int? tasksCompleted,
  }) {
    return GroupScoreModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
    );
  }
}
