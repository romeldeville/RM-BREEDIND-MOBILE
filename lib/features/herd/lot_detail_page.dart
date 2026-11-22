import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class LotDetailPage extends ConsumerStatefulWidget {
  const LotDetailPage({super.key, required this.lotId});

  final String lotId;

  @override
  ConsumerState<LotDetailPage> createState() => _LotDetailPageState();
}

class _LotDetailPageState extends ConsumerState<LotDetailPage> {
  Lot? _lot;
  List<Species> _species = const [];
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
      final lot = await ref.read(herdRepositoryProvider).lot(widget.lotId);
      final species = await ref.read(referentialRepositoryProvider).species();
      if (mounted) {
        setState(() {
          _lot = lot;
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

  Future<void> _open(String path) async {
    await context.push(path);
    if (mounted) {
      await _load();
    }
  }

  Future<void> _individualize() async {
    final input = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _IndividualizeDialog(),
    );
    if (input == null) {
      return;
    }
    try {
      await ref.read(herdRepositoryProvider).individualize(widget.lotId, input);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animal individualisé.')),
        );
        await _load();
      }
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
    final lot = _lot;
    return Scaffold(
      appBar: AppBar(
        title: Text(lot?.name ?? 'Fiche lot'),
        actions: [
          if (lot != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifier',
              onPressed: () => _open('/lots/${lot.id}/edit'),
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
                      title: 'Lot',
                      child: Column(
                        children: [
                          _row('Nom', lot!.name),
                          _row('Code', lot.code ?? '-'),
                          _row('Espèce', _speciesName(lot.speciesId)),
                          _row('Production', lot.productionType ?? '-'),
                          _row('Statut', lot.status),
                          _row('Origine', lot.origin ?? '-'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    SectionCard(
                      title: 'Effectif',
                      child: Column(
                        children: [
                          _row('Initial', lot.initialCount.toString()),
                          _row('Actuel', lot.currentCount.toString()),
                          _row('Entrée', lot.entryDate ?? '-'),
                          _row('Coût unitaire', lot.unitCost?.toString() ?? '-'),
                          _row('Clôturé le', lot.closedAt ?? '-'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    SectionCard(
                      title: 'Actions',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      _open('/lots/${lot.id}/movements'),
                                  icon: const Icon(Icons.swap_vert),
                                  label: const Text('Mouvements'),
                                ),
                              ),
                              const SizedBox(width: AppTokens.space3),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _open('/lots/${lot.id}/close'),
                                  icon: const Icon(Icons.lock_outline),
                                  label: const Text('Clôturer'),
                                ),
                              ),
                            ],
                          ),
                          if (lot.status == 'OPEN' && lot.currentCount > 0) ...[
                            const SizedBox(height: AppTokens.space3),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _individualize,
                                icon: const Icon(Icons.pets),
                                label: const Text('Individualiser un animal'),
                              ),
                            ),
                          ],
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

class _IndividualizeDialog extends StatefulWidget {
  const _IndividualizeDialog();

  @override
  State<_IndividualizeDialog> createState() => _IndividualizeDialogState();
}

class _IndividualizeDialogState extends State<_IndividualizeDialog> {
  final _identifier = TextEditingController();
  final _birthDate = TextEditingController();
  String _sex = 'FEMALE';
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _birthDate.dispose();
    super.dispose();
  }

  void _submit() {
    if (_identifier.text.trim().isEmpty) {
      setState(() => _error = "L'identifiant est obligatoire.");
      return;
    }
    final date = _birthDate.text.trim();
    final parsed = date.isEmpty ? null : DateTime.tryParse(date);
    if (date.isNotEmpty && parsed == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    Navigator.pop(context, {
      'identifier': _identifier.text.trim(),
      'sex': _sex,
      'birthDate': parsed == null
          ? null
          : '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}',
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Individualiser un animal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppTokens.danger)),
            const SizedBox(height: AppTokens.space2),
          ],
          TextField(
            controller: _identifier,
            decoration: const InputDecoration(labelText: 'Identifiant'),
          ),
          const SizedBox(height: AppTokens.space3),
          DropdownButtonFormField<String>(
            initialValue: _sex,
            decoration: const InputDecoration(labelText: 'Sexe'),
            items: const [
              DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
              DropdownMenuItem(value: 'MALE', child: Text('MALE')),
              DropdownMenuItem(value: 'UNKNOWN', child: Text('UNKNOWN')),
            ],
            onChanged: (value) => setState(() => _sex = value ?? _sex),
          ),
          const SizedBox(height: AppTokens.space3),
          TextField(
            controller: _birthDate,
            decoration: const InputDecoration(
              labelText: 'Date de naissance',
              hintText: 'AAAA-MM-JJ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(onPressed: _submit, child: const Text('Créer')),
      ],
    );
  }
}
