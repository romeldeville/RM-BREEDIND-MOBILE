import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/alerts/alerts_repository.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'alerts_shared.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _dueDate = TextEditingController(text: todayDate());

  List<Task> _tasks = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _dueDate.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await ref.read(alertsRepositoryProvider).tasks();
      if (mounted) {
        setState(() => _tasks = tasks);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Titre requis.');
      return;
    }
    final dueDate = normalizeDate(_dueDate.text);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(alertsRepositoryProvider).createTask({
        'title': title,
        if (_description.text.trim().isNotEmpty)
          'description': _description.text.trim(),
        'dueDate': ?dueDate,
      });
      _title.clear();
      _description.clear();
      _dueDate.text = todayDate();
      await _load();
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _complete(Task task) async {
    try {
      await ref.read(alertsRepositoryProvider).completeTask(task.id);
      await _load();
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tâches')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouvelle tâche',
              child: Column(
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: AppTokens.danger),
                    ),
                    const SizedBox(height: AppTokens.space2),
                  ],
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Titre'),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  TextField(
                    controller: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  TextField(
                    controller: _dueDate,
                    decoration: const InputDecoration(
                      labelText: 'Échéance (AAAA-MM-JJ)',
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Tâches enregistrées',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                      ? const EmptyState(
                          message: 'Aucune tâche',
                          icon: Icons.checklist_outlined,
                        )
                      : Column(
                          children: [
                            for (final task in _tasks)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: AppTokens.background,
                                  child: Icon(Icons.checklist_outlined),
                                ),
                                title: Text(task.title),
                                subtitle: Text(
                                  '${taskStatusLabel(task.status)} · ${formatDate(task.dueDate)}',
                                ),
                                trailing: task.status == 'OPEN'
                                    ? IconButton(
                                        icon: const Icon(Icons.check_outlined),
                                        onPressed: () => _complete(task),
                                      )
                                    : null,
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
