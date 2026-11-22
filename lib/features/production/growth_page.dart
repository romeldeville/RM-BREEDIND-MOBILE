import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/production/production_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'production_shared.dart';

class GrowthPage extends ConsumerStatefulWidget {
  const GrowthPage({super.key});

  @override
  ConsumerState<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends ConsumerState<GrowthPage> {
  List<Animal> _animals = const [];
  List<Lot> _lots = const [];
  String _target = 'ANIMAL';
  String? _animalId;
  String? _lotId;
  Gmq? _gmq;
  GrowthCurve? _curve;
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
      _gmq = null;
      _curve = null;
    });
    try {
      final repository = ref.read(productionRepositoryProvider);
      final animals = await loadAnimals(ref);
      final lots = await loadLots(ref);
      final animalId = _animalId ?? (animals.isEmpty ? null : animals.first.id);
      final lotId = _lotId ?? (lots.isEmpty ? null : lots.first.id);
      Gmq? gmq;
      GrowthCurve? curve;
      String? error;
      try {
        gmq = await repository.gmq(
          animalId: _target == 'ANIMAL' ? animalId : null,
          lotId: _target == 'LOT' ? lotId : null,
        );
      } on ApiFailure catch (failure) {
        error = failure.message;
      }
      curve = await repository.growthCurve(
        animalId: _target == 'ANIMAL' ? animalId : null,
        lotId: _target == 'LOT' ? lotId : null,
      );
      if (mounted) {
        setState(() {
          _animals = animals;
          _lots = lots;
          _animalId = animalId;
          _lotId = lotId;
          _gmq = gmq;
          _curve = curve;
          _error = error;
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

  @override
  Widget build(BuildContext context) {
    final points = _curve?.points ?? const <GrowthPoint>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Courbe de croissance')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Cible',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _target,
                          decoration: const InputDecoration(labelText: 'Cible'),
                          items: const [
                            DropdownMenuItem(
                              value: 'ANIMAL',
                              child: Text('Animal'),
                            ),
                            DropdownMenuItem(value: 'LOT', child: Text('Lot')),
                          ],
                          onChanged: (value) {
                            setState(() => _target = value ?? _target);
                            _load();
                          },
                        ),
                        const SizedBox(height: AppTokens.space3),
                        if (_target == 'ANIMAL')
                          DropdownButtonFormField<String>(
                            initialValue: _animalId,
                            decoration: const InputDecoration(
                              labelText: 'Animal',
                            ),
                            items: [
                              for (final animal in _animals)
                                DropdownMenuItem(
                                  value: animal.id,
                                  child: Text(
                                    animal.name == null || animal.name!.isEmpty
                                        ? animal.identifier
                                        : '${animal.identifier} - ${animal.name}',
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() => _animalId = value);
                              _load();
                            },
                          )
                        else
                          DropdownButtonFormField<String>(
                            initialValue: _lotId,
                            decoration: const InputDecoration(labelText: 'Lot'),
                            items: [
                              for (final lot in _lots)
                                DropdownMenuItem(
                                  value: lot.id,
                                  child: Text(lot.name),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() => _lotId = value);
                              _load();
                            },
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Gain moyen quotidien',
              child: _gmq == null
                  ? Column(
                      children: [
                        if (_error != null) ...[
                          Text(
                            _error!,
                            style: const TextStyle(color: AppTokens.danger),
                          ),
                          const SizedBox(height: AppTokens.space2),
                        ],
                        const EmptyState(
                          message:
                              'GMQ indisponible (au moins deux pesées requises)',
                          icon: Icons.show_chart_outlined,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatQuantity(_gmq!.gmq)} kg/jour',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Text(
                          '${formatQuantity(_gmq!.startWeightKg)} kg → ${formatQuantity(_gmq!.endWeightKg)} kg sur ${_gmq!.days} jour(s)',
                          style: const TextStyle(color: AppTokens.textMuted),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Points de croissance',
              child: points.isEmpty
                  ? const EmptyState(
                      message: 'Aucune pesée',
                      icon: Icons.monitor_weight_outlined,
                    )
                  : Column(
                      children: [
                        for (final point in points)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.monitor_weight_outlined),
                            ),
                            title: Text('${formatQuantity(point.weightKg)} kg'),
                            subtitle: Text(formatTimestamp(point.weighedAt)),
                            trailing: point.ageDays == null
                                ? null
                                : Text('${point.ageDays} j'),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
