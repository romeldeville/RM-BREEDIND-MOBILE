import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/reproduction/reproduction_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'reproduction_shared.dart';

class WeaningFormPage extends ConsumerStatefulWidget {
  const WeaningFormPage({super.key, this.cycleId, this.litterId});

  final String? cycleId;
  final String? litterId;

  @override
  ConsumerState<WeaningFormPage> createState() => _WeaningFormPageState();
}

class _WeaningFormPageState extends ConsumerState<WeaningFormPage> {
  final _weanedAt = TextEditingController(text: todayDate());
  final _count = TextEditingController();
  final _averageWeight = TextEditingController();

  List<ReproductionCycle> _cycles = const [];
  List<Animal> _animals = const [];
  List<Litter> _litters = const [];
  String? _cycleId;
  String? _litterId;
  bool _loading = true;
  bool _loadingLitters = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _weanedAt.dispose();
    _count.dispose();
    _averageWeight.dispose();
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
      if (_cycleId != null) {
        await _loadLitters(_cycleId!, initialLitterId: widget.litterId);
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

  Future<void> _loadLitters(String cycleId, {String? initialLitterId}) async {
    setState(() => _loadingLitters = true);
    try {
      final detail = await ref
          .read(reproductionRepositoryProvider)
          .cycle(cycleId);
      if (mounted) {
        setState(() {
          _litters = detail.litters;
          _litterId =
              initialLitterId != null &&
                  detail.litters.any((litter) => litter.id == initialLitterId)
              ? initialLitterId
              : (detail.litters.isEmpty ? null : detail.litters.first.id);
          final litter = _litterId == null
              ? null
              : detail.litters.firstWhere((litter) => litter.id == _litterId);
          if (litter != null && _count.text.isEmpty) {
            _count.text = (litter.weanedCount ?? litter.bornAlive).toString();
          }
        });
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _loadingLitters = false);
      }
    }
  }

  void _selectCycle(String? value) {
    if (value == null) {
      return;
    }
    setState(() {
      _cycleId = value;
      _litters = const [];
      _litterId = null;
    });
    _loadLitters(value);
  }

  void _selectLitter(String? value) {
    Litter? selected;
    for (final litter in _litters) {
      if (litter.id == value) {
        selected = litter;
        break;
      }
    }
    setState(() {
      _litterId = value;
      if (selected != null) {
        _count.text = (selected.weanedCount ?? selected.bornAlive).toString();
      }
    });
  }

  Future<void> _save() async {
    if (_litterId == null) {
      setState(() => _error = 'La portée est obligatoire.');
      return;
    }
    final weanedAt = dateToInstant(_weanedAt.text);
    if (weanedAt == null) {
      setState(() => _error = 'La date doit être au format AAAA-MM-JJ.');
      return;
    }
    final count = int.tryParse(_count.text.trim());
    if (count == null || count < 0) {
      setState(() => _error = 'Le nombre de sevrés est invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(reproductionRepositoryProvider).recordWeaning({
        'litterId': _litterId,
        'weanedAt': weanedAt,
        'count': count,
        'averageWeight': double.tryParse(_averageWeight.text.trim()),
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
        title: const Text('Sevrage'),
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
                  title: 'Sevrage de la portée',
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
                        onChanged: _selectCycle,
                      ),
                      const SizedBox(height: AppTokens.space3),
                      if (_loadingLitters)
                        const Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _litterId,
                          decoration: const InputDecoration(
                            labelText: 'Portée',
                          ),
                          items: [
                            for (final litter in _litters)
                              DropdownMenuItem(
                                value: litter.id,
                                child: Text(
                                  '${litter.name} - ${litter.bornAlive} nés vivants',
                                ),
                              ),
                          ],
                          onChanged: _selectLitter,
                        ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _weanedAt,
                        decoration: const InputDecoration(
                          labelText: 'Date de sevrage',
                          hintText: 'AAAA-MM-JJ',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _count,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nombre sevré',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _averageWeight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Poids moyen (kg)',
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_loadingLitters && _litters.isEmpty) ...[
                  const SizedBox(height: AppTokens.space4),
                  const Text(
                    'Aucune portée disponible pour ce cycle.',
                    style: TextStyle(color: AppTokens.textMuted),
                  ),
                ],
              ],
            ),
    );
  }
}
