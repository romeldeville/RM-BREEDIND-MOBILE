import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/sales/sales_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'sales_shared.dart';

class SaleFormPage extends ConsumerStatefulWidget {
  const SaleFormPage({super.key});

  @override
  ConsumerState<SaleFormPage> createState() => _SaleFormPageState();
}

class _SaleFormPageState extends ConsumerState<SaleFormPage> {
  final _quantity = TextEditingController(text: '1');
  final _unitPrice = TextEditingController();
  final _description = TextEditingController();
  final _soldAt = TextEditingController(text: todayDate());

  List<Customer> _customers = const [];
  List<Animal> _animals = const [];
  List<Lot> _lots = const [];
  String _type = 'ANIMAL';
  String? _customerId;
  String? _animalId;
  String? _lotId;
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
    _unitPrice.dispose();
    _description.dispose();
    _soldAt.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final customers = await ref.read(salesRepositoryProvider).customers();
      final animals = await loadAnimals(ref);
      final lots = await loadLots(ref);
      if (mounted) {
        setState(() {
          _customers = customers;
          _animals = animals;
          _lots = lots;
          _animalId ??= animals.isEmpty ? null : animals.first.id;
          _lotId ??= lots.isEmpty ? null : lots.first.id;
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

  Future<void> _submit() async {
    final soldAt = dateToInstant(_soldAt.text);
    if (soldAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    final unitPrice = double.tryParse(_unitPrice.text.replaceAll(',', '.'));
    if (unitPrice == null || unitPrice < 0) {
      setState(() => _error = 'Prix unitaire invalide.');
      return;
    }
    final quantity = _type == 'ANIMAL'
        ? 1.0
        : double.tryParse(_quantity.text.replaceAll(',', '.'));
    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Quantité invalide.');
      return;
    }
    if (_type == 'ANIMAL' && _animalId == null) {
      setState(() => _error = 'Sélectionnez un animal.');
      return;
    }
    if ((_type == 'LOT' || _type == 'EGGS') && _lotId == null) {
      setState(() => _error = 'Sélectionnez un lot.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(salesRepositoryProvider).createSale({
        if (_customerId != null) 'customerId': _customerId,
        'type': _type,
        'soldAt': soldAt,
        'currency': 'XOF',
        'lines': [
          {
            'itemType': _type,
            'animalId': _type == 'ANIMAL' ? _animalId : null,
            'lotId': _type == 'LOT' || _type == 'EGGS' ? _lotId : null,
            if (_description.text.trim().isNotEmpty)
              'description': _description.text.trim(),
            'quantity': quantity,
            'unitPrice': unitPrice,
          },
        ],
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vente enregistrée')),
        );
        Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Nouvelle vente')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppTokens.space4),
              children: [
                SectionCard(
                  title: 'Vente',
                  child: Column(
                    children: [
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: const TextStyle(color: AppTokens.danger),
                        ),
                        const SizedBox(height: AppTokens.space2),
                      ],
                      DropdownButtonFormField<String?>(
                        initialValue: _customerId,
                        decoration: const InputDecoration(
                          labelText: 'Client (optionnel)',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('—'),
                          ),
                          for (final customer in _customers)
                            DropdownMenuItem<String?>(
                              value: customer.id,
                              child: Text(customer.name),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _customerId = value),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ANIMAL', child: Text('Animal')),
                          DropdownMenuItem(value: 'LOT', child: Text('Lot')),
                          DropdownMenuItem(value: 'EGGS', child: Text('Œufs')),
                          DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
                        ],
                        onChanged: (value) =>
                            setState(() => _type = value ?? _type),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      if (_type == 'ANIMAL')
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
                          onChanged: (value) =>
                              setState(() => _animalId = value),
                        )
                      else if (_type == 'LOT' || _type == 'EGGS')
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
                          onChanged: (value) => setState(() => _lotId = value),
                        )
                      else
                        TextField(
                          controller: _description,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                      if (_type != 'ANIMAL') ...[
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _quantity,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Quantité',
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _unitPrice,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Prix unitaire',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      TextField(
                        controller: _soldAt,
                        decoration: const InputDecoration(
                          labelText: 'Date de vente',
                        ),
                      ),
                      const SizedBox(height: AppTokens.space4),
                      FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
