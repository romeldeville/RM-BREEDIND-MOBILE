import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/feeding/feeding_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'feeding_shared.dart';

class ReceiptPage extends ConsumerStatefulWidget {
  const ReceiptPage({super.key});

  @override
  ConsumerState<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends ConsumerState<ReceiptPage> {
  final _quantity = TextEditingController();
  final _unitPrice = TextEditingController();
  final _receivedAt = TextEditingController(text: todayDate());
  final _supplier = TextEditingController();
  final _expiryDate = TextEditingController();

  List<Feed> _feeds = const [];
  List<FeedReceipt> _receipts = const [];
  String? _feedId;
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
    _unitPrice.dispose();
    _receivedAt.dispose();
    _supplier.dispose();
    _expiryDate.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final feeds = await ref.read(feedingRepositoryProvider).feeds();
      if (!mounted) {
        return;
      }
      setState(() {
        _feeds = feeds;
        _feedId ??= feeds.isEmpty ? null : feeds.first.id;
      });
      if (_feedId != null) {
        await _loadReceipts(_feedId!);
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

  Future<void> _loadReceipts(String feedId) async {
    final receipts = await ref
        .read(feedingRepositoryProvider)
        .receipts(feedId);
    if (mounted) {
      setState(() => _receipts = receipts);
    }
  }

  Future<void> _selectFeed(String? feedId) async {
    if (feedId == null) {
      return;
    }
    setState(() => _feedId = feedId);
    await _loadReceipts(feedId);
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
    final receivedAt = dateToInstant(_receivedAt.text);
    if (receivedAt == null) {
      setState(() => _error = 'Date invalide.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(feedingRepositoryProvider).receiveFeed(feedId, {
        'quantity': quantity,
        'unitPrice': double.tryParse(_unitPrice.text.replaceAll(',', '.')),
        'receivedAt': receivedAt,
        'supplier': _supplier.text.trim().isEmpty ? null : _supplier.text.trim(),
        'expiryDate': normalizeDate(_expiryDate.text),
      });
      _quantity.clear();
      _unitPrice.clear();
      _expiryDate.clear();
      await _loadReceipts(feedId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réception enregistrée')),
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
      appBar: AppBar(title: const Text('Réception d’aliment')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            SectionCard(
              title: 'Nouvelle réception',
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
                          onChanged: _selectFeed,
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
                          controller: _unitPrice,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Prix unitaire',
                          ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        TextField(
                          controller: _receivedAt,
                          decoration: const InputDecoration(
                            labelText: 'Date de réception',
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
                          controller: _expiryDate,
                          decoration: const InputDecoration(
                            labelText: 'Date de péremption',
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
              title: 'Réceptions récentes',
              child: _receipts.isEmpty
                  ? const EmptyState(
                      message: 'Aucune réception',
                      icon: Icons.move_to_inbox_outlined,
                    )
                  : Column(
                      children: [
                        for (final receipt in _receipts)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.move_to_inbox_outlined),
                            ),
                            title: Text(
                              '${formatQuantity(receipt.quantity)} - ${formatTimestamp(receipt.receivedAt)}',
                            ),
                            subtitle: Text(receipt.supplier ?? '-'),
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
