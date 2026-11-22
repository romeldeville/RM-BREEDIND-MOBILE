import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/finance/finance_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'finance_shared.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  List<Expense> _expenses = const [];
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
      final expenses = await ref.read(financeRepositoryProvider).expenses();
      if (mounted) {
        setState(() => _expenses = expenses);
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
            'Dépenses, revenus, coûts et marges.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [
              FilledButton.icon(
                onPressed: () => _open('/finance/expenses'),
                icon: const Icon(Icons.trending_down_outlined),
                label: const Text('Dépenses'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/finance/revenues'),
                icon: const Icon(Icons.trending_up_outlined),
                label: const Text('Revenus'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/finance/costs'),
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Coûts & marges'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Dépenses récentes',
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
                : _expenses.isEmpty
                ? const EmptyState(
                    message: 'Aucune dépense',
                    icon: Icons.trending_down_outlined,
                  )
                : Column(
                    children: [
                      for (final expense in _expenses.take(10))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppTokens.background,
                            child: Icon(Icons.trending_down_outlined),
                          ),
                          title: Text(
                            '${expense.category} · ${formatAmount(expense.amount, expense.currency)}',
                          ),
                          subtitle: Text(expense.incurredAt),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
