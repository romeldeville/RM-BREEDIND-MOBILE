import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/reproduction/reproduction_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'reproduction_shared.dart';

class MatingFormPage extends ConsumerStatefulWidget {
  const MatingFormPage({super.key});

  @override
  ConsumerState<MatingFormPage> createState() => _MatingFormPageState();
}

class _MatingFormPageState extends ConsumerState<MatingFormPage> {
  static const _methods = ['NATURAL', 'AI'];

  final _matedAt = TextEditingController(text: todayDate());
  final _semenCode = TextEditingController();
  final _notes = TextEditingController();

  List<Animal> _females = const [];
  List<Animal> _males = const [];
  String? _femaleId;
  String? _maleId;
  String _method = 'NATURAL';
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
    _matedAt.dispose();
    _semenCode.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final page = await ref.read(herdRepositoryProvider).animals(limit: 100);
      final females = page.items
          .where((animal) => animal.sex == 'FEMALE')
          .toList(growable: false);
      final males = page.items
          .where((animal) => animal.sex == 'MALE')
          .toList(growable: false);
      if (mounted) {
        setState(() {
          _females = females;
          _males = males;
          _femaleId = females.isEmpty ? null : females.first.id;
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
    if (_femaleId == null) {
      setState(() => _error = 'La femelle est obligatoire.');
      return;
    }
    final matedAt = dateToInstant(_matedAt.text);
    if (matedAt == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(reproductionRepositoryProvider).recordMating({
        'femaleId': _femaleId,
        'maleId': _maleId,
        'semenCode': _semenCode.text.trim().isEmpty
            ? null
            : _semenCode.text.trim(),
        'method': _method,
        'matedAt': matedAt,
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
        title: const Text('Saillie'),
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
                  title: 'Saillie ou insémination',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _femaleId,
                        decoration: const InputDecoration(labelText: 'Femelle'),
                        items: [
                          for (final female in _females)
                            DropdownMenuItem(
                              value: female.id,
                              child: Text(animalLabel(female)),
                            ),
                        ],
                        onChanged: (value) => setState(() => _femaleId = value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _maleId,
                        decoration: const InputDecoration(labelText: 'Mâle'),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Non précisé'),
                          ),
                          for (final male in _males)
                            DropdownMenuItem(
                              value: male.id,
                              child: Text(animalLabel(male)),
                            ),
                        ],
                        onChanged: (value) => setState(
                          () => _maleId = value == '' ? null : value,
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _method,
                        decoration: const InputDecoration(labelText: 'Méthode'),
                        items: [
                          for (final method in _methods)
                            DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _method = value ?? _method),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _matedAt,
                        decoration: const InputDecoration(
                          labelText: 'Date de saillie',
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _semenCode,
                        decoration: const InputDecoration(
                          labelText: 'Code semence',
                        ),
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
                  'Les dates de diagnostic et de mise bas sont calculées automatiquement.',
                  style: TextStyle(color: AppTokens.textMuted),
                ),
              ],
            ),
    );
  }
}
