import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/feeding/feeding_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'feeding_shared.dart';

class StockPage extends ConsumerStatefulWidget {
  const StockPage({super.key});

  @override
  ConsumerState<StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<StockPage> {
  final _threshold = TextEditingController();

  List<FeedStock> _stocks = const [];
  List<LowStockAlert> _alerts = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _threshold.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(feedingRepositoryProvider);
      final stocks = await repository.stocks();
      final alerts = await repository.lowStock(
        threshold: double.tryParse(_threshold.text.replaceAll(',', '.')),
      );
      if (mounted) {
        setState(() {
          _stocks = stocks;
          _alerts = alerts;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stocks d’aliments')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: AppTokens.danger)),
              const SizedBox(height: AppTokens.space2),
            ],
            SectionCard(
              title: 'Seuil de stock bas',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _threshold,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Seuil'),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space3),
                  FilledButton(onPressed: _load, child: const Text('Appliquer')),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Stocks',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _stocks.isEmpty
                  ? const EmptyState(
                      message: 'Aucun stock',
                      icon: Icons.warehouse_outlined,
                    )
                  : Column(
                      children: [
                        for (final stock in _stocks)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.warehouse_outlined),
                            ),
                            title: Text(
                              stock.feedName ?? shortId(stock.feedId),
                            ),
                            subtitle: Text(
                              'Prix moyen ${stock.averagePrice ?? '-'}',
                            ),
                            trailing: Text(
                              '${formatQuantity(stock.quantity)} ${stock.unit ?? ''}',
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Alertes de stock bas',
              child: _alerts.isEmpty
                  ? const EmptyState(
                      message: 'Aucune alerte',
                      icon: Icons.check_circle_outline,
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
                            title: Text(
                              alert.feedName ?? shortId(alert.feedId),
                            ),
                            subtitle: Text(
                              'Stock ${formatQuantity(alert.quantity)} < seuil ${formatQuantity(alert.threshold)}',
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
