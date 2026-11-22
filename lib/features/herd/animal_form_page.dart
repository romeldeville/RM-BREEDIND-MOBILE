import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class AnimalFormPage extends ConsumerStatefulWidget {
  const AnimalFormPage({super.key, this.animalId});

  final String? animalId;

  @override
  ConsumerState<AnimalFormPage> createState() => _AnimalFormPageState();
}

class _AnimalFormPageState extends ConsumerState<AnimalFormPage> {
  static const _sexes = ['FEMALE', 'MALE', 'UNKNOWN'];

  final _identifier = TextEditingController();
  final _name = TextEditingController();
  final _birthDate = TextEditingController();
  final _origin = TextEditingController();
  final _weight = TextEditingController();

  List<Farm> _farms = const [];
  List<Species> _species = const [];
  List<Breed> _breeds = const [];
  String? _farmId;
  String? _speciesId;
  String? _breedId;
  String _sex = 'FEMALE';
  bool _birthEstimated = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.animalId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _identifier.dispose();
    _name.dispose();
    _birthDate.dispose();
    _origin.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final referential = ref.read(referentialRepositoryProvider);
      final farms = await referential.farms();
      final species = await referential.species();
      Animal? animal;
      if (_isEdit) {
        animal = await ref.read(herdRepositoryProvider).animal(widget.animalId!);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _farms = farms;
        _species = species;
        _farmId = animal?.farmId ?? (farms.isEmpty ? null : farms.first.id);
        _speciesId = animal?.speciesId ?? (species.isEmpty ? null : species.first.id);
        _breedId = animal?.breedId;
        _sex = animal?.sex ?? 'FEMALE';
        _birthEstimated = animal?.birthEstimated ?? false;
        if (animal != null) {
          _identifier.text = animal.identifier;
          _name.text = animal.name ?? '';
          _birthDate.text = animal.birthDate ?? '';
          _origin.text = animal.origin ?? '';
          _weight.text = animal.weightKg?.toString() ?? '';
        }
        _loading = false;
      });
      if (_speciesId != null) {
        await _loadBreeds(_speciesId!);
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

  Future<void> _loadBreeds(String speciesId) async {
    try {
      final breeds = await ref.read(referentialRepositoryProvider).breeds(speciesId);
      if (mounted) {
        setState(() {
          _breeds = breeds;
          if (!breeds.any((breed) => breed.id == _breedId)) {
            _breedId = null;
          }
        });
      }
    } on ApiFailure {
      if (mounted) {
        setState(() => _breeds = const []);
      }
    }
  }

  Future<void> _save() async {
    if (_identifier.text.trim().isEmpty) {
      setState(() => _error = "L'identifiant est obligatoire.");
      return;
    }
    if (!_isEdit && (_farmId == null || _speciesId == null)) {
      setState(() => _error = 'La ferme et l\'espèce sont obligatoires.');
      return;
    }
    final birthDate = _parseDate(_birthDate.text);
    if (_birthDate.text.trim().isNotEmpty && birthDate == null) {
      setState(() => _error = 'La date de naissance doit être au format AAAA-MM-JJ.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'identifier': _identifier.text.trim(),
      'name': _name.text.trim().isEmpty ? null : _name.text.trim(),
      'sex': _sex,
      'birthDate': birthDate,
      'birthEstimated': _birthEstimated,
      'origin': _origin.text.trim().isEmpty ? null : _origin.text.trim(),
      'weightKg': double.tryParse(_weight.text.trim()),
      'breedId': _breedId,
    };
    try {
      final repository = ref.read(herdRepositoryProvider);
      if (_isEdit) {
        await repository.patchAnimal(widget.animalId!, body);
      } else {
        body['farmId'] = _farmId;
        body['speciesId'] = _speciesId;
        await repository.createAnimal(body);
      }
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

  String? _parseDate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) {
      return null;
    }
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? "Modifier l'animal" : 'Nouvel animal'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Enregistrement…' : 'Enregistrer'),
          ),
        ],
      ),
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
                  title: 'Identité',
                  child: Column(
                    children: [
                      TextField(
                        controller: _identifier,
                        decoration: const InputDecoration(labelText: 'Identifiant'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nom'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _sex,
                        decoration: const InputDecoration(labelText: 'Sexe'),
                        items: [
                          for (final sex in _sexes)
                            DropdownMenuItem(value: sex, child: Text(sex)),
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
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Date estimée'),
                        value: _birthEstimated,
                        onChanged: (value) => setState(() => _birthEstimated = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Rattachement',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _farmId,
                        decoration: const InputDecoration(labelText: 'Ferme'),
                        items: [
                          for (final farm in _farms)
                            DropdownMenuItem(value: farm.id, child: Text(farm.name)),
                        ],
                        onChanged: _isEdit
                            ? null
                            : (value) => setState(() => _farmId = value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _speciesId,
                        decoration: const InputDecoration(labelText: 'Espèce'),
                        items: [
                          for (final species in _species)
                            DropdownMenuItem(value: species.id, child: Text(species.name)),
                        ],
                        onChanged: _isEdit
                            ? null
                            : (value) {
                                setState(() {
                                  _speciesId = value;
                                  _breedId = null;
                                  _breeds = const [];
                                });
                                if (value != null) {
                                  _loadBreeds(value);
                                }
                              },
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _breedId,
                        decoration: const InputDecoration(labelText: 'Race'),
                        items: [
                          const DropdownMenuItem(value: '', child: Text('Non précisée')),
                          for (final breed in _breeds)
                            DropdownMenuItem(value: breed.id, child: Text(breed.name)),
                        ],
                        onChanged: (value) =>
                            setState(() => _breedId = value == '' ? null : value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Données zootechniques',
                  child: Column(
                    children: [
                      TextField(
                        controller: _origin,
                        decoration: const InputDecoration(
                          labelText: 'Origine',
                          hintText: 'NAISSANCE, ACHAT, LOT…',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _weight,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Poids (kg)'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
