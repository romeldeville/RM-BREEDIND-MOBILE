import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/health/health_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'health_shared.dart';

class QuarantineFormPage extends ConsumerStatefulWidget {
  const QuarantineFormPage({super.key});

  @override
  ConsumerState<QuarantineFormPage> createState() => _QuarantineFormPageState();
}

class _QuarantineFormPageState extends ConsumerState<QuarantineFormPage> {
  final _startDate = TextEditingController(text: todayDate());
  final _endDate = TextEditingController();
  final _reason = TextEditingController();

  List<Animal> _animals = const [];
  List<Quarantine> _quarantines = const [];
  String? _animalId;
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
    _startDate.dispose();
    _endDate.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final animals = await loadAnimals(ref);
      final quarantines = await ref.read(healthRepositoryProvider).quarantines();
      if (mounted) {
        setState(() {
          _animals = animals;
          _quarantines = quarantines;
          _animalId = animals.isEmpty ? null : animals.first.id;
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

  Future<void> _save() async {
    if (_animalId == null) {
      setState(() => _error = 'L’animal est obligatoire.');
      return;
    }
    final startDate = normalizeDate(_startDate.text);
    if (startDate == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(healthRepositoryProvider).createQuarantine({
        'animalId': _animalId,
        'startDate': startDate,
        'endDate': normalizeDate(_endDate.text),
        'reason': _reason.text.trim().isEmpty ? null : _reason.text.trim(),
      });
      if (mounted) {
        await _load();
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

  Future<void> _release(Quarantine quarantine) async {
    try {
      await ref.read(healthRepositoryProvider).releaseQuarantine(quarantine.id);
      if (mounted) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quarantaine'),
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
                SectionCard(
                  title: 'Nouvelle quarantaine',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _animalId,
                        decoration: const InputDecoration(labelText: 'Animal'),
                        items: [
                          for (final animal in _animals)
                            DropdownMenuItem(
                              value: animal.id,
                              child: Text(animalLabel(animal)),
                            ),
                        ],
                        onChanged: (value) => setState(() => _animalId = value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _startDate,
                        decoration: const InputDecoration(
                          labelText: 'Date de début',
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _endDate,
                        decoration: const InputDecoration(
                          labelText: 'Date de fin prévue',
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _reason,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Motif'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Quarantaines',
                  child: _quarantines.isEmpty
                      ? const EmptyState(
                          message: 'Aucune quarantaine',
                          icon: Icons.coronavirus_outlined,
                        )
                      : Column(
                          children: [
                            for (final quarantine in _quarantines)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: AppTokens.background,
                                  child: Icon(Icons.coronavirus_outlined),
                                ),
                                title: Text(
                                  'Animal ${shortId(quarantine.animalId ?? quarantine.lotId ?? '')}',
                                ),
                                subtitle: Text(
                                  '${quarantine.status} - ${quarantine.startDate} au ${quarantine.endDate ?? '-'}',
                                ),
                                trailing: quarantine.status == 'ACTIVE'
                                    ? IconButton(
                                        icon: const Icon(Icons.lock_open_outlined),
                                        tooltip: 'Libérer',
                                        onPressed: () => _release(quarantine),
                                      )
                                    : null,
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}
