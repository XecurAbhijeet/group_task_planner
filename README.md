# Task Tracker – Shared Task Tracker for Roommates & Pet Care

A production-quality Flutter mobile app with Firebase backend. Users join groups (e.g. roommates, pet care), create shared tasks, complete them, track streaks, and view a group leaderboard.

## Tech Stack

- **Flutter** (latest stable) – Android & iOS
- **Firebase**: Auth, Cloud Firestore, Cloud Messaging, Cloud Functions (optional)
- **State**: Riverpod
- **Navigation**: go_router
- **Architecture**: Clean architecture, repository pattern, feature-based structure

## Setup

1. **Flutter**
   - Install [Flutter](https://flutter.dev) and run `flutter pub get`.

2. **Firebase**
   - Create a project at [Firebase Console](https://console.firebase.google.com).
   - Add Android and iOS apps; download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into the project.
   - Enable **Authentication** (Email/Password and Google).
   - Create **Cloud Firestore** (start in test mode or set rules as below).
   - Enable **Cloud Messaging** for notifications.

3. **Firestore indexes**
   - Deploy indexes so queries work:
   ```bash
   firebase deploy --only firestore:indexes
   ```
   - Or create the indexes from the Firebase Console when the app first runs (links will appear in the debug console).

4. **Run**
   ```bash
   flutter run
   ```

## Firestore security rules (example)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /groups/{groupId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null;
    }
    match /tasks/{taskId} {
      allow read, create, update, delete: if request.auth != null;
    }
    match /task_logs/{logId} {
      allow read, create: if request.auth != null;
    }
    match /group_scores/{scoreId} {
      allow read, create, update: if request.auth != null;
    }
    match /user_task_stats/{statId} {
      allow read, create, update: if request.auth != null;
    }
  }
}
```

## Sample data (development)

You can seed Firestore manually for testing:

1. **Group**  
   - Collection: `groups`  
   - Document: e.g. `flat402`  
   - Fields: `name`: "Flat 402", `invite_code`: "FISH4821", `created_by`: \<uid\>, `members`: [\<uid\>]

2. **Task**  
   - Collection: `tasks`  
   - Fields: `group_id`: \<groupId\>, `title`: "Feed Captain", `interval_hours`: 24, `points`: 10, `created_by`: \<uid\>

3. **Leaderboard**  
   - Collection: `group_scores`  
   - Documents with `group_id`, `user_id`, `points` (e.g. 140, 120), `tasks_completed`

Ensure `users/<uid>` exists with `name`, `email`, `joined_groups` (array of group IDs).

## Project structure

```
lib/
  core/           # theme, constants, utils, router
  features/
    auth/          # login, signup, splash, repository, providers
    groups/        # create/join group, selection, repository, providers
    tasks/         # home, manage tasks, complete task, repository, providers
    leaderboard/   # group leaderboard screen
    history/       # task log history screen
    settings/      # profile, groups, notifications, logout
  models/          # User, Group, Task, TaskLog, GroupScore, UserTaskStat
  services/        # Firebase Auth, Firestore, FCM
  widgets/         # TaskCard, LeaderboardTile, UserAvatar, StreakBadge
  screens/         # HomeShellScreen (bottom nav)
  main.dart
```

## Notifications

FCM is initialized in the app. To send “task overdue” notifications (e.g. “Captain is hungry 🐟”), implement a scheduled Cloud Function that checks overdue tasks and sends messages to group members. A placeholder is in `functions/`.

## License

Private / none.
