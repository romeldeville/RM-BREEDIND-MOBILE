import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/reproduction/reproduction_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'reproduction_shared.dart';

class CycleDetailPage extends ConsumerStatefulWidget {
  const CycleDetailPage({super.key, required this.cycleId});

  final String cycleId;

  @override
  ConsumerState<CycleDetailPage> createState() => _CycleDetailPageState();
}

class _CycleDetailPageState extends ConsumerState<CycleDetailPage> {
  CycleDetail? _detail;
  List<Animal> _animals = const [];
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
      final detail = await ref
          .read(reproductionRepositoryProvider)
          .cycle(widget.cycleId);
      final animals = await ref
          .read(herdRepositoryProvider)
          .animals(limit: 100);
      if (mounted) {
        setState(() {
          _detail = detail;
          _animals = animals.items;
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

  Future<void> _open(String path) async {
    await context.push(path);
    if (mounted) {
      await _load();
    }
  }

  Future<void> _createLot(Litter litter) async {
    final input = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateLotDialog(litter: litter),
    );
    if (input == null) {
      return;
    }
    try {
      await ref
          .read(reproductionRepositoryProvider)
          .createLotFromLitter(litter.id, input);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lot créé depuis la portée.')),
        );
        await _load();
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final cycle = detail?.cycle;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle de reproduction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _load,
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
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(AppTokens.space4),
              children: [
                SectionCard(
                  title: 'Cycle',
                  child: Column(
                    children: [
                      _row('Femelle', _femaleLabel(cycle?.femaleId ?? '')),
                      _row('Statut', cycle?.status ?? '-'),
                      _row('Parité', (cycle?.parity ?? 0).toString()),
                      _row('Début', cycle?.startDate ?? '-'),
                      _row(
                        'Diagnostic prévu',
                        cycle?.expectedDiagnosisDate ?? '-',
                      ),
                      _row('Mise bas prévue', cycle?.expectedBirthDate ?? '-'),
                      _row('Fin', cycle?.endDate ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Actions',
                  child: Wrap(
                    spacing: AppTokens.space3,
                    runSpacing: AppTokens.space2,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _open('/reproduction/heats'),
                        icon: const Icon(Icons.water_drop_outlined),
                        label: const Text('Chaleurs'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _open('/reproduction/matings'),
                        icon: const Icon(Icons.favorite_outline),
                        label: const Text('Saillie'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _open(
                          '/reproduction/diagnoses?cycle=${widget.cycleId}',
                        ),
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Diagnostic'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _open(
                          '/reproduction/births?cycle=${widget.cycleId}',
                        ),
                        icon: const Icon(Icons.child_care),
                        label: const Text('Mise bas'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Chaleurs',
                  child: _events(
                    detail?.heats
                            .map(
                              (heat) => _event(
                                formatTimestamp(heat.observedAt),
                                '${heat.intensity ?? '-'} - prochaine: ${heat.nextExpectedAt ?? '-'}',
                              ),
                            )
                            .toList(growable: false) ??
                        const [],
                    'Aucune chaleur enregistrée.',
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Saillies',
                  child: _events(
                    detail?.matings
                            .map(
                              (mating) => _event(
                                formatTimestamp(mating.matedAt),
                                '${mating.method ?? '-'} - mise bas prévue: ${mating.expectedBirthDate ?? '-'}',
                              ),
                            )
                            .toList(growable: false) ??
                        const [],
                    'Aucune saillie enregistrée.',
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Diagnostics',
                  child: _events(
                    detail?.diagnoses
                            .map(
                              (diagnosis) => _event(
                                formatTimestamp(diagnosis.diagnosedAt),
                                '${diagnosis.result} - prochain: ${diagnosis.nextDiagnosisAt ?? '-'}',
                              ),
                            )
                            .toList(growable: false) ??
                        const [],
                    'Aucun diagnostic enregistré.',
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Avortements',
                  child: _events(
                    detail?.abortions
                            .map(
                              (abortion) => _event(
                                formatTimestamp(abortion.occurredAt),
                                abortion.suspectedCause ??
                                    abortion.stage ??
                                    '-',
                              ),
                            )
                            .toList(growable: false) ??
                        const [],
                    'Aucun avortement enregistré.',
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Mises bas',
                  child: _events(
                    detail?.births
                            .map(
                              (birth) => _event(
                                formatTimestamp(birth.occurredAt),
                                '${birth.bornAlive} nés vivants, ${birth.stillborn} mort-nés, ${birth.mummified} momifiés',
                              ),
                            )
                            .toList(growable: false) ??
                        const [],
                    'Aucune mise bas enregistrée.',
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Portées',
                  child: Column(
                    children: [
                      if (detail == null || detail.litters.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppTokens.space3,
                          ),
                          child: Text(
                            'Aucune portée enregistrée.',
                            style: TextStyle(color: AppTokens.textMuted),
                          ),
                        )
                      else
                        for (final litter in detail.litters) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(litter.name),
                            subtitle: Text(
                              '${litter.bornAlive} nés vivants - sevrés: ${litter.weanedCount ?? 0}',
                            ),
                            trailing: Text(
                              litter.lotId == null ? 'Sans lot' : 'Lot créé',
                            ),
                          ),
                          Wrap(
                            spacing: AppTokens.space3,
                            children: [
                              OutlinedButton(
                                onPressed: () => _open(
                                  '/reproduction/weanings?cycle=${widget.cycleId}&litter=${litter.id}',
                                ),
                                child: const Text('Sevrage'),
                              ),
                              if (litter.lotId == null)
                                FilledButton(
                                  onPressed: () => _createLot(litter),
                                  child: const Text('Créer un lot'),
                                ),
                            ],
                          ),
                          const Divider(),
                        ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _femaleLabel(String id) {
    for (final animal in _animals) {
      if (animal.id == id) {
        return animalLabel(animal);
      }
    }
    return shortId(id);
  }

  Widget _events(List<Widget> children, String emptyMessage) {
    if (children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space2),
        child: Text(
          emptyMessage,
          style: const TextStyle(color: AppTokens.textMuted),
        ),
      );
    }
    return Column(children: children);
  }

  Widget _event(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppTokens.textMuted),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _CreateLotDialog extends StatefulWidget {
  const _CreateLotDialog({required this.litter});

  final Litter litter;

  @override
  State<_CreateLotDialog> createState() => _CreateLotDialogState();
}

class _CreateLotDialogState extends State<_CreateLotDialog> {
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _unitCost = TextEditingController();
  String _productionType = 'MIXED';

  @override
  void initState() {
    super.initState();
    _name.text = widget.litter.name;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _unitCost.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      return;
    }
    Navigator.pop(context, {
      'name': _name.text.trim(),
      'code': _code.text.trim().isEmpty ? null : _code.text.trim(),
      'productionType': _productionType,
      'unitCost': double.tryParse(_unitCost.text.trim()),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Créer un lot depuis la portée'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nom du lot'),
          ),
          const SizedBox(height: AppTokens.space3),
          TextField(
            controller: _code,
            decoration: const InputDecoration(labelText: 'Code'),
          ),
          const SizedBox(height: AppTokens.space3),
          DropdownButtonFormField<String>(
            initialValue: _productionType,
            decoration: const InputDecoration(labelText: 'Production'),
            items: const [
              DropdownMenuItem(value: 'MIXED', child: Text('MIXED')),
              DropdownMenuItem(value: 'MILK', child: Text('MILK')),
              DropdownMenuItem(value: 'MEAT', child: Text('MEAT')),
              DropdownMenuItem(value: 'EGGS', child: Text('EGGS')),
            ],
            onChanged: (value) =>
                setState(() => _productionType = value ?? _productionType),
          ),
          const SizedBox(height: AppTokens.space3),
          TextField(
            controller: _unitCost,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Coût unitaire'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Créer')),
      ],
    );
  }
}
