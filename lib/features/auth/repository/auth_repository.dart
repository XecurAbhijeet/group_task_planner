import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_task_planner/models/user_model.dart';
import 'package:group_task_planner/services/firebase_auth_service.dart';
import 'package:group_task_planner/services/firestore_service.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuthService? authService,
    FirestoreService? firestoreService,
  })  : _auth = authService ?? FirebaseAuthService(),
        _firestore = firestoreService ?? FirestoreService();

  final FirebaseAuthService _auth;
  final FirestoreService _firestore;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUserId;
  Stream<User?> get authStateChanges => _auth.authStateChanges;

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmail(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.signUpWithEmail(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    final cred = await _auth.signInWithGoogle();
    if (cred == null) throw Exception('Google sign in cancelled');
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    await _firestore.userDoc(userId).set({
      'name': name,
      'email': email,
      'joined_groups': <String>[],
    });
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.userDoc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUserJoinedGroups(String userId, List<String> groupIds) async {
    await _firestore.userDoc(userId).update({'joined_groups': groupIds});
  }
}
