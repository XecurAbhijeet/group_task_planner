/// Firestore collection and document path constants.
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String groups = 'groups';
  static const String tasks = 'tasks';
  static const String taskLogs = 'task_logs';
  static const String groupScores = 'group_scores';
  static const String userTaskStats = 'user_task_stats';

  static String userDoc(String userId) => '$users/$userId';
  static String groupDoc(String groupId) => '$groups/$groupId';
  static String taskDoc(String taskId) => '$tasks/$taskId';
  static String taskLogDoc(String logId) => '$taskLogs/$logId';
  static String groupScoreDoc(String scoreId) => '$groupScores/$scoreId';
  static String userTaskStatDoc(String statId) => '$userTaskStats/$statId';
}
