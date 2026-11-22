import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/db/app_database.dart';
import 'package:rm_breeding_mobile/core/sync/sync_api.dart';
import 'package:rm_breeding_mobile/core/sync/sync_controller.dart';
import 'package:rm_breeding_mobile/core/sync/sync_engine.dart';

class _FakeSyncEngine extends SyncEngine {
  _FakeSyncEngine(AppDatabase db)
      : super(
          outboxDao: db.outboxDao,
          syncStateDao: db.syncStateDao,
          localDataDao: db.localDataDao,
          conflictDao: db.conflictDao,
          api: SyncApi(Dio()),
        );

  int calls = 0;

  @override
  Future<SyncReport> syncNow() async {
    calls++;
    return const SyncReport(
      pushed: 2,
      pulled: 1,
      conflicts: 0,
      cursor: 7,
      pending: 0,
    );
  }
}

void main() {
  test('connectivity loss marks the UI offline without syncing', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final engine = _FakeSyncEngine(db);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncEngineProvider.overrideWithValue(engine),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(syncControllerProvider.notifier);
    await controller.refresh();

    controller.setOnline(false);

    expect(container.read(syncControllerProvider).online, isFalse);
    expect(engine.calls, 0);
  });

  test('returning online triggers an automatic synchronization', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final engine = _FakeSyncEngine(db);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncEngineProvider.overrideWithValue(engine),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(syncControllerProvider.notifier);
    await controller.refresh();
    controller.setOnline(false);
    expect(engine.calls, 0);

    controller.setOnline(true);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(syncControllerProvider);
    expect(engine.calls, 1);
    expect(state.online, isTrue);
    expect(state.lastReport?.pulled, 1);
  });
}
