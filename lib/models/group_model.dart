import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;
  final List<String> members;
  final DateTime? createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    this.members = const [],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'invite_code': inviteCode,
      'created_by': createdBy,
      'members': members,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  factory GroupModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final createdAt = data['created_at'] as Timestamp?;
    return GroupModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      inviteCode: data['invite_code'] as String? ?? '',
      createdBy: data['created_by'] as String? ?? '',
      members: List<String>.from(data['members'] as List? ?? []),
      createdAt: createdAt?.toDate(),
    );
  }

  bool get isAdmin => true; // Can be extended: check createdBy or roles map
}
