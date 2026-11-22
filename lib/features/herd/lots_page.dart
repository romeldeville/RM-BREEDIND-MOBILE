import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class LotsPage extends ConsumerStatefulWidget {
  const LotsPage({super.key});

  @override
  ConsumerState<LotsPage> createState() => _LotsPageState();
}

class _LotsPageState extends ConsumerState<LotsPage> {
  List<Lot> _lots = const [];
  List<Species> _species = const [];
  String _status = '';
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
      final page = await ref.read(herdRepositoryProvider).lots(status: _status);
      final species = await ref.read(referentialRepositoryProvider).species();
      if (mounted) {
        setState(() {
          _lots = page.items;
          _species = species;
        });
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

  String _speciesName(String id) {
    for (final species in _species) {
      if (species.id == id) {
        return species.name;
      }
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const Text(
            'Lots et effectifs.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await context.push('/lots/new');
                    if (mounted) {
                      _load();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau lot'),
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _status.isEmpty ? 'ALL' : _status,
                  decoration: const InputDecoration(labelText: 'Statut'),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('Tous')),
                    DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                    DropdownMenuItem(value: 'CLOSED', child: Text('CLOSED')),
                  ],
                  onChanged: (value) {
                    setState(() => _status = value == 'ALL' ? '' : (value ?? ''));
                    _load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Column(
              children: [
                Text(_error!, style: const TextStyle(color: AppTokens.danger)),
                const SizedBox(height: AppTokens.space2),
                OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
              ],
            )
          else if (_lots.isEmpty)
            const EmptyState(message: 'Aucun lot enregistré', icon: Icons.inventory_2)
          else
            for (final lot in _lots)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTokens.background,
                    child: Text(lot.name.isEmpty ? '?' : lot.name.substring(0, 1)),
                  ),
                  title: Text(lot.name),
                  subtitle: Text(
                    '${_speciesName(lot.speciesId)} · ${lot.currentCount}/${lot.initialCount} · ${lot.status}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await context.push('/lots/${lot.id}');
                    if (mounted) {
                      _load();
                    }
                  },
                ),
              ),
        ],
      ),
    );
  }
}
