import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class SpeciesFormPage extends ConsumerStatefulWidget {
  const SpeciesFormPage({super.key, this.speciesId});

  final String? speciesId;

  @override
  ConsumerState<SpeciesFormPage> createState() => _SpeciesFormPageState();
}

class _SpeciesFormPageState extends ConsumerState<SpeciesFormPage> {
  static const _productionTypes = ['MEAT', 'MILK', 'EGGS', 'MIXED', 'OTHER'];
  static const _trackingModes = ['INDIVIDUAL', 'LOT', 'HYBRID'];

  final _name = TextEditingController();
  final _code = TextEditingController();
  final _gestation = TextEditingController();
  final _heatCycle = TextEditingController();
  final _weaning = TextEditingController();
  final _incubation = TextEditingController();
  final _settings = TextEditingController(text: '{}');
  final _templateName = TextEditingController();

  String _productionType = 'MIXED';
  String _trackingMode = 'INDIVIDUAL';
  List<SpeciesTemplate> _templates = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.speciesId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _load();
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _gestation.dispose();
    _heatCycle.dispose();
    _weaning.dispose();
    _incubation.dispose();
    _settings.dispose();
    _templateName.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repository = ref.read(referentialRepositoryProvider);
      final species = await repository.speciesById(widget.speciesId!);
      final templates = await repository.templates(widget.speciesId!);
      if (!mounted) {
        return;
      }
      setState(() {
        _name.text = species.name;
        _code.text = species.code;
        _productionType = species.productionType;
        _trackingMode = species.trackingMode;
        _gestation.text = species.gestationDays?.toString() ?? '';
        _heatCycle.text = species.heatCycleDays?.toString() ?? '';
        _weaning.text = species.weaningAgeDays?.toString() ?? '';
        _incubation.text = species.incubationDays?.toString() ?? '';
        _settings.text = const JsonEncoder.withIndent('  ').convert(species.settings);
        _templates = templates;
        _loading = false;
      });
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
    if (_name.text.trim().isEmpty || _code.text.trim().isEmpty) {
      setState(() => _error = 'Le nom et le code sont obligatoires.');
      return;
    }
    Map<String, dynamic> settings;
    try {
      final decoded = jsonDecode(_settings.text.trim().isEmpty ? '{}' : _settings.text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException();
      }
      settings = decoded;
    } on FormatException {
      setState(() => _error = 'Le JSON des paramètres est invalide.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'code': _code.text.trim(),
      'productionType': _productionType,
      'trackingMode': _trackingMode,
      'gestationDays': _intOrNull(_gestation.text),
      'heatCycleDays': _intOrNull(_heatCycle.text),
      'weaningAgeDays': _intOrNull(_weaning.text),
      'incubationDays': _intOrNull(_incubation.text),
      'settings': settings,
    };
    try {
      final repository = ref.read(referentialRepositoryProvider);
      if (_isEdit) {
        body.remove('code');
        await repository.patchSpecies(widget.speciesId!, body);
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Espèce enregistrée.')),
          );
        }
      } else {
        await repository.createSpecies(body);
        if (mounted) {
          context.pop();
        }
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

  Future<void> _addTemplate() async {
    final name = _templateName.text.trim();
    if (name.isEmpty || !_isEdit) {
      return;
    }
    try {
      final template = await ref
          .read(referentialRepositoryProvider)
          .createTemplate(widget.speciesId!, {'name': name});
      _templateName.clear();
      if (mounted) {
        setState(() => _templates = [..._templates, template]);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _removeTemplate(SpeciesTemplate template) async {
    try {
      await ref.read(referentialRepositoryProvider).deleteTemplate(template.id);
      if (mounted) {
        setState(() => _templates = _templates.where((t) => t.id != template.id).toList());
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
      appBar: AppBar(
        title: Text(_isEdit ? 'Modifier l’espèce' : 'Nouvelle espèce'),
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
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nom'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _code,
                        enabled: !_isEdit,
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          helperText: 'Minuscules, chiffres et tirets',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _productionType,
                        decoration: const InputDecoration(labelText: 'Production'),
                        items: [
                          for (final type in _productionTypes)
                            DropdownMenuItem(value: type, child: Text(type)),
                        ],
                        onChanged: (value) =>
                            setState(() => _productionType = value ?? _productionType),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _trackingMode,
                        decoration: const InputDecoration(labelText: 'Suivi'),
                        items: [
                          for (final mode in _trackingModes)
                            DropdownMenuItem(value: mode, child: Text(mode)),
                        ],
                        onChanged: (value) =>
                            setState(() => _trackingMode = value ?? _trackingMode),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Reproduction',
                  child: Column(
                    children: [
                      _numberField(_gestation, 'Gestation (jours)'),
                      _numberField(_heatCycle, 'Cycle de chaleur (jours)'),
                      _numberField(_weaning, 'Sevrage (jours)'),
                      _numberField(_incubation, 'Incubation (jours)'),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Paramètres (JSON)',
                  child: TextField(
                    controller: _settings,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: '{"lactationDays": 305}',
                    ),
                  ),
                ),
                if (_isEdit) ...[
                  const SizedBox(height: AppTokens.space4),
                  SectionCard(
                    title: 'Gabarits',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final template in _templates)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(template.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Supprimer',
                              onPressed: () => _removeTemplate(template),
                            ),
                          ),
                        if (_templates.isEmpty)
                          const Text(
                            'Aucun gabarit.',
                            style: TextStyle(color: AppTokens.textMuted),
                          ),
                        const SizedBox(height: AppTokens.space3),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _templateName,
                                decoration: const InputDecoration(labelText: 'Nom du gabarit'),
                              ),
                            ),
                            const SizedBox(width: AppTokens.space2),
                            FilledButton(
                              onPressed: _addTemplate,
                              child: const Text('Ajouter'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space3),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
