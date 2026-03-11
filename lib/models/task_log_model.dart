import 'package:cloud_firestore/cloud_firestore.dart';

class TaskLogModel {
  final String id;
  final String taskId;
  final String groupId;
  final String completedBy;
  final DateTime completedAt;
  final String dateKey;

  const TaskLogModel({
    required this.id,
    required this.taskId,
    required this.groupId,
    required this.completedBy,
    required this.completedAt,
    required this.dateKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'task_id': taskId,
      'group_id': groupId,
      'completed_by': completedBy,
      'completed_at': Timestamp.fromDate(completedAt),
      'date_key': dateKey,
    };
  }

  factory TaskLogModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final completedAt = data['completed_at'] as Timestamp?;
    return TaskLogModel(
      id: doc.id,
      taskId: data['task_id'] as String? ?? '',
      groupId: data['group_id'] as String? ?? '',
      completedBy: data['completed_by'] as String? ?? '',
      completedAt: completedAt?.toDate() ?? DateTime.now(),
      dateKey: data['date_key'] as String? ?? '',
    );
  }
}
