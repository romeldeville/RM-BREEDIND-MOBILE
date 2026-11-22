import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';

class FarmPlanPage extends ConsumerStatefulWidget {
  const FarmPlanPage({super.key});

  @override
  ConsumerState<FarmPlanPage> createState() => _FarmPlanPageState();
}

class _FarmPlanPageState extends ConsumerState<FarmPlanPage> {
  List<Farm> _farms = const [];
  List<Building> _buildings = const [];
  final Map<String, List<Pen>> _pensByBuilding = {};
  final Map<String, PenOccupancy> _occupancies = {};
  String? _selectedFarmId;
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
      final farms = await ref.read(referentialRepositoryProvider).farms();
      if (!mounted) {
        return;
      }
      setState(() {
        _farms = farms;
        _selectedFarmId = farms.isEmpty ? null : farms.first.id;
        _loading = false;
      });
      if (_selectedFarmId != null) {
        await _loadPlan(_selectedFarmId!);
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

  Future<void> _loadPlan(String farmId) async {
    setState(() {
      _loading = true;
      _error = null;
      _pensByBuilding.clear();
    });
    try {
      final repository = ref.read(referentialRepositoryProvider);
      final buildings = await repository.buildings(farmId);
      for (final building in buildings) {
        final pens = await repository.pens(building.id);
        _pensByBuilding[building.id] = pens;
        for (final pen in pens) {
          final occupancy = await repository.occupancy(pen.id);
          _occupancies[pen.id] = occupancy;
        }
      }
      if (mounted) {
        setState(() {
          _buildings = buildings;
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space4),
      children: [
        const Text(
          'Vue d’ensemble des bâtiments et de l’occupation.',
          style: TextStyle(color: AppTokens.textMuted),
        ),
        const SizedBox(height: AppTokens.space4),
        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: AppTokens.danger)),
          const SizedBox(height: AppTokens.space3),
        ],
        if (_farms.isEmpty)
          const Text(
            'Aucune ferme disponible.',
            style: TextStyle(color: AppTokens.textMuted),
          )
        else ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedFarmId,
            decoration: const InputDecoration(labelText: 'Ferme'),
            items: [
              for (final farm in _farms)
                DropdownMenuItem(value: farm.id, child: Text(farm.name)),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedFarmId = value);
                _loadPlan(value);
              }
            },
          ),
          const SizedBox(height: AppTokens.space4),
          if (_buildings.isEmpty)
            const Text(
              'Aucun bâtiment à afficher.',
              style: TextStyle(color: AppTokens.textMuted),
            )
          else
            for (final building in _buildings)
              Card(
                margin: const EdgeInsets.only(bottom: AppTokens.space4),
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.space4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Wrap(
                        spacing: AppTokens.space2,
                        runSpacing: AppTokens.space2,
                        children: [
                          for (final pen in _pensByBuilding[building.id] ?? const <Pen>[])
                            _PenTile(
                              pen: pen,
                              occupancy: _occupancies[pen.id],
                            ),
                          if ((_pensByBuilding[building.id] ?? const <Pen>[]).isEmpty)
                            const Text(
                              'Aucune loge.',
                              style: TextStyle(color: AppTokens.textMuted),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }

}

class _PenTile extends StatelessWidget {
  const _PenTile({required this.pen, this.occupancy});

  final Pen pen;
  final PenOccupancy? occupancy;

  @override
  Widget build(BuildContext context) {
    final occupied = occupancy?.occupied ?? 0;
    final percent = pen.capacity <= 0 ? 0.0 : (occupied / pen.capacity).clamp(0.0, 1.0);
    final full = percent >= 1.0;
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppTokens.space2),
      decoration: BoxDecoration(
        color: full ? const Color(0xFFFEF3F2) : const Color(0xFFF8FAF8),
        border: Border.all(color: full ? AppTokens.danger : AppTokens.border),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pen.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppTokens.space1),
          Text(
            '$occupied / ${pen.capacity} occupés',
            style: const TextStyle(color: AppTokens.textMuted, fontSize: 14),
          ),
          const SizedBox(height: AppTokens.space2),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: AppTokens.border,
              valueColor: AlwaysStoppedAnimation(
                full ? AppTokens.danger : AppTokens.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
