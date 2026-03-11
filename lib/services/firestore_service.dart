import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_task_planner/core/constants/firestore_paths.dart';

/// Central Firestore instance and batch/transaction helpers.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get users =>
      _firestore.collection(FirestorePaths.users);
  CollectionReference<Map<String, dynamic>> get groups =>
      _firestore.collection(FirestorePaths.groups);
  CollectionReference<Map<String, dynamic>> get tasks =>
      _firestore.collection(FirestorePaths.tasks);
  CollectionReference<Map<String, dynamic>> get taskLogs =>
      _firestore.collection(FirestorePaths.taskLogs);
  CollectionReference<Map<String, dynamic>> get groupScores =>
      _firestore.collection(FirestorePaths.groupScores);
  CollectionReference<Map<String, dynamic>> get userTaskStats =>
      _firestore.collection(FirestorePaths.userTaskStats);

  DocumentReference<Map<String, dynamic>> userDoc(String userId) =>
      users.doc(userId);
  DocumentReference<Map<String, dynamic>> groupDoc(String groupId) =>
      groups.doc(groupId);
  DocumentReference<Map<String, dynamic>> taskDoc(String taskId) =>
      tasks.doc(taskId);
}
