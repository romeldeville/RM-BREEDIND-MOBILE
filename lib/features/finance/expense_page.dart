import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/finance/finance_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'finance_shared.dart';

class ExpensePage extends ConsumerStatefulWidget {
  const ExpensePage({super.key});

  @override
  ConsumerState<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends ConsumerState<ExpensePage> {
  final _category = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _supplier = TextEditingController();
  final _incurredAt = TextEditingController(text: todayDate());

  List<Expense> _expenses = const [];
  List<Lot> _lots = const [];
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
    _category.dispose();
    _amount.dispose();
    _description.dispose();
    _supplier.dispose();
    _incurredAt.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final expenses = await ref.read(financeRepositoryProvider).expenses();
      final lots = await loadLots(ref);
      if (mounted) {
        setState(() {
          _expenses = expenses;
          _lots = lots;
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
    final incurredAt = normalizeDate(_incurredAt.text);
    if (incurredAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(financeRepositoryProvider).createExpense({
        'category': category,
        'amount': amount,
        'currency': 'XOF',
        'incurredAt': incurredAt,
        if (_description.text.trim().isNotEmpty)
          'description': _description.text.trim(),
        if (_supplier.text.trim().isNotEmpty) 'supplier': _supplier.text.trim(),
        if (_lotId != null) 'lotId': _lotId,
      });
      _category.clear();
      _amount.clear();
      _description.clear();
      _supplier.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dépense enregistrée')),
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
      appBar: AppBar(title: const Text('Dépenses')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouvelle dépense',
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
                        DropdownButtonFormField<String?>(
                          initialValue: _lotId,
                          decoration: const InputDecoration(
                            labelText: 'Lot (optionnel)',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('—'),
                            ),
                            for (final lot in _lots)
                              DropdownMenuItem<String?>(
                                value: lot.id,
                                child: Text(lot.name),
                              ),
                          ],
                          onChanged: (value) => setState(() => _lotId = value),
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
                          controller: _supplier,
                          decoration: const InputDecoration(
                            labelText: 'Fournisseur',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _incurredAt,
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
              title: 'Dépenses',
              child: _expenses.isEmpty
                  ? const EmptyState(
                      message: 'Aucune dépense',
                      icon: Icons.trending_down_outlined,
                    )
                  : Column(
                      children: [
                        for (final expense in _expenses)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.trending_down_outlined),
                            ),
                            title: Text(
                              '${expense.category} · ${formatAmount(expense.amount, expense.currency)}',
                            ),
                            subtitle: Text(
                              '${expense.incurredAt}${expense.supplier == null ? '' : ' · ${expense.supplier}'}',
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
