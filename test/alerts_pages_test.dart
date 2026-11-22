import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/alerts/alerts_repository.dart';
import 'package:rm_breeding_mobile/features/alerts/alerts_page.dart';
import 'package:rm_breeding_mobile/features/alerts/tasks_page.dart';
import 'package:rm_breeding_mobile/features/alerts/today_page.dart';

class FakeAlertsRepository extends AlertsRepository {
  FakeAlertsRepository() : super(Dio());

  static const sampleAlert = Alert(
    id: 'alert-1',
    farmId: 'farm-1',
    type: 'FARROWING_DUE',
    priority: 'CRITICAL',
    title: 'Mise bas prévue',
    message: 'Portée attendue cette semaine',
    dueDate: '2026-11-13',
    status: 'OPEN',
  );

  static const sampleTask = Task(
    id: 'task-1',
    farmId: 'farm-1',
    title: 'Nettoyer le bâtiment',
    status: 'OPEN',
    dueDate: '2026-11-13',
  );

  @override
  Future<List<Alert>> alerts({
    String? status,
    String? priority,
    String? dueBefore,
  }) async {
    return const [sampleAlert];
  }

  @override
  Future<TodayBundle> today() async {
    return const TodayBundle(alerts: [sampleAlert], tasks: [sampleTask]);
  }

  @override
  Future<List<Task>> tasks() async {
    return const [sampleTask];
  }
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      alertsRepositoryProvider.overrideWithValue(FakeAlertsRepository()),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _wrapBody(Widget child) {
  return _wrap(Scaffold(body: child));
}

void main() {
  testWidgets('AlertsPage renders filters and alerts', (tester) async {
    await tester.pumpWidget(_wrapBody(const AlertsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Filtres'), findsOneWidget);
    expect(find.text('Statut'), findsOneWidget);
    expect(find.text('Priorité'), findsOneWidget);
    expect(find.text('Alertes'), findsOneWidget);
    expect(find.text('Mise bas prévue'), findsOneWidget);
    expect(find.text('Critique · Ouverte · 2026-11-13'), findsOneWidget);
  });

  testWidgets('TodayPage renders alerts and tasks of the day', (tester) async {
    await tester.pumpWidget(_wrap(const TodayPage()));
    await tester.pumpAndSettle();

    expect(find.text('Alertes du jour'), findsOneWidget);
    expect(find.text('Mise bas prévue'), findsOneWidget);
    expect(find.text('Tâches du jour'), findsOneWidget);
    expect(find.text('Nettoyer le bâtiment'), findsOneWidget);
  });

  testWidgets('TasksPage renders the task form and list', (tester) async {
    await tester.pumpWidget(_wrap(const TasksPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle tâche'), findsOneWidget);
    expect(find.text('Titre'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Tâches enregistrées'), findsOneWidget);
    expect(find.text('Nettoyer le bâtiment'), findsOneWidget);
  });
}
