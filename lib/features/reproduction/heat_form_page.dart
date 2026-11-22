import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/reproduction/reproduction_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'reproduction_shared.dart';

class HeatFormPage extends ConsumerStatefulWidget {
  const HeatFormPage({super.key});

  @override
  ConsumerState<HeatFormPage> createState() => _HeatFormPageState();
}

class _HeatFormPageState extends ConsumerState<HeatFormPage> {
  static const _intensities = ['LOW', 'MEDIUM', 'HIGH'];

  final _observedAt = TextEditingController(text: todayDate());
  final _notes = TextEditingController();

  List<Animal> _females = const [];
  String? _animalId;
  String _intensity = 'MEDIUM';
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
    _observedAt.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final females = await loadFemales(ref);
      if (mounted) {
        setState(() {
          _females = females;
          _animalId = females.isEmpty ? null : females.first.id;
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
    if (_animalId == null) {
      setState(() => _error = 'La femelle est obligatoire.');
      return;
    }
    final observedAt = dateToInstant(_observedAt.text);
    if (observedAt == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(reproductionRepositoryProvider).recordHeat({
        'animalId': _animalId,
        'observedAt': observedAt,
        'intensity': _intensity,
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
        title: const Text('Chaleurs'),
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
                  title: 'Détection des chaleurs',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _animalId,
                        decoration: const InputDecoration(labelText: 'Femelle'),
                        items: [
                          for (final female in _females)
                            DropdownMenuItem(
                              value: female.id,
                              child: Text(animalLabel(female)),
                            ),
                        ],
                        onChanged: (value) => setState(() => _animalId = value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _observedAt,
                        decoration: const InputDecoration(
                          labelText: "Date d'observation",
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _intensity,
                        decoration: const InputDecoration(
                          labelText: 'Intensité',
                        ),
                        items: [
                          for (final intensity in _intensities)
                            DropdownMenuItem(
                              value: intensity,
                              child: Text(intensity),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _intensity = value ?? _intensity),
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
                  "La prochaine chaleur prévue est calculée à partir du cycle de l'espèce.",
                  style: TextStyle(color: AppTokens.textMuted),
                ),
              ],
            ),
    );
  }
}
