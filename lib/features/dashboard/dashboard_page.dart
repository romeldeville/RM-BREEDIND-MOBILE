import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/alerts/alerts_repository.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/dashboard/dashboard_repository.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../shared/widgets/section_card.dart';
import 'widgets/trend_bar_chart.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  DashboardSummary? _summary;
  List<IndicatorPoint> _births = const [];
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
    final repository = ref.read(dashboardRepositoryProvider);
    try {
      final results = await Future.wait<Object>([
        repository.dashboard(),
        repository.indicatorSeries('BIRTHS_PERIOD'),
      ]);
      if (mounted) {
        setState(() {
          _summary = results[0] as DashboardSummary;
          _births = results[1] as List<IndicatorPoint>;
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          const Text(
            'Vue du jour de votre exploitation.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space4),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(AppTokens.space8),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SectionCard(
              title: 'Tableau de bord',
              child: Column(
                children: [
                  Text(_error!, style: const TextStyle(color: AppTokens.danger)),
                  const SizedBox(height: AppTokens.space2),
                  OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
                ],
              ),
            )
          else if (_summary != null) ...[
            _kpis(_summary!),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Alertes critiques',
              trailing: TextButton(
                onPressed: () => context.push('/alerts'),
                child: const Text('Voir tout'),
              ),
              child: _summary!.criticalAlerts.isEmpty
                  ? const EmptyState(
                      message: 'Aucune alerte critique',
                      icon: Icons.notifications_off_outlined,
                    )
                  : Column(
                      children: [
                        for (final alert
                            in _summary!.criticalAlerts.take(3))
                          _alertTile(alert),
                      ],
                    ),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Naissances (6 mois)',
              trailing: TextButton(
                onPressed: () => context.push('/reports'),
                child: const Text('Détails'),
              ),
              child: TrendBarChart(points: _births, unit: 'naissances / mois'),
            ),
            const SizedBox(height: AppTokens.space4),
            SectionCard(
              title: 'Actions rapides',
              child: Wrap(
                spacing: AppTokens.space2,
                runSpacing: AppTokens.space2,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.push('/herd/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Animal'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/lots/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Lot'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/sales/new'),
                    icon: const Icon(Icons.point_of_sale_outlined),
                    label: const Text('Vente'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/production/weighings'),
                    icon: const Icon(Icons.scale_outlined),
                    label: const Text('Pesée'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _kpis(DashboardSummary summary) {
    final tiles = <Widget>[
      KpiCard(
        label: 'Effectif',
        value: '${summary.herdSize}',
        icon: Icons.pets_outlined,
      ),
      KpiCard(
        label: 'Naissances (mois)',
        value: '${summary.birthsThisMonth}',
        icon: Icons.child_care_outlined,
      ),
      KpiCard(
        label: 'GMQ moyen',
        value: _decimal(summary.averageDailyGain),
        unit: 'kg/j',
        icon: Icons.trending_up,
      ),
      KpiCard(
        label: 'Marge brute',
        value: _decimal(summary.grossMargin),
        icon: Icons.savings_outlined,
      ),
      KpiCard(
        label: 'Alertes ouvertes',
        value: '${summary.openAlerts}',
        icon: Icons.notifications_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 960
            ? 5
            : constraints.maxWidth >= 600
                ? 3
                : 2;
        final spacing = AppTokens.space3;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final tile in tiles) SizedBox(width: itemWidth, child: tile),
          ],
        );
      },
    );
  }

  Widget _alertTile(Alert alert) {
    final priority = alert.priority;
    final color = switch (priority) {
      'CRITICAL' => AppTokens.danger,
      'IMPORTANT' => AppTokens.warning,
      _ => AppTokens.info,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(Icons.priority_high, color: color, size: 18),
      ),
      title: Text(alert.title),
      subtitle: Text(
        alert.dueDate ?? 'Sans échéance',
        style: const TextStyle(color: AppTokens.textMuted),
      ),
    );
  }

  String _decimal(double? value) {
    if (value == null) {
      return 'Indisponible';
    }
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}
