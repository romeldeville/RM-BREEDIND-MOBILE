import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/sync/sync_controller.dart';
import 'package:rm_breeding_mobile/features/sync/sync_banner.dart';

class _FixedSyncController extends SyncController {
  _FixedSyncController(super.ref, SyncUiState initial) {
    state = initial;
  }

  @override
  Future<void> refresh() async {
    // The banner test pins a deterministic state; no database read.
  }
}

Future<void> _pumpBanner(WidgetTester tester, SyncUiState state) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        syncControllerProvider.overrideWith(
          (ref) => _FixedSyncController(ref, state),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(body: SyncBanner()),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the offline hint when the device has no network',
      (tester) async {
    await _pumpBanner(tester, const SyncUiState(online: false));

    expect(
      find.text('Hors ligne — les saisies restent sur l’appareil.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the number of local writes waiting for upload',
      (tester) async {
    await _pumpBanner(tester, const SyncUiState(pending: 2));

    expect(
      find.text('2 modification(s) en attente d’envoi.'),
      findsOneWidget,
    );
  });

  testWidgets('makes unresolved conflicts actionable', (tester) async {
    await _pumpBanner(tester, const SyncUiState(conflicts: 1));

    expect(
      find.text('1 conflit(s) de synchronisation à résoudre.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('stays hidden when everything is synchronized', (tester) async {
    await _pumpBanner(tester, const SyncUiState());

    expect(find.byType(SyncBanner), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_outlined), findsNothing);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsNothing);
  });
}
