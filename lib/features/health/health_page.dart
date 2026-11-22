import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/health/health_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';
import 'health_shared.dart';

class HealthPage extends ConsumerStatefulWidget {
  const HealthPage({super.key});

  @override
  ConsumerState<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends ConsumerState<HealthPage> {
  List<Withdrawal> _withdrawals = const [];
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
      final withdrawals = await ref
          .read(healthRepositoryProvider)
          .withdrawals();
      if (mounted) {
        setState(() => _withdrawals = withdrawals);
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
            'Produits, vaccinations, traitements, délais d’attente, mortalité et quarantaine.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          Wrap(
            spacing: AppTokens.space2,
            runSpacing: AppTokens.space2,
            children: [
              FilledButton.icon(
                onPressed: () => _open('/health/products'),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Produits'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/health/vaccinations'),
                icon: const Icon(Icons.vaccines_outlined),
                label: const Text('Vaccination'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/health/treatments'),
                icon: const Icon(Icons.medication_outlined),
                label: const Text('Traitement'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/health/withdrawals'),
                icon: const Icon(Icons.hourglass_bottom_outlined),
                label: const Text('Délais d’attente'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/health/mortalities'),
                icon: const Icon(Icons.warning_amber_outlined),
                label: const Text('Mortalité'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('/health/quarantines'),
                icon: const Icon(Icons.coronavirus_outlined),
                label: const Text('Quarantaine'),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          SectionCard(
            title: 'Délais d’attente actifs',
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
                    message: 'Aucun délai d’attente actif',
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
                            'Fin: ${withdrawal.endDate} - ${withdrawal.animalId != null ? 'animal ${shortId(withdrawal.animalId!)}' : 'lot ${shortId(withdrawal.lotId ?? '')}'}',
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
