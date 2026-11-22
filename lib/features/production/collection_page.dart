import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/production/production_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'production_shared.dart';

class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({super.key});

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  final _collected = TextEditingController();
  final _broken = TextEditingController(text: '0');
  final _downgraded = TextEditingController(text: '0');
  final _collectedAt = TextEditingController(text: todayDate());

  List<Lot> _lots = const [];
  List<EggCollection> _collections = const [];
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
    _collected.dispose();
    _broken.dispose();
    _downgraded.dispose();
    _collectedAt.dispose();
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
      final collections = await repository.collections();
      if (!mounted) {
        return;
      }
      setState(() {
        _lots = lots;
        _collections = collections;
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
    final collected = int.tryParse(_collected.text.trim());
    if (collected == null || collected < 0) {
      setState(() => _error = 'Nombre d’œufs invalide.');
      return;
    }
    final collectedAt = dateToInstant(_collectedAt.text);
    if (collectedAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(productionRepositoryProvider).createCollection({
        'lotId': _lotId,
        'collectedAt': collectedAt,
        'collected': collected,
        'broken': int.tryParse(_broken.text.trim()) ?? 0,
        'downgraded': int.tryParse(_downgraded.text.trim()) ?? 0,
      });
      _collected.clear();
      _broken.text = '0';
      _downgraded.text = '0';
      final collections = await ref
          .read(productionRepositoryProvider)
          .collections();
      if (mounted) {
        setState(() => _collections = collections);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ramassage enregistré')),
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
      appBar: AppBar(title: const Text('Ramassage d’œufs')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouveau ramassage',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
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
                              DropdownMenuItem(
                                value: lot.id,
                                child: Text(lot.name),
                              ),
                          ],
                          onChanged: (value) => setState(() => _lotId = value),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _collected,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Œufs collectés',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _broken,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cassés',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _downgraded,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Écartés',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _collectedAt,
                          decoration: const InputDecoration(
                            labelText: 'Date de ramassage',
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
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Ramassages récents',
              child: _collections.isEmpty
                  ? const EmptyState(
                      message: 'Aucun ramassage',
                      icon: Icons.egg_outlined,
                    )
                  : Column(
                      children: [
                        for (final collection in _collections)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.egg_outlined),
                            ),
                            title: Text(
                              '${collection.collected} collectés, ${collection.sellable} vendables',
                            ),
                            subtitle: Text(
                              formatTimestamp(collection.collectedAt),
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
