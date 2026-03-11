import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:group_task_planner/core/constants/app_colors.dart';
import 'package:group_task_planner/features/auth/providers/auth_providers.dart';
import 'package:group_task_planner/features/groups/providers/groups_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final groupAsync = ref.watch(selectedGroupProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profileAsync.when(
            data: (profile) => ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(profile?.name ?? 'Profile'),
              subtitle: Text(profile?.email ?? ''),
              onTap: () {},
            ),
            loading: () => const ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Loading...'),
            ),
            error: (error, stackTrace) => const ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Profile'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.group_rounded),
            title: const Text('Groups'),
            subtitle: Text(groupAsync.whenOrNull(data: (g) => g?.name) ?? 'Select group'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/group-selection'),
          ),
          ListTile(
            leading: const Icon(Icons.task_alt_rounded),
            title: const Text('Manage tasks'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/manage-tasks'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_rounded),
            title: const Text('Notifications'),
            trailing: Switch(
              value: true,
              onChanged: (_) {},
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              await ref.read(authRepositoryProvider).signOut();
              ref.read(selectedGroupIdProvider.notifier).state = null;
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
