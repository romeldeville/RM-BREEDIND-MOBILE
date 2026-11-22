import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/health/health_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'health_shared.dart';

class VaccinationFormPage extends ConsumerStatefulWidget {
  const VaccinationFormPage({super.key});

  @override
  ConsumerState<VaccinationFormPage> createState() =>
      _VaccinationFormPageState();
}

class _VaccinationFormPageState extends ConsumerState<VaccinationFormPage> {
  final _performedAt = TextEditingController(text: todayDate());
  final _vaccineLot = TextEditingController();
  final _dose = TextEditingController();
  final _notes = TextEditingController();

  List<Animal> _animals = const [];
  List<HealthProduct> _products = const [];
  List<Vaccination> _recent = const [];
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
    _performedAt.dispose();
    _vaccineLot.dispose();
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
      final recent = await ref.read(healthRepositoryProvider).vaccinations();
      if (mounted) {
        setState(() {
          _animals = animals;
          _products = products;
          _recent = recent;
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
    final performedAt = dateToInstant(_performedAt.text);
    if (performedAt == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(healthRepositoryProvider).recordVaccination({
        'animalId': _animalId,
        'productId': _productId,
        'performedAt': performedAt,
        'vaccineLot': _vaccineLot.text.trim().isEmpty
            ? null
            : _vaccineLot.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination'),
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
                  title: 'Nouvelle vaccination',
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
                        controller: _performedAt,
                        decoration: const InputDecoration(
                          labelText: 'Date de vaccination',
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _vaccineLot,
                        decoration: const InputDecoration(
                          labelText: 'N° de lot du vaccin',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _dose,
                        decoration: const InputDecoration(labelText: 'Dose'),
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
                  title: 'Vaccinations récentes',
                  child: _recent.isEmpty
                      ? const EmptyState(
                          message: 'Aucune vaccination enregistrée',
                          icon: Icons.vaccines_outlined,
                        )
                      : Column(
                          children: [
                            for (final vaccination in _recent)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: AppTokens.background,
                                  child: Icon(Icons.vaccines_outlined),
                                ),
                                title: Text(
                                  vaccination.animalId == null
                                      ? 'Lot ${shortId(vaccination.lotId ?? '')}'
                                      : 'Animal ${shortId(vaccination.animalId!)}',
                                ),
                                subtitle: Text(
                                  '${formatTimestamp(vaccination.performedAt)} - lot vaccin ${vaccination.vaccineLot ?? '-'}',
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
