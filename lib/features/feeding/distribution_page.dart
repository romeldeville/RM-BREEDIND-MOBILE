import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/feeding/feeding_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'feeding_shared.dart';

class DistributionPage extends ConsumerStatefulWidget {
  const DistributionPage({super.key});

  @override
  ConsumerState<DistributionPage> createState() => _DistributionPageState();
}

class _DistributionPageState extends ConsumerState<DistributionPage> {
  final _quantity = TextEditingController();
  final _distributedAt = TextEditingController(text: todayDate());
  final _notes = TextEditingController();

  List<Feed> _feeds = const [];
  List<Lot> _lots = const [];
  List<Animal> _animals = const [];
  List<FeedDistribution> _distributions = const [];
  String? _feedId;
  String _target = 'LOT';
  String? _lotId;
  String? _animalId;
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
    _distributedAt.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(feedingRepositoryProvider);
      final feeds = await repository.feeds();
      final lots = await loadLots(ref);
      final animals = await loadAnimals(ref);
      final distributions = await repository.distributions();
      if (!mounted) {
        return;
      }
      setState(() {
        _feeds = feeds;
        _lots = lots;
        _animals = animals;
        _distributions = distributions;
        _feedId ??= feeds.isEmpty ? null : feeds.first.id;
        _lotId ??= lots.isEmpty ? null : lots.first.id;
        _animalId ??= animals.isEmpty ? null : animals.first.id;
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
    final feedId = _feedId;
    final quantity = double.tryParse(_quantity.text.replaceAll(',', '.'));
    if (feedId == null) {
      setState(() => _error = 'Sélectionnez un aliment.');
      return;
    }
    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Quantité invalide.');
      return;
    }
    final distributedAt = dateToInstant(_distributedAt.text);
    if (distributedAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    if (_target == 'LOT' && _lotId == null) {
      setState(() => _error = 'Sélectionnez un lot.');
      return;
    }
    if (_target == 'ANIMAL' && _animalId == null) {
      setState(() => _error = 'Sélectionnez un animal.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(feedingRepositoryProvider).distribute({
        'feedId': feedId,
        'lotId': _target == 'LOT' ? _lotId : null,
        'animalId': _target == 'ANIMAL' ? _animalId : null,
        'quantity': quantity,
        'distributedAt': distributedAt,
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      });
      _quantity.clear();
      _notes.clear();
      final distributions = await ref
          .read(feedingRepositoryProvider)
          .distributions();
      if (mounted) {
        setState(() => _distributions = distributions);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Distribution enregistrée')),
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
      appBar: AppBar(title: const Text('Distribution d’aliment')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouvelle distribution',
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
                          initialValue: _feedId,
                          decoration: const InputDecoration(labelText: 'Aliment'),
                          items: [
                            for (final feed in _feeds)
                              DropdownMenuItem(
                                value: feed.id,
                                child: Text(feed.name),
                              ),
                          ],
                          onChanged: (value) => setState(() => _feedId = value),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        DropdownButtonFormField<String>(
                          initialValue: _target,
                          decoration: const InputDecoration(labelText: 'Cible'),
                          items: const [
                            DropdownMenuItem(value: 'LOT', child: Text('Lot')),
                            DropdownMenuItem(
                              value: 'ANIMAL',
                              child: Text('Animal'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _target = value ?? _target),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        if (_target == 'LOT')
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
                          ),
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
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _distributedAt,
                          decoration: const InputDecoration(
                            labelText: 'Date de distribution',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _notes,
                          decoration: const InputDecoration(labelText: 'Notes'),
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
              title: 'Distributions récentes',
              child: _distributions.isEmpty
                  ? const EmptyState(
                      message: 'Aucune distribution',
                      icon: Icons.restaurant_outlined,
                    )
                  : Column(
                      children: [
                        for (final distribution in _distributions)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.restaurant_outlined),
                            ),
                            title: Text(
                              '${formatQuantity(distribution.quantity)} - ${formatTimestamp(distribution.distributedAt)}',
                            ),
                            subtitle: Text(
                              distribution.lotId != null
                                  ? 'Lot ${shortId(distribution.lotId!)}'
                                  : 'Animal ${shortId(distribution.animalId ?? '')}',
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
