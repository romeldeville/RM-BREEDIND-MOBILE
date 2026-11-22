import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/notifications/notification_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

const _typeLabels = <String, String>{
  'PREGNANCY_DIAGNOSIS_DUE': 'Diagnostic de gestation',
  'FARROWING_DUE': 'Mise bas',
  'WEANING_DUE': 'Sevrage',
  'HEAT_RETURN': 'Retour en chaleur',
  'WITHDRAWAL_START': 'Début de délai d’attente',
  'WITHDRAWAL_END': 'Fin de délai d’attente',
  'QUARANTINE_END': 'Fin de quarantaine',
  'WEIGHING_DUE': 'Pesée due',
  'OVERCROWDING': 'Surpeuplement',
  'PAYMENT_OVERDUE': 'Paiement en retard',
  'LOW_STOCK': 'Stock bas',
  'FEED_EXPIRY': 'Péremption d’aliment',
  'LAYING_DROP': 'Baisse de ponte',
  'DAILY_DIGEST': 'Résumé quotidien',
};

const _channelLabels = <String, String>{
  'PUSH': 'Push',
  'EMAIL': 'E-mail',
};

/// P15-10 - per-alert-type push and e-mail preferences.
class NotificationPreferencesPage extends ConsumerStatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  ConsumerState<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends ConsumerState<NotificationPreferencesPage> {
  List<NotificationPreference> _items = const [];
  bool _loading = true;
  bool _saving = false;
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
      final items =
          await ref.read(notificationRepositoryProvider).preferences();
      if (mounted) {
        setState(() => _items = items);
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.message);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _toggle(String key, bool value) {
    setState(() {
      _items = [
        for (final item in _items)
          if (item.key == key) item.copyWith(enabled: value) else item,
      ];
    });
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final items = await ref
          .read(notificationRepositoryProvider)
          .updatePreferences(_items);
      if (mounted) {
        setState(() => _items = items);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préférences enregistrées.')),
        );
      }
    } on ApiFailure catch (failure) {
      if (mounted) {
        setState(() => _error = failure.message);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: AppTokens.danger)),
              const SizedBox(height: AppTokens.space3),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    final groups = <String, List<NotificationPreference>>{};
    for (final item in _items) {
      groups.putIfAbsent(item.type, () => []).add(item);
    }
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        SectionCard(
          title: 'Notifications',
          child: const Text(
            'Choisissez les alertes reçues sur cet appareil (push) et par '
            'e-mail. Par défaut, tous les canaux sont activés.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        for (final entry in groups.entries) ...[
          SectionCard(
            title: _typeLabels[entry.key] ?? entry.key,
            child: Column(
              children: [
                for (final item in entry.value)
                  SwitchListTile(
                    key: Key('pref-${item.type}-${item.channel}'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(_channelLabels[item.channel] ?? item.channel),
                    value: item.enabled,
                    onChanged: (value) => _toggle(item.key, value),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space4),
        ],
        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: AppTokens.danger)),
          const SizedBox(height: AppTokens.space3),
        ],
        FilledButton.icon(
          onPressed: _saving || _items.isEmpty ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Enregistrement…' : 'Enregistrer'),
        ),
      ],
    );
  }
}
