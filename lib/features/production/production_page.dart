import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/production/production_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'production_shared.dart';

class ProductionPage extends ConsumerStatefulWidget {
  const ProductionPage({super.key});

  @override
  ConsumerState<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends ConsumerState<ProductionPage> {
  List<EggStock> _stocks = const [];
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
      final stocks = await ref.read(productionRepositoryProvider).eggStocks();
      if (mounted) {
        setState(() => _stocks = stocks);
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
            'Pesées, croissance, ramassages et stock d’œufs.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [
              FilledButton.icon(
                onPressed: () => _open('/production/weighings'),
                icon: const Icon(Icons.monitor_weight_outlined),
                label: const Text('Pesées'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/production/growth'),
                icon: const Icon(Icons.show_chart_outlined),
                label: const Text('Croissance'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/production/collections'),
                icon: const Icon(Icons.egg_outlined),
                label: const Text('Ramassage'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/production/egg-stocks'),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Stock d’œufs'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Stock d’œufs',
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
                : _stocks.isEmpty
                ? const EmptyState(
                    message: 'Aucun stock d’œufs',
                    icon: Icons.inventory_2_outlined,
                  )
                : Column(
                    children: [
                      for (final stock in _stocks)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppTokens.background,
                            child: Icon(Icons.egg_outlined),
                          ),
                          title: Text(
                            stock.lotId == null
                                ? 'Ferme'
                                : 'Lot ${shortId(stock.lotId!)}',
                          ),
                          subtitle: Text(
                            formatTimestamp(stock.updatedAt),
                          ),
                          trailing: Text('${stock.quantity} œufs'),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
