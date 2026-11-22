import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/feeding/feeding_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class FeedsPage extends ConsumerStatefulWidget {
  const FeedsPage({super.key});

  @override
  ConsumerState<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends ConsumerState<FeedsPage> {
  List<Feed> _feeds = const [];
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
      final feeds = await ref.read(feedingRepositoryProvider).feeds();
      if (mounted) {
        setState(() => _feeds = feeds);
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
      builder: (context) => const _FeedDialog(),
    );
    if (input == null) {
      return;
    }
    try {
      await ref.read(feedingRepositoryProvider).createFeed(input);
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
      appBar: AppBar(title: const Text('Aliments')),
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
              title: 'Catalogue',
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
                  : _feeds.isEmpty
                  ? const EmptyState(
                      message: 'Aucun aliment',
                      icon: Icons.grass_outlined,
                    )
                  : Column(
                      children: [
                        for (final feed in _feeds)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.grass_outlined),
                            ),
                            title: Text(feed.name),
                            subtitle: Text(
                              '${feed.type ?? '-'} - ${feed.unit}${feed.supplier != null ? ' - ${feed.supplier}' : ''}',
                            ),
                            trailing: Text(
                              feed.price == null ? '-' : '${feed.price}',
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

class _FeedDialog extends StatefulWidget {
  const _FeedDialog();

  @override
  State<_FeedDialog> createState() => _FeedDialogState();
}

class _FeedDialogState extends State<_FeedDialog> {
  static const _types = ['CONCENTRATE', 'FORAGE', 'MINERAL', 'ADDITIVE', 'OTHER'];

  final _name = TextEditingController();
  final _unit = TextEditingController(text: 'kg');
  final _price = TextEditingController();
  final _supplier = TextEditingController();
  String _type = 'CONCENTRATE';
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _price.dispose();
    _supplier.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Le nom est obligatoire.');
      return;
    }
    if (_unit.text.trim().isEmpty) {
      setState(() => _error = 'L’unité est obligatoire.');
      return;
    }
    Navigator.pop(context, {
      'name': _name.text.trim(),
      'type': _type,
      'unit': _unit.text.trim(),
      'price': double.tryParse(_price.text.replaceAll(',', '.')),
      'supplier': _supplier.text.trim().isEmpty ? null : _supplier.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvel aliment'),
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
              controller: _unit,
              decoration: const InputDecoration(labelText: 'Unité'),
            ),
            const SizedBox(height: AppTokens.space3),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Prix unitaire'),
            ),
            const SizedBox(height: AppTokens.space3),
            TextField(
              controller: _supplier,
              decoration: const InputDecoration(labelText: 'Fournisseur'),
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
