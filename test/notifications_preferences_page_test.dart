import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/auth/auth_repository.dart';
import 'package:rm_breeding_mobile/core/notifications/notification_repository.dart';
import 'package:rm_breeding_mobile/features/notifications/notifications_preferences_page.dart';

class _FakeNotificationRepository extends NotificationRepository {
  _FakeNotificationRepository({required this.items}) : super(Dio());

  List<NotificationPreference> items;
  List<NotificationPreference>? saved;

  @override
  Future<List<NotificationPreference>> preferences() async => items;

  @override
  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> items,
  ) async {
    saved = List.of(items);
    this.items = List.of(items);
    return this.items;
  }
}

Widget _wrap(_FakeNotificationRepository repository) {
  return ProviderScope(
    overrides: [
      notificationRepositoryProvider.overrideWithValue(repository),
    ],
    child: const MaterialApp(
      home: Scaffold(body: NotificationPreferencesPage()),
    ),
  );
}

void main() {
  testWidgets('renders the preference matrix with French labels',
      (tester) async {
    final repository = _FakeNotificationRepository(
      items: const [
        NotificationPreference(
          type: 'FARROWING_DUE',
          channel: 'PUSH',
          enabled: true,
        ),
        NotificationPreference(
          type: 'FARROWING_DUE',
          channel: 'EMAIL',
          enabled: false,
        ),
        NotificationPreference(
          type: 'DAILY_DIGEST',
          channel: 'EMAIL',
          enabled: true,
        ),
      ],
    );

    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    expect(find.text('Mise bas'), findsOneWidget);
    expect(find.text('Résumé quotidien'), findsOneWidget);
    expect(find.text('Push'), findsOneWidget);
    expect(find.byKey(const Key('pref-FARROWING_DUE-PUSH')), findsOneWidget);
    expect(find.byKey(const Key('pref-FARROWING_DUE-EMAIL')), findsOneWidget);
    expect(find.byKey(const Key('pref-DAILY_DIGEST-EMAIL')), findsOneWidget);

    final disabled = tester.widget<SwitchListTile>(
      find.byKey(const Key('pref-FARROWING_DUE-EMAIL')),
    );
    expect(disabled.value, isFalse);
  });

  testWidgets('toggles a channel and saves the whole matrix', (tester) async {
    final repository = _FakeNotificationRepository(
      items: const [
        NotificationPreference(
          type: 'FARROWING_DUE',
          channel: 'PUSH',
          enabled: true,
        ),
        NotificationPreference(
          type: 'FARROWING_DUE',
          channel: 'EMAIL',
          enabled: true,
        ),
      ],
    );

    await tester.pumpWidget(_wrap(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('pref-FARROWING_DUE-PUSH')));
    await tester.pumpAndSettle();
    final toggled = tester.widget<SwitchListTile>(
      find.byKey(const Key('pref-FARROWING_DUE-PUSH')),
    );
    expect(toggled.value, isFalse);

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(repository.saved, isNotNull);
    expect(repository.saved, hasLength(2));
    final push = repository.saved!.firstWhere(
      (item) => item.type == 'FARROWING_DUE' && item.channel == 'PUSH',
    );
    expect(push.enabled, isFalse);
    expect(find.text('Préférences enregistrées.'), findsOneWidget);
  });

  testWidgets('shows an error state when loading fails', (tester) async {
    final repository = _FailingNotificationRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: NotificationPreferencesPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Serveur indisponible'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}

class _FailingNotificationRepository extends NotificationRepository {
  _FailingNotificationRepository() : super(Dio());

  @override
  Future<List<NotificationPreference>> preferences() async {
    throw ApiFailure('Serveur indisponible', statusCode: 500);
  }
}
