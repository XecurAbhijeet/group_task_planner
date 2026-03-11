import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String groupId;
  final String title;
  final int intervalHours;
  final int points;
  final String createdBy;
  final DateTime? createdAt;

  const TaskModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.intervalHours,
    required this.points,
    required this.createdBy,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'title': title,
      'interval_hours': intervalHours,
      'points': points,
      'created_by': createdBy,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAt = data['created_at'] as Timestamp?;
    return TaskModel(
      id: doc.id,
      groupId: data['group_id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      intervalHours: (data['interval_hours'] as num?)?.toInt() ?? 24,
      points: (data['points'] as num?)?.toInt() ?? 10,
      createdBy: data['created_by'] as String? ?? '',
      createdAt: createdAt?.toDate(),
    );
  }
}
