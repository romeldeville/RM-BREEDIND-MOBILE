import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/reproduction/reproduction_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'reproduction_shared.dart';

class DiagnosisFormPage extends ConsumerStatefulWidget {
  const DiagnosisFormPage({super.key, this.cycleId});

  final String? cycleId;

  @override
  ConsumerState<DiagnosisFormPage> createState() => _DiagnosisFormPageState();
}

class _DiagnosisFormPageState extends ConsumerState<DiagnosisFormPage> {
  static const _results = ['POSITIVE', 'NEGATIVE', 'UNCERTAIN'];

  final _diagnosedAt = TextEditingController(text: todayDate());
  final _notes = TextEditingController();

  List<ReproductionCycle> _cycles = const [];
  List<Animal> _animals = const [];
  String? _cycleId;
  String _result = 'POSITIVE';
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
    _diagnosedAt.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final cycles = await loadCycles(ref);
      final animals = await ref
          .read(herdRepositoryProvider)
          .animals(limit: 100);
      if (mounted) {
        setState(() {
          _cycles = cycles;
          _animals = animals.items;
          _cycleId =
              widget.cycleId != null &&
                  cycles.any((cycle) => cycle.id == widget.cycleId)
              ? widget.cycleId
              : (cycles.isEmpty ? null : cycles.first.id);
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

  Future<void> _save() async {
    if (_cycleId == null) {
      setState(() => _error = 'Le cycle est obligatoire.');
      return;
    }
    final diagnosedAt = dateToInstant(_diagnosedAt.text);
    if (diagnosedAt == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(reproductionRepositoryProvider).recordDiagnosis({
        'cycleId': _cycleId,
        'diagnosedAt': diagnosedAt,
        'result': _result,
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      });
      if (mounted) {
        context.pop(true);
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
      appBar: AppBar(
        title: const Text('Diagnostic de gestation'),
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
                SectionCard(
                  title: 'Diagnostic',
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
                        onChanged: (value) => setState(() => _cycleId = value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _diagnosedAt,
                        decoration: const InputDecoration(
                          labelText: 'Date du diagnostic',
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _result,
                        decoration: const InputDecoration(
                          labelText: 'Résultat',
                        ),
                        items: [
                          for (final result in _results)
                            DropdownMenuItem(
                              value: result,
                              child: Text(result),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _result = value ?? _result),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _notes,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Notes'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                const Text(
                  'Un résultat négatif replanifie le prochain diagnostic selon le cycle de chaleur.',
                  style: TextStyle(color: AppTokens.textMuted),
                ),
              ],
            ),
    );
  }
}
