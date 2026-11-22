import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class LotFormPage extends ConsumerStatefulWidget {
  const LotFormPage({super.key, this.lotId});

  final String? lotId;

  @override
  ConsumerState<LotFormPage> createState() => _LotFormPageState();
}

class _LotFormPageState extends ConsumerState<LotFormPage> {
  static const _productionTypes = ['MEAT', 'MILK', 'EGGS', 'MIXED', 'WORK', 'OTHER'];

  final _name = TextEditingController();
  final _code = TextEditingController();
  final _entryDate = TextEditingController();
  final _initialCount = TextEditingController(text: '0');
  final _unitCost = TextEditingController();

  List<Farm> _farms = const [];
  List<Species> _species = const [];
  String? _farmId;
  String? _speciesId;
  String _productionType = 'MIXED';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.lotId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _entryDate.dispose();
    _initialCount.dispose();
    _unitCost.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final referential = ref.read(referentialRepositoryProvider);
      final farms = await referential.farms();
      final species = await referential.species();
      Lot? lot;
      if (_isEdit) {
        lot = await ref.read(herdRepositoryProvider).lot(widget.lotId!);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _farms = farms;
        _species = species;
        _farmId = lot?.farmId ?? (farms.isEmpty ? null : farms.first.id);
        _speciesId = lot?.speciesId ?? (species.isEmpty ? null : species.first.id);
        if (lot != null) {
          _name.text = lot.name;
          _code.text = lot.code ?? '';
          _productionType = lot.productionType ?? 'MIXED';
          _entryDate.text = lot.entryDate ?? '';
          _initialCount.text = lot.initialCount.toString();
          _unitCost.text = lot.unitCost?.toString() ?? '';
        }
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
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Le nom est obligatoire.');
      return;
    }
    if (!_isEdit && (_farmId == null || _speciesId == null)) {
      setState(() => _error = 'La ferme et l\'espèce sont obligatoires.');
      return;
    }
    final entryDate = _parseDate(_entryDate.text);
    if (_entryDate.text.trim().isNotEmpty && entryDate == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'code': _code.text.trim().isEmpty ? null : _code.text.trim(),
      'productionType': _productionType,
      'entryDate': entryDate,
      'unitCost': double.tryParse(_unitCost.text.trim()),
    };
    try {
      final repository = ref.read(herdRepositoryProvider);
      if (_isEdit) {
        await repository.patchLot(widget.lotId!, body);
      } else {
        body['farmId'] = _farmId;
        body['speciesId'] = _speciesId;
        body['initialCount'] = int.tryParse(_initialCount.text.trim()) ?? 0;
        await repository.createLot(body);
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
        title: Text(_isEdit ? 'Modifier le lot' : 'Nouveau lot'),
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
                  title: 'Lot',
                  child: Column(
                    children: [
                      TextField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nom'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _code,
                        decoration: const InputDecoration(labelText: 'Code'),
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
                            : (value) => setState(() => _speciesId = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Effectif et coût',
                  child: Column(
                    children: [
                      TextField(
                        controller: _entryDate,
                        decoration: const InputDecoration(
                          labelText: "Date d'entrée",
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _initialCount,
                        enabled: !_isEdit,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Effectif initial'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _unitCost,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Coût unitaire'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
