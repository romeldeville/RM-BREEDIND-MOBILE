import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/production/production_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'production_shared.dart';

const _movementTypes = ['SALE', 'LOSS', 'ADJUSTMENT', 'TRANSFER', 'ENTRY'];

class EggStockPage extends ConsumerStatefulWidget {
  const EggStockPage({super.key});

  @override
  ConsumerState<EggStockPage> createState() => _EggStockPageState();
}

class _EggStockPageState extends ConsumerState<EggStockPage> {
  final _quantity = TextEditingController();
  final _reason = TextEditingController();
  final _occurredAt = TextEditingController(text: todayDate());

  List<Lot> _lots = const [];
  List<EggStock> _stocks = const [];
  List<EggMovement> _movements = const [];
  String? _lotId;
  String _type = 'SALE';
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
    _quantity.dispose();
    _reason.dispose();
    _occurredAt.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(productionRepositoryProvider);
      final lots = await loadLots(ref);
      final stocks = await repository.eggStocks();
      final movements = await repository.movements();
      if (!mounted) {
        return;
      }
      setState(() {
        _lots = lots;
        _stocks = stocks;
        _movements = movements;
        _lotId ??= lots.isEmpty ? null : lots.first.id;
      });
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

  Future<void> _submit() async {
    if (_lotId == null) {
      setState(() => _error = 'Sélectionnez un lot.');
      return;
    }
    final quantity = int.tryParse(_quantity.text.trim());
    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Quantité invalide.');
      return;
    }
    final occurredAt = dateToInstant(_occurredAt.text);
    if (occurredAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(productionRepositoryProvider).createMovement({
        'lotId': _lotId,
        'type': _type,
        'quantity': quantity,
        'occurredAt': occurredAt,
        'reason': _reason.text.trim().isEmpty ? null : _reason.text.trim(),
      });
      _quantity.clear();
      _reason.clear();
      final repository = ref.read(productionRepositoryProvider);
      final stocks = await repository.eggStocks();
      final movements = await repository.movements();
      if (mounted) {
        setState(() {
          _stocks = stocks;
          _movements = movements;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mouvement enregistré')),
        );
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
      appBar: AppBar(title: const Text('Stock d’œufs')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Stocks',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _stocks.isEmpty
                  ? const EmptyState(
                      message: 'Aucun stock',
                      icon: Icons.inventory_2_outlined,
                    )
                  : Column(
                      children: [
                        for (final stock in _stocks)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.inventory_2_outlined),
                            ),
                            title: Text(
                              stock.lotId == null
                                  ? 'Ferme'
                                  : 'Lot ${shortId(stock.lotId!)}',
                            ),
                            subtitle: Text(formatTimestamp(stock.updatedAt)),
                            trailing: Text('${stock.quantity} œufs'),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Nouveau mouvement',
              child: Column(
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: AppTokens.danger),
                    ),
                    const SizedBox(height: AppTokens.space2),
                  ],
                  DropdownButtonFormField<String>(
                    initialValue: _lotId,
                    decoration: const InputDecoration(labelText: 'Lot'),
                    items: [
                      for (final lot in _lots)
                        DropdownMenuItem(value: lot.id, child: Text(lot.name)),
                    ],
                    onChanged: (value) => setState(() => _lotId = value),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: [
                      for (final type in _movementTypes)
                        DropdownMenuItem(value: type, child: Text(type)),
                    ],
                    onChanged: (value) => setState(() => _type = value ?? _type),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  TextField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantité'),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  TextField(
                    controller: _occurredAt,
                    decoration: const InputDecoration(labelText: 'Date'),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  TextField(
                    controller: _reason,
                    decoration: const InputDecoration(labelText: 'Motif'),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Mouvements récents',
              child: _movements.isEmpty
                  ? const EmptyState(
                      message: 'Aucun mouvement',
                      icon: Icons.swap_horiz_outlined,
                    )
                  : Column(
                      children: [
                        for (final movement in _movements)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.swap_horiz_outlined),
                            ),
                            title: Text('${movement.type} - ${movement.quantity}'),
                            subtitle: Text(
                              formatTimestamp(movement.occurredAt),
                            ),
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
