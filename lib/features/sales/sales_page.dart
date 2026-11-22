import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/sales/sales_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'sales_shared.dart';

class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  List<Sale> _sales = const [];
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
      final sales = await ref.read(salesRepositoryProvider).sales();
      if (mounted) {
        setState(() => _sales = sales);
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
            'Ventes, clients et encaissements.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [
              FilledButton.icon(
                onPressed: () => _open('/sales/new'),
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Nouvelle vente'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/sales/payments'),
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Paiements'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/sales/clients'),
                icon: const Icon(Icons.people_outline),
                label: const Text('Clients'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Ventes récentes',
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
                : _sales.isEmpty
                ? const EmptyState(
                    message: 'Aucune vente',
                    icon: Icons.point_of_sale_outlined,
                  )
                : Column(
                    children: [
                      for (final sale in _sales)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppTokens.background,
                            child: Icon(Icons.receipt_long_outlined),
                          ),
                          title: Text(
                            '${sale.number} · ${formatAmount(sale.totalAmount, sale.currency)}',
                          ),
                          subtitle: Text(
                            '${saleStatusLabel(sale.status)} · ${paymentStatusLabel(sale.paymentStatus)} · ${formatTimestamp(sale.soldAt)}',
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
