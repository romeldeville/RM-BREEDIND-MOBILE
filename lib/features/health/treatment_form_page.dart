import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/health/health_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'health_shared.dart';

class TreatmentFormPage extends ConsumerStatefulWidget {
  const TreatmentFormPage({super.key});

  @override
  ConsumerState<TreatmentFormPage> createState() => _TreatmentFormPageState();
}

class _TreatmentFormPageState extends ConsumerState<TreatmentFormPage> {
  final _startDate = TextEditingController(text: todayDate());
  final _durationDays = TextEditingController(text: '3');
  final _diagnosis = TextEditingController();
  final _symptoms = TextEditingController();
  final _dose = TextEditingController();
  final _notes = TextEditingController();

  List<Animal> _animals = const [];
  List<HealthProduct> _products = const [];
  List<Treatment> _treatments = const [];
  String? _animalId;
  String? _productId;
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
    _durationDays.dispose();
    _diagnosis.dispose();
    _symptoms.dispose();
    _dose.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final animals = await loadAnimals(ref);
      final products = await ref.read(healthRepositoryProvider).products();
      final treatments = await ref.read(healthRepositoryProvider).treatments();
      if (mounted) {
        setState(() {
          _animals = animals;
          _products = products;
          _treatments = treatments;
          _animalId = animals.isEmpty ? null : animals.first.id;
          _productId = products.isEmpty ? null : products.first.id;
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
    if (_animalId == null || _productId == null) {
      setState(() => _error = 'L’animal et le produit sont obligatoires.');
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
      await ref.read(healthRepositoryProvider).createTreatment({
        'animalId': _animalId,
        'productId': _productId,
        'startDate': startDate,
        'durationDays': int.tryParse(_durationDays.text),
        'diagnosis': _diagnosis.text.trim().isEmpty
            ? null
            : _diagnosis.text.trim(),
        'symptoms': _symptoms.text.trim().isEmpty
            ? null
            : _symptoms.text.trim(),
        'dose': _dose.text.trim().isEmpty ? null : _dose.text.trim(),
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

  Future<void> _administer(Treatment treatment) async {
    try {
      await ref.read(healthRepositoryProvider).addAdministration(treatment.id, {
        'administeredAt': DateTime.now().toUtc().toIso8601String(),
      });
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
        title: const Text('Traitement'),
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
                  title: 'Nouveau traitement',
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
                      DropdownButtonFormField<String>(
                        initialValue: _productId,
                        decoration: const InputDecoration(labelText: 'Produit'),
                        items: [
                          for (final product in _products)
                            DropdownMenuItem(
                              value: product.id,
                              child: Text(product.name),
                            ),
                        ],
                        onChanged: (value) => setState(() => _productId = value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _diagnosis,
                        decoration: const InputDecoration(
                          labelText: 'Diagnostic',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _symptoms,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Symptômes',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _dose,
                        decoration: const InputDecoration(labelText: 'Dose'),
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
                        controller: _durationDays,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Durée (jours)',
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
                SectionCard(
                  title: 'Traitements en cours',
                  child: _treatments.isEmpty
                      ? const EmptyState(
                          message: 'Aucun traitement',
                          icon: Icons.medication_outlined,
                        )
                      : Column(
                          children: [
                            for (final treatment in _treatments)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: AppTokens.background,
                                  child: Icon(Icons.medication_outlined),
                                ),
                                title: Text(treatment.diagnosis ?? 'Traitement'),
                                subtitle: Text(
                                  '${treatment.status} - délai jusqu’au ${treatment.withdrawalEndDate ?? '-'}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.check_circle_outline),
                                  tooltip: 'Administrer',
                                  onPressed: () => _administer(treatment),
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
