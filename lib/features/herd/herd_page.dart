import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class HerdPage extends ConsumerStatefulWidget {
  const HerdPage({super.key});

  @override
  ConsumerState<HerdPage> createState() => _HerdPageState();
}

class _HerdPageState extends ConsumerState<HerdPage> {
  static const _statuses = [
    'ACTIVE',
    'QUARANTINED',
    'SOLD',
    'DEAD',
    'SLAUGHTERED',
    'TRANSFERRED',
    'ARCHIVED',
  ];

  final _search = TextEditingController();
  List<Animal> _animals = const [];
  List<Species> _species = const [];
  String _status = '';
  String _speciesFilter = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(herdRepositoryProvider);
      final page = await repository.animals(
        search: _search.text.trim(),
        status: _status,
        speciesId: _speciesFilter,
      );
      final species = await ref.read(referentialRepositoryProvider).species();
      if (mounted) {
        setState(() {
          _animals = page.items;
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
    return id.isEmpty ? '-' : id.substring(0, id.length < 8 ? id.length : 8);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const Text(
            'Animaux individuels et lots.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/herd/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvel animal'),
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              OutlinedButton.icon(
                onPressed: () => context.push('/lots'),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Lots'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Recherche',
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Identifiant ou nom',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _load,
                    ),
                  ),
                  onSubmitted: (_) => _load(),
                ),
                const SizedBox(height: AppTokens.space3),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status.isEmpty ? 'ALL' : _status,
                        decoration: const InputDecoration(labelText: 'Statut'),
                        items: [
                          const DropdownMenuItem(value: 'ALL', child: Text('Tous')),
                          for (final status in _statuses)
                            DropdownMenuItem(value: status, child: Text(status)),
                        ],
                        onChanged: (value) {
                          setState(() => _status = value == 'ALL' ? '' : (value ?? ''));
                          _load();
                        },
                      ),
                    ),
                    const SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _speciesFilter.isEmpty ? 'ALL' : _speciesFilter,
                        decoration: const InputDecoration(labelText: 'Espèce'),
                        items: [
                          const DropdownMenuItem(value: 'ALL', child: Text('Toutes')),
                          for (final species in _species)
                            DropdownMenuItem(value: species.id, child: Text(species.name)),
                        ],
                        onChanged: (value) {
                          setState(() => _speciesFilter = value == 'ALL' ? '' : (value ?? ''));
                          _load();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          else if (_animals.isEmpty)
            const EmptyState(message: 'Aucun animal enregistré', icon: Icons.pets)
          else
            for (final animal in _animals)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTokens.background,
                    child: Text(
                      animal.identifier.isEmpty ? '?' : animal.identifier.substring(0, 1),
                    ),
                  ),
                  title: Text(
                    animal.name == null || animal.name!.isEmpty
                        ? animal.identifier
                        : '${animal.identifier} · ${animal.name}',
                  ),
                  subtitle: Text(
                    '${_speciesName(animal.speciesId)} · ${animal.sex} · ${animal.status}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/herd/${animal.id}'),
                ),
              ),
        ],
      ),
    );
  }
}
