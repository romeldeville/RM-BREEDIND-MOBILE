import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/health/health_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  List<HealthProduct> _products = const [];
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
      final products = await ref.read(healthRepositoryProvider).products();
      if (mounted) {
        setState(() => _products = products);
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

  Future<void> _create() async {
    final input = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ProductDialog(),
    );
    if (input == null) {
      return;
    }
    try {
      await ref.read(healthRepositoryProvider).createProduct(input);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Produits vétérinaires')),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Produits',
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
                  : _products.isEmpty
                  ? const EmptyState(
                      message: 'Aucun produit vétérinaire',
                      icon: Icons.inventory_2_outlined,
                    )
                  : Column(
                      children: [
                        for (final product in _products)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.inventory_2_outlined),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              '${product.type ?? '-'} - délai viande ${product.withdrawalMeatDays} j',
                            ),
                            trailing: Text(
                              product.stockQty == null
                                  ? '-'
                                  : '${product.stockQty}',
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

class _ProductDialog extends StatefulWidget {
  const _ProductDialog();

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  static const _types = ['VACCINE', 'ANTIBIOTIC', 'ANTIPARASITIC', 'OTHER'];

  final _name = TextEditingController();
  final _dose = TextEditingController();
  final _meatDays = TextEditingController(text: '0');
  final _milkDays = TextEditingController(text: '0');
  String _type = 'VACCINE';
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _meatDays.dispose();
    _milkDays.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Le nom est obligatoire.');
      return;
    }
    Navigator.pop(context, {
      'name': _name.text.trim(),
      'type': _type,
      'dose': _dose.text.trim().isEmpty ? null : _dose.text.trim(),
      'withdrawalMeatDays': int.tryParse(_meatDays.text) ?? 0,
      'withdrawalMilkDays': int.tryParse(_milkDays.text) ?? 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouveau produit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppTokens.danger)),
              const SizedBox(height: AppTokens.space2),
            ],
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            const SizedBox(height: AppTokens.space3),
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
              controller: _dose,
              decoration: const InputDecoration(labelText: 'Dose'),
            ),
            const SizedBox(height: AppTokens.space3),
            TextField(
              controller: _meatDays,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Délai viande (jours)',
              ),
            ),
            const SizedBox(height: AppTokens.space3),
            TextField(
              controller: _milkDays,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Délai lait (jours)',
              ),
            ),
          ],
        ),
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
