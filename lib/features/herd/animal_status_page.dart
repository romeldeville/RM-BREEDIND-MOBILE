import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class AnimalStatusPage extends ConsumerStatefulWidget {
  const AnimalStatusPage({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<AnimalStatusPage> createState() => _AnimalStatusPageState();
}

class _AnimalStatusPageState extends ConsumerState<AnimalStatusPage> {
  static const _statuses = [
    'ACTIVE',
    'QUARANTINED',
    'SOLD',
    'DEAD',
    'SLAUGHTERED',
    'TRANSFERRED',
    'ARCHIVED',
  ];

  final _reason = TextEditingController();
  List<AnimalStatusEntry> _history = const [];
  List<Animal> _animals = const [];
  String _status = 'ACTIVE';
  String? _motherId;
  String? _fatherId;
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
    _reason.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(herdRepositoryProvider);
      final animal = await repository.animal(widget.animalId);
      final history = await repository.statusHistory(widget.animalId);
      final page = await repository.animals(limit: 100);
      if (mounted) {
        setState(() {
          _history = history;
          _animals = page.items.where((item) => item.id != animal.id).toList();
          _status = animal.status;
          _motherId = animal.motherId;
          _fatherId = animal.fatherId;
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

  Future<void> _changeStatus() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(herdRepositoryProvider).changeStatus(widget.animalId, {
        'status': _status,
        'reason': _reason.text.trim().isEmpty ? null : _reason.text.trim(),
      });
      _reason.clear();
      await _load();
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

  Future<void> _saveFiliation() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(herdRepositoryProvider).patchAnimal(widget.animalId, {
        'motherId': _motherId,
        'fatherId': _fatherId,
      });
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filiation enregistrée.')),
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
      appBar: AppBar(title: const Text('Statut et filiation')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTokens.space4),
              children: [
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: AppTokens.danger)),
                  const SizedBox(height: AppTokens.space3),
                ],
                SectionCard(
                  title: 'Changer le statut',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Statut'),
                        items: [
                          for (final status in _statuses)
                            DropdownMenuItem(value: status, child: Text(status)),
                        ],
                        onChanged: (value) => setState(() => _status = value ?? _status),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _reason,
                        decoration: const InputDecoration(labelText: 'Motif'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _saving ? null : _changeStatus,
                          child: const Text('Changer le statut'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Filiation',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _motherId,
                        decoration: const InputDecoration(labelText: 'Mère'),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Non renseignée')),
                          for (final animal in _animals.where((a) => a.sex == 'FEMALE'))
                            DropdownMenuItem(
                              value: animal.id,
                              child: Text(animal.identifier),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _motherId = value == '' ? null : value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _fatherId,
                        decoration: const InputDecoration(labelText: 'Père'),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Non renseigné')),
                          for (final animal in _animals.where((a) => a.sex == 'MALE'))
                            DropdownMenuItem(
                              value: animal.id,
                              child: Text(animal.identifier),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _fatherId = value == '' ? null : value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: _saving ? null : _saveFiliation,
                          child: const Text('Enregistrer la filiation'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Historique',
                  child: _history.isEmpty
                      ? const Text(
                          'Aucun changement enregistré.',
                          style: TextStyle(color: AppTokens.textMuted),
                        )
                      : Column(
                          children: [
                            for (final entry in _history)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.history),
                                title: Text(entry.status),
                                subtitle: Text(
                                  '${entry.changedAt}'
                                  '${entry.reason == null ? '' : ' · ${entry.reason}'}',
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
