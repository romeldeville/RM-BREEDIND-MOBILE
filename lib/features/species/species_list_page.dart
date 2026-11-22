import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class SpeciesListPage extends ConsumerStatefulWidget {
  const SpeciesListPage({super.key});

  @override
  ConsumerState<SpeciesListPage> createState() => _SpeciesListPageState();
}

class _SpeciesListPageState extends ConsumerState<SpeciesListPage> {
  List<Species> _species = const [];
  bool _loading = true;
  bool _includeArchived = false;
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
      final species = await ref
          .read(referentialRepositoryProvider)
          .species(includeArchived: _includeArchived);
      if (mounted) {
        setState(() => _species = species);
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

  Future<void> _archive(Species species) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver cette espèce ?'),
        content: Text('${species.name} ne sera plus proposée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await ref.read(referentialRepositoryProvider).archiveSpecies(species.id);
      await _load();
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
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
            'Espèces, gabarits, races et plans.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/species/new'),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvelle espèce'),
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              FilterChip(
                label: const Text('Archivées'),
                selected: _includeArchived,
                onSelected: (value) {
                  setState(() => _includeArchived = value);
                  _load();
                },
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
          else if (_species.isEmpty)
            const EmptyState(message: 'Aucune espèce enregistrée')
          else
            for (final species in _species)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(species.name.isEmpty ? '?' : species.name.substring(0, 1)),
                  ),
                  title: Text(species.name),
                  subtitle: Text(
                    '${species.code} · ${species.productionType} · ${species.trackingMode}'
                    '${species.archivedAt != null ? ' · archivée' : ''}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context.push('/species/${species.id}/edit');
                        case 'breeds':
                          context.push('/species/${species.id}/breeds');
                        case 'plans':
                          context.push('/species/${species.id}/plans');
                        case 'archive':
                          _archive(species);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      const PopupMenuItem(value: 'breeds', child: Text('Races')),
                      const PopupMenuItem(value: 'plans', child: Text('Plans')),
                      if (species.archivedAt == null)
                        const PopupMenuItem(value: 'archive', child: Text('Archiver')),
                    ],
                  ),
                  onTap: () => context.push('/species/${species.id}/edit'),
                ),
              ),
        ],
      ),
    );
  }
}
