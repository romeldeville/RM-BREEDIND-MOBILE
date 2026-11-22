import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/reproduction/reproduction_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'reproduction_shared.dart';

class ReproductionPage extends ConsumerStatefulWidget {
  const ReproductionPage({super.key});

  @override
  ConsumerState<ReproductionPage> createState() => _ReproductionPageState();
}

class _ReproductionPageState extends ConsumerState<ReproductionPage> {
  List<ReproductionCycle> _cycles = const [];
  List<Animal> _animals = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cycles = await loadCycles(ref);
      final animals = await ref
          .read(herdRepositoryProvider)
          .animals(limit: 100);
      if (mounted) {
        setState(() {
          _cycles = cycles;
          _animals = animals.items;
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

  Future<void> _open(String path) async {
    await context.push(path);
    if (mounted) {
      await _load();
    }
  }

  Future<void> _newCycle() async {
    final input = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _NewCycleDialog(females: _animals),
    );
    if (input == null) {
      return;
    }
    try {
      await ref.read(reproductionRepositoryProvider).createCycle(input);
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
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const Text(
            'Chaleurs, saillies, gestations, mises bas et sevrages.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [
              FilledButton.icon(
                onPressed: _newCycle,
                icon: const Icon(Icons.add),
                label: const Text('Nouveau cycle'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/reproduction/heats'),
                icon: const Icon(Icons.water_drop_outlined),
                label: const Text('Chaleurs'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/reproduction/matings'),
                icon: const Icon(Icons.favorite_outline),
                label: const Text('Saillie'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/reproduction/diagnoses'),
                icon: const Icon(Icons.science_outlined),
                label: const Text('Diagnostic'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/reproduction/births'),
                icon: const Icon(Icons.child_care),
                label: const Text('Mise bas'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/reproduction/weanings'),
                icon: const Icon(Icons.grass_outlined),
                label: const Text('Sevrage'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Cycles de reproduction',
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Column(
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTokens.danger),
                      ),
                      const SizedBox(height: AppTokens.space2),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  )
                : _cycles.isEmpty
                ? const EmptyState(
                    message: 'Aucun cycle de reproduction',
                    icon: Icons.favorite_border,
                  )
                : Column(
                    children: [
                      for (final cycle in _cycles)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppTokens.background,
                            child: Icon(Icons.favorite_border),
                          ),
                          title: Text(cycleLabel(cycle, _animals)),
                          subtitle: Text(
                            'Parité ${cycle.parity} - mise bas prévue: ${cycle.expectedBirthDate ?? '-'}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              _open('/reproduction/cycles/${cycle.id}'),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _NewCycleDialog extends StatefulWidget {
  const _NewCycleDialog({required this.females});

  final List<Animal> females;

  @override
  State<_NewCycleDialog> createState() => _NewCycleDialogState();
}

class _NewCycleDialogState extends State<_NewCycleDialog> {
  final _startDate = TextEditingController(text: todayDate());
  String? _femaleId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final females = widget.females
        .where((animal) => animal.sex == 'FEMALE')
        .toList();
    _femaleId = females.isEmpty ? null : females.first.id;
  }

  @override
  void dispose() {
    _startDate.dispose();
    super.dispose();
  }

  void _submit() {
    final startDate = normalizeDate(_startDate.text);
    if (_femaleId == null || startDate == null) {
      setState(() => _error = 'La femelle et la date sont obligatoires.');
      return;
    }
    Navigator.pop(context, {'femaleId': _femaleId, 'startDate': startDate});
  }

  @override
  Widget build(BuildContext context) {
    final females = widget.females
        .where((animal) => animal.sex == 'FEMALE')
        .toList();
    return AlertDialog(
      title: const Text('Nouveau cycle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppTokens.danger)),
            const SizedBox(height: AppTokens.space2),
          ],
          DropdownButtonFormField<String>(
            initialValue: _femaleId,
            decoration: const InputDecoration(labelText: 'Femelle'),
            items: [
              for (final female in females)
                DropdownMenuItem(
                  value: female.id,
                  child: Text(animalLabel(female)),
                ),
            ],
            onChanged: (value) => setState(() => _femaleId = value),
          ),
          const SizedBox(height: AppTokens.space3),
          TextField(
            controller: _startDate,
            decoration: const InputDecoration(
              labelText: 'Date de début',
              hintText: 'AAAA-MM-JJ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Créer')),
      ],
    );
  }
}
