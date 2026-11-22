import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/sales/sales_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'sales_shared.dart';

class PaymentsPage extends ConsumerStatefulWidget {
  const PaymentsPage({super.key});

  @override
  ConsumerState<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends ConsumerState<PaymentsPage> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _paidAt = TextEditingController(text: todayDate());

  List<Sale> _sales = const [];
  List<Payment> _payments = const [];
  String _method = 'CASH';
  String? _saleId;
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
    _amount.dispose();
    _reference.dispose();
    _paidAt.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sales = await ref.read(salesRepositoryProvider).sales();
      final saleId = _saleId ?? (sales.isEmpty ? null : sales.first.id);
      final payments = saleId == null
          ? const <Payment>[]
          : await ref.read(salesRepositoryProvider).payments(saleId);
      if (mounted) {
        setState(() {
          _sales = sales;
          _saleId = saleId;
          _payments = payments;
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

  Future<void> _select(String? saleId) async {
    setState(() => _saleId = saleId);
    await _load();
  }

  Future<void> _submit() async {
    final saleId = _saleId;
    if (saleId == null) {
      setState(() => _error = 'Sélectionnez une vente.');
      return;
    }
    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Montant invalide.');
      return;
    }
    final paidAt = dateToInstant(_paidAt.text);
    if (paidAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(salesRepositoryProvider).addPayment(saleId, {
        'amount': amount,
        'method': _method,
        'paidAt': paidAt,
        if (_reference.text.trim().isNotEmpty)
          'reference': _reference.text.trim(),
      });
      _amount.clear();
      _reference.clear();
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement enregistré')),
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
      appBar: AppBar(title: const Text('Paiements')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouveau paiement',
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
                          initialValue: _saleId,
                          decoration: const InputDecoration(
                            labelText: 'Vente',
                          ),
                          items: [
                            for (final sale in _sales)
                              DropdownMenuItem(
                                value: sale.id,
                                child: Text(
                                  '${sale.number} · ${formatAmount(sale.totalAmount, sale.currency)}',
                                ),
                              ),
                          ],
                          onChanged: _select,
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
                        DropdownButtonFormField<String>(
                          initialValue: _method,
                          decoration: const InputDecoration(
                            labelText: 'Méthode',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'CASH', child: Text('Espèces')),
                            DropdownMenuItem(
                              value: 'MOBILE_MONEY',
                              child: Text('Mobile money'),
                            ),
                            DropdownMenuItem(
                              value: 'BANK_TRANSFER',
                              child: Text('Virement'),
                            ),
                            DropdownMenuItem(value: 'CARD', child: Text('Carte')),
                            DropdownMenuItem(value: 'CREDIT', child: Text('Crédit')),
                          ],
                          onChanged: (value) =>
                              setState(() => _method = value ?? _method),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _reference,
                          decoration: const InputDecoration(
                            labelText: 'Référence',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _paidAt,
                          decoration: const InputDecoration(
                            labelText: 'Date de paiement',
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
              title: 'Paiements enregistrés',
              child: _payments.isEmpty
                  ? const EmptyState(
                      message: 'Aucun paiement',
                      icon: Icons.payments_outlined,
                    )
                  : Column(
                      children: [
                        for (final payment in _payments)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.payments_outlined),
                            ),
                            title: Text(formatAmount(payment.amount)),
                            subtitle: Text(
                              '${payment.method} · ${formatTimestamp(payment.paidAt)}',
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
