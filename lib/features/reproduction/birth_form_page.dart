import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/reproduction/reproduction_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'reproduction_shared.dart';

class BirthFormPage extends ConsumerStatefulWidget {
  const BirthFormPage({super.key, this.cycleId});

  final String? cycleId;

  @override
  ConsumerState<BirthFormPage> createState() => _BirthFormPageState();
}

class _BirthFormPageState extends ConsumerState<BirthFormPage> {
  final _occurredAt = TextEditingController(text: todayDate());
  final _bornAlive = TextEditingController(text: '1');
  final _stillborn = TextEditingController(text: '0');
  final _mummified = TextEditingController(text: '0');
  final _litterWeight = TextEditingController();
  final _complications = TextEditingController();

  List<ReproductionCycle> _cycles = const [];
  List<Animal> _animals = const [];
  String? _cycleId;
  String? _femaleId;
  bool _assistance = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  BirthCreation? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _occurredAt.dispose();
    _bornAlive.dispose();
    _stillborn.dispose();
    _mummified.dispose();
    _litterWeight.dispose();
    _complications.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final cycles = await loadCycles(ref);
      final animals = await ref
          .read(herdRepositoryProvider)
          .animals(limit: 100);
      final selected =
          widget.cycleId != null &&
              cycles.any((cycle) => cycle.id == widget.cycleId)
          ? cycles.firstWhere((cycle) => cycle.id == widget.cycleId)
          : (cycles.isEmpty ? null : cycles.first);
      if (mounted) {
        setState(() {
          _cycles = cycles;
          _animals = animals.items;
          _cycleId = selected?.id;
          _femaleId = selected?.femaleId;
          _loading = false;
        });
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _loading = false;
        });
      }
    }
  }

  void _selectCycle(String? value) {
    ReproductionCycle? selected;
    for (final cycle in _cycles) {
      if (cycle.id == value) {
        selected = cycle;
        break;
      }
    }
    setState(() {
      _cycleId = value;
      if (selected != null) {
        _femaleId = selected.femaleId;
      }
    });
  }

  Future<void> _save() async {
    if (_cycleId == null || _femaleId == null) {
      setState(() => _error = 'Le cycle et la femelle sont obligatoires.');
      return;
    }
    final occurredAt = dateToInstant(_occurredAt.text);
    if (occurredAt == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    final bornAlive = int.tryParse(_bornAlive.text.trim());
    final stillborn = int.tryParse(_stillborn.text.trim());
    final mummified = int.tryParse(_mummified.text.trim());
    if (bornAlive == null || bornAlive < 0) {
      setState(() => _error = 'Le nombre de nés vivants est invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(reproductionRepositoryProvider)
          .recordBirth({
            'cycleId': _cycleId,
            'femaleId': _femaleId,
            'occurredAt': occurredAt,
            'bornAlive': bornAlive,
            'stillborn': stillborn ?? 0,
            'mummified': mummified ?? 0,
            'litterWeight': double.tryParse(_litterWeight.text.trim()),
            'assistance': _assistance,
            'complications': _complications.text.trim().isEmpty
                ? null
                : _complications.text.trim(),
          });
      if (mounted) {
        setState(() => _result = result);
      }
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

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mise bas'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTokens.space4),
              children: [
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(color: AppTokens.danger),
                  ),
                  const SizedBox(height: AppTokens.space3),
                ],
                if (result != null) ...[
                  SectionCard(
                    title: 'Résultat',
                    child: Column(
                      children: [
                        _row('Portée', result.litterId),
                        if (result.retroactiveMatingSuggested)
                          _row(
                            'Saillie suggérée',
                            result.suggestedMatingDate ?? '-',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                ],
                SectionCard(
                  title: 'Mise bas',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _cycleId,
                        decoration: const InputDecoration(labelText: 'Cycle'),
                        items: [
                          for (final cycle in _cycles)
                            DropdownMenuItem(
                              value: cycle.id,
                              child: Text(cycleLabel(cycle, _animals)),
                            ),
                        ],
                        onChanged: _selectCycle,
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _occurredAt,
                        decoration: const InputDecoration(
                          labelText: 'Date de mise bas',
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _bornAlive,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Nés vivants',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space3),
                          Expanded(
                            child: TextField(
                              controller: _stillborn,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Mort-nés',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space3),
                          Expanded(
                            child: TextField(
                              controller: _mummified,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Momifiés',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _litterWeight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Poids de portée (kg)',
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Assistance à la mise bas'),
                        value: _assistance,
                        onChanged: (value) =>
                            setState(() => _assistance = value),
                      ),
                      TextField(
                        controller: _complications,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Complications',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                const Text(
                  'Si aucune saillie récente n’est enregistrée, une date de saillie rétroactive est proposée.',
                  style: TextStyle(color: AppTokens.textMuted),
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
            width: 120,
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
