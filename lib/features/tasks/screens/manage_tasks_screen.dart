import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:group_task_planner/core/constants/app_colors.dart';
import 'package:group_task_planner/features/groups/providers/groups_providers.dart';
import 'package:group_task_planner/features/tasks/providers/tasks_providers.dart';

class ManageTasksScreen extends ConsumerStatefulWidget {
  const ManageTasksScreen({super.key});

  @override
  ConsumerState<ManageTasksScreen> createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends ConsumerState<ManageTasksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  final _intervalController = TextEditingController(text: '24');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    final groupId = ref.read(selectedGroupIdProvider);
    if (groupId == null) {
      setState(() => _errorMessage = 'Select a group first');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final points = int.tryParse(_pointsController.text) ?? 10;
      final interval = int.tryParse(_intervalController.text) ?? 24;
      await ref.read(tasksRepositoryProvider).createTask(
            groupId: groupId,
            title: _titleController.text.trim(),
            intervalHours: interval,
            points: points,
          );
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task name',
                    hintText: 'e.g. Feed Captain',
                    prefixIcon: Icon(Icons.task_alt_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter task name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Points',
                    prefixIcon: Icon(Icons.star_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter points';
                    if (int.tryParse(v) == null) return 'Enter a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _intervalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Interval (hours)',
                    hintText: '24',
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter interval';
                    if (int.tryParse(v) == null) return 'Enter a number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _createTask,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
