import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/db/app_database.dart';
import 'package:rm_breeding_mobile/core/sync/sync_api.dart';
import 'package:rm_breeding_mobile/core/sync/sync_models.dart';
import 'package:rm_breeding_mobile/features/sync/conflicts_page.dart';

class ConflictSyncApi extends SyncApi {
  ConflictSyncApi(this.conflict) : super(Dio());

  final SyncConflict conflict;
  String? lastResolution;

  @override
  Future<List<SyncConflict>> conflicts({bool includeResolved = false}) async {
    return [conflict];
  }

  @override
  Future<SyncConflict> resolve(
    String conflictId,
    String resolution, {
    Map<String, dynamic>? payload,
  }) async {
    lastResolution = resolution;
    return SyncConflict(
      id: conflictId,
      entityType: conflict.entityType,
      entityId: conflict.entityId,
      resolution: resolution,
      resolvedAt: DateTime.now().toIso8601String(),
      createdAt: conflict.createdAt,
      reason: conflict.reason,
      payload: conflict.payload,
    );
  }
}

class _EmptySyncApi extends SyncApi {
  _EmptySyncApi() : super(Dio());

  @override
  Future<List<SyncConflict>> conflicts({bool includeResolved = false}) async {
    return const [];
  }
}

const _conflict = SyncConflict(
  id: 'c1f0a3b2-2222-4a3b-9c44-000000000002',
  entityType: 'lot',
  entityId: '8f14e45f-ceea-467f-a9c2-4a3f6b1d9e21',
  reason: 'HEADCOUNT_MISMATCH',
  payload: {'reason': 'HEADCOUNT_MISMATCH', 'expected': 19, 'actual': 18},
);

LocalConflict _localConflict({String? resolution, DateTime? resolvedAt}) {
  return LocalConflict(
    id: _conflict.id,
    entityType: _conflict.entityType,
    entityId: _conflict.entityId,
    reason: _conflict.reason,
    payload: '{"reason":"HEADCOUNT_MISMATCH","expected":19,"actual":18}',
    resolution: resolution,
    createdAt: DateTime(2026, 11, 10, 8, 15),
    resolvedAt: resolvedAt,
  );
}

Future<AppDatabase> _pumpPage(
  WidgetTester tester,
  SyncApi api,
  Stream<List<LocalConflict>> conflicts,
) async {
  final db = AppDatabase(NativeDatabase.memory());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncApiProvider.overrideWithValue(api),
        localConflictsStreamProvider.overrideWith((ref) => conflicts),
      ],
      child: const MaterialApp(home: ConflictsPage()),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('shows divergent conflicts with explicit resolutions',
      (tester) async {
    await _pumpPage(
      tester,
      ConflictSyncApi(_conflict),
      Stream.value([_localConflict()]),
    );

    expect(find.text('Conflits de synchronisation'), findsOneWidget);
    expect(find.textContaining('effectif saisi'), findsOneWidget);
    expect(find.text('Mobile : 19   •   Serveur : 18'), findsOneWidget);
    expect(find.text('Garder le mobile'), findsOneWidget);
    expect(find.text('Garder le serveur'), findsOneWidget);
    expect(find.text('Fusionner'), findsOneWidget);
  });

  testWidgets('resolving with the server value marks the conflict resolved',
      (tester) async {
    final api = ConflictSyncApi(_conflict);
    final controller = StreamController<List<LocalConflict>>();
    addTearDown(controller.close);
    controller.add([_localConflict()]);
    final db = await _pumpPage(tester, api, controller.stream);
    expect(api.lastResolution, isNull);

    await tester.tap(find.text('Garder le serveur'));
    await tester.pumpAndSettle();

    expect(api.lastResolution, 'SERVER_WINS');
    expect(await db.conflictDao.pendingCount(), 0);

    controller.add([
      _localConflict(resolution: 'SERVER_WINS', resolvedAt: DateTime.now()),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Serveur retenu'), findsOneWidget);
  });

  testWidgets('shows an empty state when nothing diverges', (tester) async {
    await _pumpPage(tester, _EmptySyncApi(), Stream.value(const []));

    expect(
      find.text('Aucun conflit : les données sont alignées.'),
      findsOneWidget,
    );
  });
}
