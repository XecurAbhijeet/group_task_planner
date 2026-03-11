import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> joinedGroups;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.joinedGroups = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'joined_groups': joinedGroups,
    };
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      joinedGroups: List<String>.from(data['joined_groups'] as List? ?? []),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? joinedGroups,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinedGroups: joinedGroups ?? this.joinedGroups,
    );
  }
}
