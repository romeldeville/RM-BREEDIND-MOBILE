import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/health/health_repository.dart';
import '../../core/herd/herd_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'health_shared.dart';

class WithdrawalsPage extends ConsumerStatefulWidget {
  const WithdrawalsPage({super.key});

  @override
  ConsumerState<WithdrawalsPage> createState() => _WithdrawalsPageState();
}

class _WithdrawalsPageState extends ConsumerState<WithdrawalsPage> {
  List<Withdrawal> _withdrawals = const [];
  List<Animal> _animals = const [];
  String _filter = 'ACTIVE';
  String? _animalId;
  SaleEligibility? _eligibility;
  bool _loading = true;
  bool _checking = false;
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
      final withdrawals = await ref.read(healthRepositoryProvider).withdrawals(
            status: _filter == 'ALL' ? null : _filter,
          );
      final animals = await loadAnimals(ref);
      if (mounted) {
        setState(() {
          _withdrawals = withdrawals;
          _animals = animals;
          _animalId ??= animals.isEmpty ? null : animals.first.id;
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

  Future<void> _checkEligibility() async {
    if (_animalId == null) {
      return;
    }
    setState(() {
      _checking = true;
      _eligibility = null;
    });
    try {
      final eligibility = await ref
          .read(healthRepositoryProvider)
          .saleEligibility(animalId: _animalId);
      if (mounted) {
        setState(() => _eligibility = eligibility);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Délais d’attente')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            Wrap(
              spacing: AppTokens.space2,
              children: [
                ChoiceChip(
                  label: const Text('Actifs'),
                  selected: _filter == 'ACTIVE',
                  onSelected: (_) {
                    setState(() => _filter = 'ACTIVE');
                    _load();
                  },
                ),
                ChoiceChip(
                  label: const Text('Tous'),
                  selected: _filter == 'ALL',
                  onSelected: (_) {
                    setState(() => _filter = 'ALL');
                    _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Délais d’attente',
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
                  : _withdrawals.isEmpty
                  ? const EmptyState(
                      message: 'Aucun délai d’attente',
                      icon: Icons.hourglass_empty_outlined,
                    )
                  : Column(
                      children: [
                        for (final withdrawal in _withdrawals)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.hourglass_bottom_outlined),
                            ),
                            title: Text(withdrawal.type),
                            subtitle: Text(
                              'Du ${withdrawal.startDate} au ${withdrawal.endDate} - ${withdrawal.status}',
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Vérification vente',
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _animalId,
                    decoration: const InputDecoration(labelText: 'Animal'),
                    items: [
                      for (final animal in _animals)
                        DropdownMenuItem(
                          value: animal.id,
                          child: Text(animalLabel(animal)),
                        ),
                    ],
                    onChanged: (value) => setState(() => _animalId = value),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  FilledButton(
                    onPressed: _checking ? null : _checkEligibility,
                    child: Text(_checking ? 'Vérification...' : 'Vérifier'),
                  ),
                  if (_eligibility != null) ...[
                    const SizedBox(height: AppTokens.space3),
                    Row(
                      children: [
                        Icon(
                          _eligibility!.allowed
                              ? Icons.check_circle_outline
                              : Icons.block_outlined,
                          color: _eligibility!.allowed
                              ? AppTokens.success
                              : AppTokens.danger,
                        ),
                        const SizedBox(width: AppTokens.space2),
                        Text(
                          _eligibility!.allowed
                              ? 'Vente autorisée'
                              : 'Vente bloquée (${_eligibility!.blockingWithdrawals.length} délai(s))',
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
