import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/production/production_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'production_shared.dart';

class WeighingPage extends ConsumerStatefulWidget {
  const WeighingPage({super.key});

  @override
  ConsumerState<WeighingPage> createState() => _WeighingPageState();
}

class _WeighingPageState extends ConsumerState<WeighingPage> {
  final _weight = TextEditingController();
  final _sampleCount = TextEditingController();
  final _weighedAt = TextEditingController(text: todayDate());

  List<Animal> _animals = const [];
  List<Lot> _lots = const [];
  List<Weighing> _weighings = const [];
  String _target = 'ANIMAL';
  String? _animalId;
  String? _lotId;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _weight.dispose();
    _sampleCount.dispose();
    _weighedAt.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(productionRepositoryProvider);
      final animals = await loadAnimals(ref);
      final lots = await loadLots(ref);
      if (!mounted) {
        return;
      }
      final animalId = _animalId ?? (animals.isEmpty ? null : animals.first.id);
      final lotId = _lotId ?? (lots.isEmpty ? null : lots.first.id);
      final weighings = await repository.weighings(
        animalId: _target == 'ANIMAL' ? animalId : null,
        lotId: _target == 'LOT' ? lotId : null,
      );
      if (mounted) {
        setState(() {
          _animals = animals;
          _lots = lots;
          _animalId = animalId;
          _lotId = lotId;
          _weighings = weighings;
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

  Future<void> _submit() async {
    final weight = double.tryParse(_weight.text.replaceAll(',', '.'));
    if (weight == null || weight <= 0) {
      setState(() => _error = 'Poids invalide.');
      return;
    }
    final weighedAt = dateToInstant(_weighedAt.text);
    if (weighedAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    if (_target == 'ANIMAL' && _animalId == null) {
      setState(() => _error = 'Sélectionnez un animal.');
      return;
    }
    if (_target == 'LOT' && _lotId == null) {
      setState(() => _error = 'Sélectionnez un lot.');
      return;
    }
    final sampleCount = int.tryParse(_sampleCount.text.trim());
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(productionRepositoryProvider).createWeighing({
        'animalId': _target == 'ANIMAL' ? _animalId : null,
        'lotId': _target == 'LOT' ? _lotId : null,
        'weighedAt': weighedAt,
        'weightKg': weight,
        if (_target == 'LOT' && sampleCount != null) 'sampleCount': sampleCount,
        if (_target == 'LOT' && sampleCount != null)
          'averageWeight': weight,
      });
      _weight.clear();
      _sampleCount.clear();
      final weighings = await ref
          .read(productionRepositoryProvider)
          .weighings(
            animalId: _target == 'ANIMAL' ? _animalId : null,
            lotId: _target == 'LOT' ? _lotId : null,
          );
      if (mounted) {
        setState(() => _weighings = weighings);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesée enregistrée')),
        );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Pesées')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouvelle pesée',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: const TextStyle(color: AppTokens.danger),
                          ),
                          const SizedBox(height: AppTokens.space2),
                        ],
                        DropdownButtonFormField<String>(
                          initialValue: _target,
                          decoration: const InputDecoration(labelText: 'Cible'),
                          items: const [
                            DropdownMenuItem(
                              value: 'ANIMAL',
                              child: Text('Animal'),
                            ),
                            DropdownMenuItem(value: 'LOT', child: Text('Lot')),
                          ],
                          onChanged: (value) {
                            setState(() => _target = value ?? _target);
                            _load();
                          },
                        ),
                        const SizedBox(height: AppTokens.space3),
                        if (_target == 'ANIMAL')
                          DropdownButtonFormField<String>(
                            initialValue: _animalId,
                            decoration: const InputDecoration(
                              labelText: 'Animal',
                            ),
                            items: [
                              for (final animal in _animals)
                                DropdownMenuItem(
                                  value: animal.id,
                                  child: Text(
                                    animal.name == null || animal.name!.isEmpty
                                        ? animal.identifier
                                        : '${animal.identifier} - ${animal.name}',
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _animalId = value),
                          )
                        else
                          DropdownButtonFormField<String>(
                            initialValue: _lotId,
                            decoration: const InputDecoration(labelText: 'Lot'),
                            items: [
                              for (final lot in _lots)
                                DropdownMenuItem(
                                  value: lot.id,
                                  child: Text(lot.name),
                                ),
                            ],
                            onChanged: (value) => setState(() => _lotId = value),
                          ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _weight,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Poids (kg)',
                          ),
                        ),
                        if (_target == 'LOT') ...[
                          const SizedBox(height: AppTokens.space3),
                          TextField(
                            controller: _sampleCount,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Taille de l’échantillon',
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _weighedAt,
                          decoration: const InputDecoration(
                            labelText: 'Date de pesée',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space4),
                        FilledButton(
                          onPressed: _saving ? null : _submit,
                          child: const Text('Enregistrer'),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Pesées récentes',
              child: _weighings.isEmpty
                  ? const EmptyState(
                      message: 'Aucune pesée',
                      icon: Icons.monitor_weight_outlined,
                    )
                  : Column(
                      children: [
                        for (final weighing in _weighings)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.monitor_weight_outlined),
                            ),
                            title: Text(
                              '${formatQuantity(weighing.averageWeight ?? weighing.weightKg)} kg',
                            ),
                            subtitle: Text(
                              formatTimestamp(weighing.weighedAt),
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
