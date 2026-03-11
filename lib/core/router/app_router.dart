import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_task_planner/features/auth/screens/login_screen.dart';
import 'package:group_task_planner/features/auth/screens/signup_screen.dart';
import 'package:group_task_planner/features/auth/screens/splash_screen.dart';
import 'package:group_task_planner/features/groups/screens/create_group_screen.dart';
import 'package:group_task_planner/features/groups/screens/group_selection_screen.dart';
import 'package:group_task_planner/features/groups/screens/join_group_screen.dart';
import 'package:group_task_planner/features/history/screens/history_screen.dart';
import 'package:group_task_planner/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:group_task_planner/features/settings/screens/settings_screen.dart';
import 'package:group_task_planner/features/tasks/screens/home_screen.dart';
import 'package:group_task_planner/features/tasks/screens/manage_tasks_screen.dart';
import 'package:group_task_planner/screens/home_shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/group-selection',
        builder: (context, state) => const GroupSelectionScreen(),
      ),
      GoRoute(
        path: '/create-group',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: '/join-group',
        builder: (context, state) => const JoinGroupScreen(),
      ),
      GoRoute(
        path: '/manage-tasks',
        builder: (context, state) => const ManageTasksScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leaderboard',
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) => const LeaderboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                parentNavigatorKey: _shellNavigatorKey,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
