import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/db/app_database.dart' hide Animal;
import '../../core/health/health_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/sync/sync_controller.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'health_shared.dart';

class MortalityFormPage extends ConsumerStatefulWidget {
  const MortalityFormPage({super.key});

  @override
  ConsumerState<MortalityFormPage> createState() => _MortalityFormPageState();
}

class _MortalityFormPageState extends ConsumerState<MortalityFormPage> {
  final _occurredAt = TextEditingController(text: todayDate());
  final _count = TextEditingController(text: '1');
  final _cause = TextEditingController();

  List<Animal> _animals = const [];
  List<Lot> _lots = const [];
  List<Mortality> _recent = const [];
  String _target = 'ANIMAL';
  String? _animalId;
  String? _lotId;
  bool _loading = true;
  bool _saving = false;
  bool _offline = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _occurredAt.dispose();
    _count.dispose();
    _cause.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final animals = await loadAnimals(ref);
      final lots = await ref.read(herdRepositoryProvider).lots(limit: 100);
      final recent = await ref.read(healthRepositoryProvider).mortalities();
      if (mounted) {
        setState(() {
          _animals = animals;
          _lots = lots.items;
          _recent = recent;
          _animalId = animals.isEmpty ? null : animals.first.id;
          _lotId = lots.items.isEmpty ? null : lots.items.first.id;
        });
      }
    } on ApiFailure catch (error) {
      if (_isOffline(error)) {
        await _loadLocalFallback();
      } else if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  static bool _isOffline(ApiFailure error) => error.statusCode == null;

  /// Field entry must stay possible without network. When the API cannot be
  /// reached, the form falls back to the lots and animals cached in Drift.
  Future<void> _loadLocalFallback() async {
    final localAnimals = await ref.read(animalDaoProvider).all();
    final localLots = await ref.read(localDataDaoProvider).lots();
    final animals = localAnimals
        .map(
          (row) => Animal(
            id: row.id,
            farmId: '',
            speciesId: row.species,
            identifier: row.tag,
            sex: row.sex,
            status: row.status,
            birthDate: row.birthDate?.toIso8601String(),
            createdAt: row.createdAt.toIso8601String(),
          ),
        )
        .toList(growable: false);
    final lots = localLots
        .map(
          (row) => Lot(
            id: row.id,
            farmId: '',
            speciesId: '',
            name: row.name,
            status: row.status,
            initialCount: row.initialCount,
            currentCount: row.currentCount,
          ),
        )
        .toList(growable: false);
    if (!mounted) {
      return;
    }
    setState(() {
      _animals = animals;
      _lots = lots;
      _recent = const [];
      _offline = true;
      _error = null;
      _animalId = animals.isEmpty ? null : animals.first.id;
      _lotId = lots.isEmpty ? null : lots.first.id;
    });
  }

  Future<void> _save() async {
    if (_target == 'ANIMAL' && _animalId == null) {
      setState(() => _error = 'L’animal est obligatoire.');
      return;
    }
    if (_target == 'LOT' && _lotId == null) {
      setState(() => _error = 'Le lot est obligatoire.');
      return;
    }
    final occurredAt = dateToInstant(_occurredAt.text);
    if (occurredAt == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(healthRepositoryProvider).recordMortality({
        'animalId': _target == 'ANIMAL' ? _animalId : null,
        'lotId': _target == 'LOT' ? _lotId : null,
        'count': int.tryParse(_count.text) ?? 1,
        'cause': _cause.text.trim().isEmpty ? null : _cause.text.trim(),
        'occurredAt': occurredAt,
      });
      if (mounted) {
        context.pop(true);
      }
    } on ApiFailure catch (error) {
      if (_isOffline(error)) {
        await _saveOffline(occurredAt: occurredAt);
      } else if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  /// Local-first fallback: append the mortality event to the outbox so it is
  /// synchronized as soon as the device reconnects.
  Future<void> _saveOffline({required String occurredAt}) async {
    final mutations = ref.read(localMutationServiceProvider);
    final count = int.tryParse(_count.text) ?? 1;
    final cause = _cause.text.trim().isEmpty ? null : _cause.text.trim();
    final occurred = DateTime.tryParse(occurredAt);
    if (_target == 'LOT' && _lotId != null) {
      await mutations.recordLotMortality(
        lotId: _lotId!,
        count: count,
        cause: cause,
        occurredAt: occurred,
      );
    } else if (_animalId != null) {
      await mutations.record(
        aggregateType: 'animal',
        aggregateId: _animalId!,
        eventType: 'animal.mortality.recorded',
        occurredAt: occurred,
        payload: {'count': count, 'cause': ?cause},
      );
    }
    await ref.read(syncControllerProvider.notifier).refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hors ligne : mortalité enregistrée et sera synchronisée.',
          ),
        ),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortalité'),
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
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
                if (_offline) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTokens.space3),
                    decoration: BoxDecoration(
                      color: AppTokens.warning.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusMd),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          color: AppTokens.warning,
                          size: 18,
                        ),
                        SizedBox(width: AppTokens.space2),
                        Expanded(
                          child: Text(
                            'Hors ligne : la saisie sera enregistrée sur '
                            'l’appareil puis synchronisée.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.space3),
                ],
                SectionCard(
                  title: 'Nouvelle mortalité',
                  child: Column(
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'ANIMAL', label: Text('Animal')),
                          ButtonSegment(value: 'LOT', label: Text('Lot')),
                        ],
                        selected: {_target},
                        onSelectionChanged: (value) =>
                            setState(() => _target = value.first),
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
                                child: Text(animalLabel(animal)),
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
                        controller: _count,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _cause,
                        decoration: const InputDecoration(labelText: 'Cause'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _occurredAt,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Mortalités récentes',
                  child: _recent.isEmpty
                      ? const EmptyState(
                          message: 'Aucune mortalité enregistrée',
                          icon: Icons.warning_amber_outlined,
                        )
                      : Column(
                          children: [
                            for (final mortality in _recent)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: AppTokens.background,
                                  child: Icon(Icons.warning_amber_outlined),
                                ),
                                title: Text(
                                  '${mortality.count} - ${mortality.cause ?? 'Cause inconnue'}',
                                ),
                                subtitle: Text(
                                  formatTimestamp(mortality.occurredAt),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
