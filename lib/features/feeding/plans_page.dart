import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/feeding/feeding_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

class FeedingPlansPage extends ConsumerStatefulWidget {
  const FeedingPlansPage({super.key});

  @override
  ConsumerState<FeedingPlansPage> createState() => _FeedingPlansPageState();
}

class _FeedingPlansPageState extends ConsumerState<FeedingPlansPage> {
  List<FeedingPlan> _plans = const [];
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
      final plans = await ref.read(feedingRepositoryProvider).feedingPlans();
      if (mounted) {
        setState(() => _plans = plans);
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
      appBar: AppBar(title: const Text('Plans d’alimentation')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            const Text(
              'Les plans sont définis par espèce dans le référentiel.',
              style: TextStyle(color: AppTokens.textMuted),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Plans',
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
                  : _plans.isEmpty
                  ? const EmptyState(
                      message: 'Aucun plan d’alimentation',
                      icon: Icons.assignment_outlined,
                    )
                  : Column(
                      children: [
                        for (final plan in _plans)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTokens.background,
                              child: Icon(Icons.assignment_outlined),
                            ),
                            title: Text(plan.name),
                            subtitle: Text(
                              '${plan.stages.length} étape(s) - ${plan.active ? 'Actif' : 'Inactif'}',
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
