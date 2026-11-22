import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/feeding/feeding_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'feeding_shared.dart';

class FeedingPage extends ConsumerStatefulWidget {
  const FeedingPage({super.key});

  @override
  ConsumerState<FeedingPage> createState() => _FeedingPageState();
}

class _FeedingPageState extends ConsumerState<FeedingPage> {
  List<LowStockAlert> _alerts = const [];
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
      final alerts = await ref.read(feedingRepositoryProvider).lowStock();
      if (mounted) {
        setState(() => _alerts = alerts);
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

  Future<void> _open(String path) async {
    await context.push(path);
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const Text(
            'Aliments, réceptions, distributions, stocks et plans d’alimentation.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [
              FilledButton.icon(
                onPressed: () => _open('/feeding/feeds'),
                icon: const Icon(Icons.grass_outlined),
                label: const Text('Aliments'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/feeding/receipts'),
                icon: const Icon(Icons.move_to_inbox_outlined),
                label: const Text('Réception'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/feeding/distributions'),
                icon: const Icon(Icons.restaurant_outlined),
                label: const Text('Distribution'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/feeding/stocks'),
                icon: const Icon(Icons.warehouse_outlined),
                label: const Text('Stocks'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/feeding/plans'),
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Plans'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Stocks bas',
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
                : _alerts.isEmpty
                ? const EmptyState(
                    message: 'Aucun stock sous le seuil',
                    icon: Icons.warehouse_outlined,
                  )
                : Column(
                    children: [
                      for (final alert in _alerts)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppTokens.background,
                            child: Icon(Icons.warning_amber_outlined),
                          ),
                          title: Text(alert.feedName ?? shortId(alert.feedId)),
                          subtitle: Text(
                            'Stock ${formatQuantity(alert.quantity)} ${alert.unit ?? ''} < seuil ${formatQuantity(alert.threshold)}',
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
