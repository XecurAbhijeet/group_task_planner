import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_task_planner/core/utils/invite_code_generator.dart';
import 'package:group_task_planner/features/auth/repository/auth_repository.dart';
import 'package:group_task_planner/models/group_model.dart';
import 'package:group_task_planner/services/firestore_service.dart';

class GroupsRepository {
  GroupsRepository({
    FirestoreService? firestore,
    AuthRepository? auth,
  })  : _firestore = firestore ?? FirestoreService(),
        _auth = auth ?? AuthRepository();

  final FirestoreService _firestore;
  final AuthRepository _auth;

  Future<GroupModel> createGroup(String name) async {
    final userId = _auth.currentUserId;
    if (userId == null) throw Exception('Not authenticated');
    String code;
    bool exists;
    do {
      code = generateInviteCode();
      final q = await _firestore.groups
          .where('invite_code', isEqualTo: code)
          .limit(1)
          .get();
      exists = q.docs.isNotEmpty;
    } while (exists);
    final members = [userId];
    final group = GroupModel(
      id: '',
      name: name,
      inviteCode: code,
      createdBy: userId,
      members: members,
      createdAt: DateTime.now(),
    );
    final ref = await _firestore.groups.add(group.toMap());
    await _firestore.groups.doc(ref.id).update({'created_at': FieldValue.serverTimestamp()});
    final user = await _auth.getUser(userId);
    final joined = user?.joinedGroups ?? [];
    if (!joined.contains(ref.id)) {
      await _auth.updateUserJoinedGroups(userId, [...joined, ref.id]);
    }
    return GroupModel(
      id: ref.id,
      name: group.name,
      inviteCode: group.inviteCode,
      createdBy: group.createdBy,
      members: group.members,
      createdAt: DateTime.now(),
    );
  }

  Future<GroupModel?> joinGroupByInviteCode(String inviteCode) async {
    final userId = _auth.currentUserId;
    if (userId == null) throw Exception('Not authenticated');
    final normalized = inviteCode.trim().toUpperCase();
    final q = await _firestore.groups
        .where('invite_code', isEqualTo: normalized)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    final group = GroupModel.fromFirestore(doc);
    if (group.members.contains(userId)) return group;
    await _firestore.groupDoc(doc.id).update({
      'members': FieldValue.arrayUnion([userId]),
    });
    final user = await _auth.getUser(userId);
    final joined = user?.joinedGroups ?? [];
    if (!joined.contains(doc.id)) {
      await _auth.updateUserJoinedGroups(userId, [...joined, doc.id]);
    }
    return GroupModel(
      id: group.id,
      name: group.name,
      inviteCode: group.inviteCode,
      createdBy: group.createdBy,
      members: [...group.members, userId],
      createdAt: group.createdAt,
    );
  }

  Future<List<GroupModel>> getGroupsForUser() async {
    final userId = _auth.currentUserId;
    if (userId == null) return [];
    final user = await _auth.getUser(userId);
    final ids = user?.joinedGroups ?? [];
    if (ids.isEmpty) return [];
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += 10) {
      chunks.add(ids.sublist(i, (i + 10 > ids.length) ? ids.length : i + 10));
    }
    final all = <GroupModel>[];
    for (final chunk in chunks) {
      final snap = await _firestore.groups
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        all.add(GroupModel.fromFirestore(doc));
      }
    }
    return all;
  }

  Stream<GroupModel?> watchGroup(String groupId) {
    return _firestore.groupDoc(groupId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return GroupModel.fromFirestore(doc);
      }
      return null;
    });
  }
}
