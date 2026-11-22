import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/alerts/alerts_repository.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'alerts_shared.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  TodayBundle _bundle = const TodayBundle();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bundle = await ref.read(alertsRepositoryProvider).today();
      if (mounted) {
        setState(() => _bundle = bundle);
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

  Future<void> _close(Alert alert) async {
    try {
      await ref.read(alertsRepositoryProvider).close(alert.id);
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
      appBar: AppBar(title: const Text('À faire aujourd\'hui')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Alertes du jour',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Text(
                          _error!,
                          style: const TextStyle(color: AppTokens.danger),
                        )
                      : _bundle.alerts.isEmpty
                          ? const EmptyState(
                              message: 'Aucune alerte, tout va bien',
                              icon: Icons.notifications_off_outlined,
                            )
                          : Column(
                              children: [
                                for (final alert in _bundle.alerts)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: priorityColor(alert.priority)
                                          .withValues(alpha: 0.12),
                                      child: Icon(
                                        Icons.notifications_active_outlined,
                                        color: priorityColor(alert.priority),
                                      ),
                                    ),
                                    title: Text(alert.title),
                                    subtitle: Text(
                                      '${priorityLabel(alert.priority)} · ${formatDate(alert.dueDate)}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.check_outlined),
                                      onPressed: () => _close(alert),
                                    ),
                                  ),
                              ],
                            ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Tâches du jour',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _bundle.tasks.isEmpty
                      ? const EmptyState(
                          message: 'Aucune tâche',
                          icon: Icons.checklist_outlined,
                        )
                      : Column(
                          children: [
                            for (final task in _bundle.tasks)
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
