import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class LotMovementsPage extends ConsumerStatefulWidget {
  const LotMovementsPage({super.key, required this.lotId});

  final String lotId;

  @override
  ConsumerState<LotMovementsPage> createState() => _LotMovementsPageState();
}

class _LotMovementsPageState extends ConsumerState<LotMovementsPage> {
  static const _types = [
    'ENTRY',
    'EXIT',
    'MORTALITY',
    'SALE',
    'TRANSFER',
    'ADJUSTMENT',
  ];

  final _quantity = TextEditingController(text: '1');
  final _occurredAt = TextEditingController();
  final _reason = TextEditingController();
  Lot? _lot;
  List<LotMovement> _movements = const [];
  String _type = 'ENTRY';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _occurredAt.text = DateTime.now().toIso8601String();
    _load();
  }

  @override
  void dispose() {
    _quantity.dispose();
    _occurredAt.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(herdRepositoryProvider);
      final lot = await repository.lot(widget.lotId);
      final movements = await repository.lotMovements(widget.lotId);
      if (mounted) {
        setState(() {
          _lot = lot;
          _movements = movements;
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

  Future<void> _add() async {
    final quantity = int.tryParse(_quantity.text.trim());
    if (quantity == null || quantity < 1) {
      setState(() => _error = "La quantité doit être un entier positif.");
      return;
    }
    final occurredAt = DateTime.tryParse(_occurredAt.text.trim());
    if (occurredAt == null) {
      setState(() => _error = 'La date doit être au format ISO.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(herdRepositoryProvider).moveLot(widget.lotId, {
        'type': _type,
        'quantity': quantity,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        'reason': _reason.text.trim().isEmpty ? null : _reason.text.trim(),
      });
      _quantity.text = '1';
      _reason.clear();
      await _load();
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
        title: Text(_lot == null ? 'Mouvements' : 'Mouvements · ${_lot!.name}'),
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
                  title: 'Nouveau mouvement',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: [
                          for (final type in _types)
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
                        decoration: const InputDecoration(labelText: 'Date et heure (ISO)'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _reason,
                        decoration: const InputDecoration(labelText: 'Motif'),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _saving ? null : _add,
                          child: const Text('Enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                SectionCard(
                  title: 'Historique',
                  child: _movements.isEmpty
                      ? const Text(
                          'Aucun mouvement enregistré.',
                          style: TextStyle(color: AppTokens.textMuted),
                        )
                      : Column(
                          children: [
                            for (final movement in _movements)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.swap_vert),
                                title: Text('${movement.type} · ${movement.quantity}'),
                                subtitle: Text(
                                  '${movement.occurredAt}'
                                  '${movement.reason == null ? '' : ' · ${movement.reason}'}',
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
