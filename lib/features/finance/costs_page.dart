import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/finance/finance_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'finance_shared.dart';

class CostsPage extends ConsumerStatefulWidget {
  const CostsPage({super.key});

  @override
  ConsumerState<CostsPage> createState() => _CostsPageState();
}

class _CostsPageState extends ConsumerState<CostsPage> {
  List<Lot> _lots = const [];
  LotCost? _cost;
  LotMargin? _margin;
  String? _lotId;
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
      final lots = await loadLots(ref);
      final lotId = _lotId ?? (lots.isEmpty ? null : lots.first.id);
      LotCost? cost;
      LotMargin? margin;
      if (lotId != null) {
        final repository = ref.read(financeRepositoryProvider);
        cost = await repository.lotCost(lotId);
        margin = await repository.lotMargin(lotId);
      }
      if (mounted) {
        setState(() {
          _lots = lots;
          _lotId = lotId;
          _cost = cost;
          _margin = margin;
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

  Future<void> _select(String? lotId) async {
    setState(() => _lotId = lotId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coûts & marges')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Lot',
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      initialValue: _lotId,
                      decoration: const InputDecoration(labelText: 'Lot'),
                      items: [
                        for (final lot in _lots)
                          DropdownMenuItem(value: lot.id, child: Text(lot.name)),
                      ],
                      onChanged: _select,
                    ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppTokens.space4),
              Text(
                _error!,
                style: const TextStyle(color: AppTokens.danger),
              ),
            ],
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Coût du lot',
              child: _cost == null
                  ? const EmptyState(
                      message: 'Aucune donnée de coût',
                      icon: Icons.calculate_outlined,
                    )
                  : Column(
                      children: [
                        _row('Coût aliment', _cost!.feedCost),
                        _row('Coûts alloués', _cost!.allocatedCost),
                        const Divider(),
                        _row('Coût total', _cost!.totalCost, bold: true),
                      ],
                    ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Marge du lot',
              child: _margin == null
                  ? const EmptyState(
                      message: 'Aucune donnée de marge',
                      icon: Icons.insights_outlined,
                    )
                  : Column(
                      children: [
                        _row('Revenus', _margin!.revenue),
                        _row('Coûts', _margin!.cost),
                        const Divider(),
                        _row('Marge', _margin!.margin, bold: true),
                        if (_margin!.marginRate != null)
                          _row(
                            'Taux de marge',
                            _margin!.marginRate!,
                            suffix: '%',
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false, String? suffix}) {
    final text = '${formatAmount(value)}${
      suffix ?? ''
    }';
    final style = bold ? const TextStyle(fontWeight: FontWeight.w600) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(text, style: style),
        ],
      ),
    );
  }
}
