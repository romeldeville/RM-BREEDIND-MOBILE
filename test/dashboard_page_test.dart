import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/alerts/alerts_repository.dart';
import 'package:rm_breeding_mobile/core/dashboard/dashboard_repository.dart';
import 'package:rm_breeding_mobile/features/dashboard/dashboard_page.dart';
import 'package:rm_breeding_mobile/features/dashboard/widgets/trend_bar_chart.dart';

class FakeDashboardRepository extends DashboardRepository {
  FakeDashboardRepository({this.summary = sampleSummary}) : super(Dio());

  static const sampleSummary = DashboardSummary(
    herdSize: 128,
    openAlerts: 12,
    birthsThisMonth: 3,
    averageDailyGain: 0.72,
    grossMargin: 1200000,
    criticalAlerts: [
      Alert(
        id: 'alert-1',
        farmId: 'farm-1',
        type: 'FARROWING_DUE',
        priority: 'CRITICAL',
        title: 'Mise bas prévue — Truie 04',
        message: 'Portée attendue cette semaine',
        dueDate: '2026-11-15',
        status: 'OPEN',
      ),
    ],
  );

  static const sampleSeries = [
    IndicatorPoint(label: 'juin', value: 1),
    IndicatorPoint(label: 'juil.', value: 2),
    IndicatorPoint(label: 'août', value: 3),
    IndicatorPoint(label: 'sept.', value: 4),
    IndicatorPoint(label: 'oct.', value: 5),
    IndicatorPoint(label: 'nov.', value: 6),
  ];

  final DashboardSummary summary;

  @override
  Future<DashboardSummary> dashboard() async => summary;

  @override
  Future<List<IndicatorPoint>> indicatorSeries(String code, {int months = 6}) async {
    return sampleSeries;
  }
}

Widget _wrap(Widget child, {DashboardSummary? summary}) {
  return ProviderScope(
    overrides: [
      dashboardRepositoryProvider.overrideWithValue(
        FakeDashboardRepository(summary: summary ?? FakeDashboardRepository.sampleSummary),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('DashboardPage renders live KPIs, alerts and trend chart', (tester) async {
    await tester.pumpWidget(_wrap(const DashboardPage()));
    await tester.pumpAndSettle();

    expect(find.text('Effectif'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('Naissances (mois)'), findsOneWidget);
    expect(find.text('GMQ moyen'), findsOneWidget);
    expect(find.text('0.72'), findsOneWidget);
    expect(find.text('Marge brute'), findsOneWidget);
    expect(find.text('1200000'), findsOneWidget);
    expect(find.text('Alertes ouvertes'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    expect(find.text('Alertes critiques'), findsOneWidget);
    expect(find.text('Mise bas prévue — Truie 04'), findsOneWidget);

    expect(find.text('Naissances (6 mois)'), findsOneWidget);
    expect(find.text('juin'), findsOneWidget);
    expect(find.text('nov.'), findsOneWidget);
    expect(find.byKey(const ValueKey('trend-bar-5')), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Actions rapides'), 300);
    expect(find.text('Actions rapides'), findsOneWidget);
    expect(find.text('Animal'), findsOneWidget);
    expect(find.text('Lot'), findsOneWidget);
    expect(find.text('Vente'), findsOneWidget);
    expect(find.text('Pesée'), findsOneWidget);
  });

  testWidgets('DashboardPage marks missing data as unavailable', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const DashboardPage(),
        summary: const DashboardSummary(
          herdSize: 0,
          openAlerts: 0,
          birthsThisMonth: 0,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Indisponible'), findsNWidgets(2));
    expect(find.text('Aucune alerte critique'), findsOneWidget);
  });

  testWidgets('TrendBarChart renders one bar per point', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrendBarChart(
            points: const [
              IndicatorPoint(label: 'oct.', value: 2),
              IndicatorPoint(label: 'nov.', value: null),
            ],
            unit: 'naissances',
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('trend-bar-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('trend-bar-1')), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('naissances'), findsOneWidget);
  });
}
