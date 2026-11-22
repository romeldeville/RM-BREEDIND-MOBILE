import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/dashboard/dashboard_repository.dart';
import 'package:rm_breeding_mobile/features/reports/reports_page.dart';

class FakeReportsRepository extends DashboardRepository {
  FakeReportsRepository({this.indicatorsList = sampleIndicators}) : super(Dio());

  static const sampleIndicators = [
    IndicatorValue(
      code: 'HERD_SIZE',
      label: 'Effectif total',
      unit: 'tête',
      value: 42,
      periodStart: '2026-11-01',
      periodEnd: '2026-11-30',
    ),
    IndicatorValue(
      code: 'PREGNANCY_RATE',
      label: 'Taux de gestation',
      unit: '%',
      periodStart: '2026-11-01',
      periodEnd: '2026-11-30',
    ),
    IndicatorValue(
      code: 'NET_MARGIN',
      label: 'Marge nette',
      unit: 'XOF',
      value: 3000.5,
      periodStart: '2026-11-01',
      periodEnd: '2026-11-30',
    ),
  ];

  final List<IndicatorValue> indicatorsList;

  @override
  Future<List<IndicatorValue>> indicators({String? from, String? to}) async {
    return indicatorsList;
  }
}

Widget _wrap(Widget child, {List<IndicatorValue>? indicatorsList}) {
  return ProviderScope(
    overrides: [
      dashboardRepositoryProvider.overrideWithValue(
        FakeReportsRepository(
          indicatorsList: indicatorsList ?? FakeReportsRepository.sampleIndicators,
        ),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('ReportsPage lists indicators and unavailable values', (tester) async {
    await tester.pumpWidget(_wrap(const ReportsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Période'), findsOneWidget);
    expect(find.text('Appliquer'), findsOneWidget);
    expect(find.text('Effectif total'), findsOneWidget);
    expect(find.text('HERD_SIZE'), findsOneWidget);
    expect(find.text('42 tête'), findsOneWidget);
    expect(find.text('Taux de gestation'), findsOneWidget);
    expect(find.text('Indisponible'), findsOneWidget);
    expect(find.text('Marge nette'), findsOneWidget);
    expect(find.text('3000.50 XOF'), findsOneWidget);
  });

  testWidgets('ReportsPage shows an empty state without indicators', (tester) async {
    await tester.pumpWidget(_wrap(const ReportsPage(), indicatorsList: const []));
    await tester.pumpAndSettle();

    expect(find.text('Aucun indicateur'), findsOneWidget);
  });
}
