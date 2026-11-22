import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/finance/finance_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'finance_shared.dart';

class RevenuePage extends ConsumerStatefulWidget {
  const RevenuePage({super.key});

  @override
  ConsumerState<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends ConsumerState<RevenuePage> {
  final _category = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _receivedAt = TextEditingController(text: todayDate());

  List<Revenue> _revenues = const [];
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
    _category.dispose();
    _amount.dispose();
    _description.dispose();
    _receivedAt.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final revenues = await ref.read(financeRepositoryProvider).revenues();
      if (mounted) {
        setState(() => _revenues = revenues);
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

  Future<void> _submit() async {
    final category = _category.text.trim();
    if (category.isEmpty) {
      setState(() => _error = 'La catégorie est obligatoire.');
      return;
    }
    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Montant invalide.');
      return;
    }
    final receivedAt = normalizeDate(_receivedAt.text);
    if (receivedAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(financeRepositoryProvider).createRevenue({
        'category': category,
        'amount': amount,
        'currency': 'XOF',
        'receivedAt': receivedAt,
        if (_description.text.trim().isNotEmpty)
          'description': _description.text.trim(),
      });
      _category.clear();
      _amount.clear();
      _description.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revenu enregistré')),
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
      appBar: AppBar(title: const Text('Revenus')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouveau revenu',
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
                        TextField(
                          controller: _category,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _amount,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Montant',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _description,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _receivedAt,
                          decoration: const InputDecoration(labelText: 'Date'),
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
              title: 'Revenus',
              child: _revenues.isEmpty
                  ? const EmptyState(
                      message: 'Aucun revenu',
                      icon: Icons.trending_up_outlined,
                    )
                  : Column(
                      children: [
                        for (final revenue in _revenues)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.trending_up_outlined),
                            ),
                            title: Text(
                              '${revenue.category} · ${formatAmount(revenue.amount, revenue.currency)}',
                            ),
                            subtitle: Text(revenue.receivedAt),
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
