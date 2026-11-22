import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class AnimalDetailPage extends ConsumerStatefulWidget {
  const AnimalDetailPage({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends ConsumerState<AnimalDetailPage> {
  Animal? _animal;
  List<Species> _species = const [];
  List<Breed> _breeds = const [];
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
      final repository = ref.read(herdRepositoryProvider);
      final animal = await repository.animal(widget.animalId);
      final referential = ref.read(referentialRepositoryProvider);
      final species = await referential.species();
      final breeds = await referential.breeds(animal.speciesId);
      if (mounted) {
        setState(() {
          _animal = animal;
          _species = species;
          _breeds = breeds;
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

  String _breedName(String? id) {
    if (id == null) {
      return 'Non précisée';
    }
    for (final breed in _breeds) {
      if (breed.id == id) {
        return breed.name;
      }
    }
    return id;
  }

  Future<void> _open(String path) async {
    await context.push(path);
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final animal = _animal;
    return Scaffold(
      appBar: AppBar(
        title: Text(animal?.identifier ?? 'Fiche animal'),
        actions: [
          if (animal != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _open('/herd/${animal.id}/edit');
                  case 'status':
                    _open('/herd/${animal.id}/status');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Modifier')),
                PopupMenuItem(value: 'status', child: Text('Statut et filiation')),
              ],
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppTokens.danger)),
                      const SizedBox(height: AppTokens.space2),
                      OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppTokens.space4),
                  children: [
                    SectionCard(
                      title: 'Identité',
                      trailing: FilledButton.tonalIcon(
                        onPressed: () => _open('/herd/${animal!.id}/status'),
                        icon: const Icon(Icons.timeline, size: 18),
                        label: const Text('Statut'),
                      ),
                      child: Column(
                        children: [
                          _row('Identifiant', animal!.identifier),
                          _row('Nom', animal.name ?? '-'),
                          _row('Espèce', _speciesName(animal.speciesId)),
                          _row('Race', _breedName(animal.breedId)),
                          _row('Sexe', animal.sex),
                          _row('Statut', animal.status),
                          _row('Naissance', animal.birthDate ?? '-'),
                          _row('Origine', animal.origin ?? '-'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    SectionCard(
                      title: 'Filiation',
                      child: Column(
                        children: [
                          _row('Mère', animal.motherId ?? 'Non renseignée'),
                          _row('Père', animal.fatherId ?? 'Non renseigné'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    SectionCard(
                      title: 'Suivi',
                      child: Column(
                        children: [
                          _row('Poids', animal.weightKg == null ? '-' : '${animal.weightKg} kg'),
                          _row('Loge', animal.penId ?? '-'),
                          _row('Créé le', animal.createdAt ?? '-'),
                          _row('Mis à jour', animal.updatedAt ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppTokens.textMuted)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
