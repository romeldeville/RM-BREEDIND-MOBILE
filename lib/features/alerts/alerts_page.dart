import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/alerts/alerts_repository.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'alerts_shared.dart';

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> {
  List<Alert> _alerts = const [];
  String? _status;
  String? _priority;
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
      final alerts = await ref
          .read(alertsRepositoryProvider)
          .alerts(status: _status, priority: _priority);
      if (mounted) {
        setState(() => _alerts = alerts);
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
      _snack(error.message);
    }
  }

  Future<void> _cancel(Alert alert) async {
    final reason = await _promptText('Motif d\'annulation');
    if (reason == null || reason.isEmpty) {
      return;
    }
    try {
      await ref.read(alertsRepositoryProvider).cancel(alert.id, reason);
      await _load();
    } on ApiFailure catch (error) {
      _snack(error.message);
    }
  }

  Future<void> _postpone(Alert alert) async {
    final dueDate = await _promptText('Nouvelle échéance (AAAA-MM-JJ)',
        initial: alert.dueDate ?? todayDate());
    final normalized = dueDate == null ? null : normalizeDate(dueDate);
    if (normalized == null) {
      return;
    }
    final reason = await _promptText('Motif du report');
    if (reason == null || reason.isEmpty) {
      return;
    }
    try {
      await ref
          .read(alertsRepositoryProvider)
          .postpone(alert.id, dueDate: normalized, reason: reason);
      await _load();
    } on ApiFailure catch (error) {
      _snack(error.message);
    }
  }

  Future<String?> _promptText(String label, {String? initial}) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _snack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const Text(
            'Alertes métier et suivi des échéances.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [
              FilledButton.icon(
                onPressed: () => context.push('/alerts/today'),
                icon: const Icon(Icons.today_outlined),
                label: const Text('À faire aujourd\'hui'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/alerts/tasks'),
                icon: const Icon(Icons.checklist_outlined),
                label: const Text('Tâches'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Filtres',
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Toutes')),
                      DropdownMenuItem(value: 'OPEN', child: Text('Ouvertes')),
                      DropdownMenuItem(value: 'POSTPONED', child: Text('Reportées')),
                      DropdownMenuItem(value: 'CLOSED', child: Text('Clôturées')),
                      DropdownMenuItem(value: 'CANCELLED', child: Text('Annulées')),
                    ],
                    onChanged: (value) {
                      setState(() => _status = value);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: AppTokens.space3),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _priority,
                    decoration: const InputDecoration(labelText: 'Priorité'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Toutes')),
                      DropdownMenuItem(value: 'CRITICAL', child: Text('Critique')),
                      DropdownMenuItem(value: 'IMPORTANT', child: Text('Importante')),
                      DropdownMenuItem(value: 'INFO', child: Text('Information')),
                    ],
                    onChanged: (value) {
                      setState(() => _priority = value);
                      _load();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Alertes',
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Column(
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(color: AppTokens.danger),
                          ),
                          const SizedBox(height: AppTokens.space2),
                          OutlinedButton(
                            onPressed: _load,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      )
                    : _alerts.isEmpty
                        ? const EmptyState(
                            message: 'Aucune alerte',
                            icon: Icons.notifications_off_outlined,
                          )
                        : Column(
                            children: [
                              for (final alert in _alerts) _tile(alert),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Alert alert) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      isThreeLine: true,
      leading: CircleAvatar(
        backgroundColor: priorityColor(alert.priority).withValues(alpha: 0.12),
        child: Icon(
          Icons.notifications_active_outlined,
          color: priorityColor(alert.priority),
        ),
      ),
      title: Text(alert.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.message),
          const SizedBox(height: AppTokens.space1),
          Text(
            '${priorityLabel(alert.priority)} · ${alertStatusLabel(alert.status)} · ${formatDate(alert.dueDate)}',
            style: const TextStyle(color: AppTokens.textMuted, fontSize: 14),
          ),
        ],
      ),
      trailing: isAlertOpen(alert)
          ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'close') {
                  _close(alert);
                } else if (value == 'postpone') {
                  _postpone(alert);
                } else if (value == 'cancel') {
                  _cancel(alert);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'close', child: Text('Clôturer')),
                PopupMenuItem(value: 'postpone', child: Text('Reporter')),
                PopupMenuItem(value: 'cancel', child: Text('Annuler')),
              ],
            )
          : null,
    );
  }
}
