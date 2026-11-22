import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class SpeciesPlansPage extends ConsumerStatefulWidget {
  const SpeciesPlansPage({super.key, required this.speciesId});

  final String speciesId;

  @override
  ConsumerState<SpeciesPlansPage> createState() => _SpeciesPlansPageState();
}

class _SpeciesPlansPageState extends ConsumerState<SpeciesPlansPage> {
  final _vaccinationName = TextEditingController();
  final _ageDays = TextEditingController();
  final _boosterDays = TextEditingController();
  final _feedingName = TextEditingController();
  final _stages = TextEditingController(text: '[]');

  List<VaccinationPlan> _vaccinationPlans = const [];
  List<FeedingPlan> _feedingPlans = const [];
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
    _vaccinationName.dispose();
    _ageDays.dispose();
    _boosterDays.dispose();
    _feedingName.dispose();
    _stages.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(referentialRepositoryProvider);
      final vaccination = await repository.vaccinationPlans(widget.speciesId);
      final feeding = await repository.feedingPlans(widget.speciesId);
      if (mounted) {
        setState(() {
          _vaccinationPlans = vaccination;
          _feedingPlans = feeding;
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

  Future<void> _addVaccination() async {
    if (_vaccinationName.text.trim().isEmpty) {
      setState(() => _error = 'Le nom du plan est obligatoire.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final plan = await ref.read(referentialRepositoryProvider).createVaccinationPlan(
            widget.speciesId,
            {
              'name': _vaccinationName.text.trim(),
              'ageDays': _intOrNull(_ageDays.text),
              'boosterDays': _intOrNull(_boosterDays.text),
            },
          );
      _vaccinationName.clear();
      _ageDays.clear();
      _boosterDays.clear();
      if (mounted) {
        setState(() => _vaccinationPlans = [..._vaccinationPlans, plan]);
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

  Future<void> _addFeeding() async {
    if (_feedingName.text.trim().isEmpty) {
      setState(() => _error = 'Le nom du plan est obligatoire.');
      return;
    }
    final List<dynamic> stages;
    try {
      final decoded = jsonDecode(_stages.text.trim().isEmpty ? '[]' : _stages.text);
      if (decoded is! List<dynamic>) {
        throw const FormatException();
      }
      stages = decoded;
    } on FormatException {
      setState(() => _error = 'Le JSON des étapes doit être un tableau.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final plan = await ref.read(referentialRepositoryProvider).createFeedingPlan(
            widget.speciesId,
            {'name': _feedingName.text.trim(), 'stages': stages},
          );
      _feedingName.clear();
      _stages.text = '[]';
      if (mounted) {
        setState(() => _feedingPlans = [..._feedingPlans, plan]);
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

  Future<void> _removeVaccination(VaccinationPlan plan) async {
    try {
      await ref.read(referentialRepositoryProvider).deleteVaccinationPlan(plan.id);
      if (mounted) {
        setState(() => _vaccinationPlans =
            _vaccinationPlans.where((p) => p.id != plan.id).toList());
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _removeFeeding(FeedingPlan plan) async {
    try {
      await ref.read(referentialRepositoryProvider).deleteFeedingPlan(plan.id);
      if (mounted) {
        setState(() => _feedingPlans = _feedingPlans.where((p) => p.id != plan.id).toList());
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  int? _intOrNull(String value) => value.trim().isEmpty ? null : int.tryParse(value.trim());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plans sanitaires et alimentaires')),
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
                  title: 'Vaccination',
                  child: Column(
                    children: [
                      TextField(
                        controller: _vaccinationName,
                        decoration: const InputDecoration(labelText: 'Nom du plan'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Row(
                        children: [
                          Expanded(child: _numberField(_ageDays, 'Âge (jours)')),
                          const SizedBox(width: AppTokens.space2),
                          Expanded(child: _numberField(_boosterDays, 'Rappel (jours)')),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _saving ? null : _addVaccination,
                          child: const Text('Ajouter'),
                        ),
                      ),
                      const Divider(height: AppTokens.space6),
                      for (final plan in _vaccinationPlans)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(plan.name),
                          subtitle: Text(
                            '${plan.ageDays ?? '—'} j'
                            '${plan.boosterDays != null ? ' · rappel ${plan.boosterDays} j' : ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Supprimer',
                            onPressed: () => _removeVaccination(plan),
                          ),
                        ),
                      if (_vaccinationPlans.isEmpty)
                        const Text(
                          'Aucun plan de vaccination.',
                          style: TextStyle(color: AppTokens.textMuted),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Alimentation',
                  child: Column(
                    children: [
                      TextField(
                        controller: _feedingName,
                        decoration: const InputDecoration(labelText: 'Nom du plan'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _stages,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Étapes (JSON)',
                          hintText: '[{"stage":"Croissance","kgPerDay":2.5}]',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _saving ? null : _addFeeding,
                          child: const Text('Ajouter'),
                        ),
                      ),
                      const Divider(height: AppTokens.space6),
                      for (final plan in _feedingPlans)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(plan.name),
                          subtitle: Text('${plan.stageCount} étape(s)'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Supprimer',
                            onPressed: () => _removeFeeding(plan),
                          ),
                        ),
                      if (_feedingPlans.isEmpty)
                        const Text(
                          'Aucun plan d’alimentation.',
                          style: TextStyle(color: AppTokens.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}
