import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/referential/referential_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class SitesPage extends ConsumerStatefulWidget {
  const SitesPage({super.key});

  @override
  ConsumerState<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends ConsumerState<SitesPage> {
  List<Farm> _farms = const [];
  List<Building> _buildings = const [];
  List<Pen> _pens = const [];
  final Map<String, PenOccupancy> _occupancies = {};
  String? _selectedFarmId;
  String? _selectedBuildingId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  Future<void> _loadFarms() async {
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
        await _loadBuildings(_selectedFarmId!);
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

  Future<void> _loadBuildings(String farmId) async {
    try {
      final buildings = await ref.read(referentialRepositoryProvider).buildings(farmId);
      if (!mounted) {
        return;
      }
      setState(() {
        _buildings = buildings;
        _pens = const [];
        _selectedBuildingId = null;
      });
      if (buildings.isNotEmpty) {
        await _selectBuilding(buildings.first);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _selectBuilding(Building building) async {
    setState(() {
      _selectedBuildingId = building.id;
      _pens = const [];
    });
    try {
      final pens = await ref.read(referentialRepositoryProvider).pens(building.id);
      if (!mounted) {
        return;
      }
      setState(() => _pens = pens);
      for (final pen in pens) {
        _loadOccupancy(pen.id);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  Future<void> _loadOccupancy(String penId) async {
    try {
      final occupancy = await ref.read(referentialRepositoryProvider).occupancy(penId);
      if (mounted) {
        setState(() => _occupancies[penId] = occupancy);
      }
    } on ApiFailure {
      // Occupancy is informative only.
    }
  }

  Future<void> _addBuilding() async {
    final farmId = _selectedFarmId;
    if (farmId == null) {
      return;
    }
    final name = TextEditingController();
    final type = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau bâtiment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nom du bâtiment'),
            ),
            const SizedBox(height: AppTokens.space3),
            TextField(
              controller: type,
              decoration: const InputDecoration(labelText: 'Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (confirmed != true || name.text.trim().isEmpty) {
      name.dispose();
      type.dispose();
      return;
    }
    try {
      final building = await ref.read(referentialRepositoryProvider).createBuilding({
        'farmId': farmId,
        'name': name.text.trim(),
        'type': type.text.trim().isEmpty ? null : type.text.trim(),
      });
      if (mounted) {
        setState(() => _buildings = [..._buildings, building]);
        await _selectBuilding(building);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      name.dispose();
      type.dispose();
    }
  }

  Future<void> _addPen() async {
    final buildingId = _selectedBuildingId;
    if (buildingId == null) {
      return;
    }
    final name = TextEditingController();
    final capacity = TextEditingController(text: '0');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle loge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nom de la loge'),
            ),
            const SizedBox(height: AppTokens.space3),
            TextField(
              controller: capacity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capacité'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
    if (confirmed != true || name.text.trim().isEmpty) {
      name.dispose();
      capacity.dispose();
      return;
    }
    try {
      final pen = await ref.read(referentialRepositoryProvider).createPen({
        'buildingId': buildingId,
        'name': name.text.trim(),
        'capacity': int.tryParse(capacity.text.trim()) ?? 0,
      });
      if (mounted) {
        setState(() => _pens = [..._pens, pen]);
        await _loadOccupancy(pen.id);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      name.dispose();
      capacity.dispose();
    }
  }

  Future<void> _archivePen(Pen pen) async {
    try {
      await ref.read(referentialRepositoryProvider).archivePen(pen.id);
      if (mounted) {
        setState(() => _pens = _pens.where((p) => p.id != pen.id).toList());
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadFarms,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const Text(
            'Structure physique de la ferme et occupation des loges.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppTokens.danger)),
            const SizedBox(height: AppTokens.space3),
          ],
          if (_farms.isEmpty)
            const EmptyState(message: 'Aucune ferme disponible.')
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
                  _loadBuildings(value);
                }
              },
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Bâtiments',
              trailing: IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Nouveau bâtiment',
                onPressed: _addBuilding,
              ),
              child: Column(
                children: [
                  for (final building in _buildings)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      selected: building.id == _selectedBuildingId,
                      title: Text(building.name),
                      subtitle: Text(building.type ?? '—'),
                      onTap: () => _selectBuilding(building),
                    ),
                  if (_buildings.isEmpty)
                    const Text(
                      'Aucun bâtiment.',
                      style: TextStyle(color: AppTokens.textMuted),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Loges',
              trailing: IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Nouvelle loge',
                onPressed: _selectedBuildingId == null ? null : _addPen,
              ),
              child: Column(
                children: [
                  if (_selectedBuildingId == null)
                    const Text(
                      'Sélectionnez un bâtiment.',
                      style: TextStyle(color: AppTokens.textMuted),
                    ),
                  for (final pen in _pens)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(pen.name),
                      subtitle: Text(_occupancyLabel(pen)),
                      trailing: IconButton(
                        icon: const Icon(Icons.archive_outlined),
                        tooltip: 'Archiver',
                        onPressed: () => _archivePen(pen),
                      ),
                    ),
                  if (_selectedBuildingId != null && _pens.isEmpty)
                    const Text(
                      'Aucune loge.',
                      style: TextStyle(color: AppTokens.textMuted),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            OutlinedButton.icon(
              onPressed: () => context.push('/sites/plan'),
              icon: const Icon(Icons.map_outlined),
              label: const Text('Voir le plan de ferme'),
            ),
          ],
        ],
      ),
    );
  }

  String _occupancyLabel(Pen pen) {
    final occupancy = _occupancies[pen.id];
    final occupied = occupancy?.occupied ?? 0;
    return '$occupied / ${pen.capacity} occupés';
  }
}
