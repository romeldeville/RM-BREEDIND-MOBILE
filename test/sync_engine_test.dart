import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/auth/auth_repository.dart';
import 'package:rm_breeding_mobile/core/db/app_database.dart';
import 'package:rm_breeding_mobile/core/sync/local_mutation_service.dart';
import 'package:rm_breeding_mobile/core/sync/sync_api.dart';
import 'package:rm_breeding_mobile/core/sync/sync_engine.dart';
import 'package:rm_breeding_mobile/core/sync/sync_models.dart';

class FakeSyncApi extends SyncApi {
  FakeSyncApi() : super(Dio());

  PushResult pushResult = const PushResult(serverSeq: 0);
  PullResult pullResult = const PullResult(serverSeq: 0);
  bool offline = false;
  List<PushEventPayload> lastPush = const [];
  int lastCursor = -1;

  @override
  Future<PushResult> push({
    required String deviceId,
    required int clientCursor,
    required List<PushEventPayload> events,
  }) async {
    lastPush = events;
    lastCursor = clientCursor;
    if (offline) {
      throw const ApiFailure('Connexion impossible pour le moment.');
    }
    if (pushResult.accepted.isEmpty && pushResult.rejected.isEmpty) {
      return PushResult(
        serverSeq: pushResult.serverSeq,
        accepted: events.map((event) => event.id).toList(growable: false),
        conflicts: pushResult.conflicts,
      );
    }
    return pushResult;
  }

  @override
  Future<PullResult> pull({
    required int since,
    required String deviceId,
    int limit = 200,
  }) async {
    if (offline) {
      throw const ApiFailure('Connexion impossible pour le moment.');
    }
    return pullResult;
  }
}

void main() {
  late AppDatabase db;
  late FakeSyncApi api;
  late SyncEngine engine;
  const lotId = '8f14e45f-ceea-467f-a9c2-4a3f6b1d9e21';

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeSyncApi();
    engine = SyncEngine(
      outboxDao: db.outboxDao,
      syncStateDao: db.syncStateDao,
      localDataDao: db.localDataDao,
      conflictDao: db.conflictDao,
      api: api,
    );
  });

  tearDown(() async {
    await db.close();
  });

  // P13-12 / P13-15 - local write then push with stable idempotency key

  test('drains the outbox and applies the pulled delta', () async {
    await db.outboxDao.enqueue(
      aggregateType: 'lot',
      aggregateId: lotId,
      eventType: 'lot.mortality.recorded',
      payload: const {'count': 2, 'headcount': 18},
    );
    api.pullResult = PullResult(
      serverSeq: 42,
      events: [
        SyncEvent(
          id: '3f0c1a52-1111-4a3b-9c44-000000000001',
          aggregateType: 'lot',
          aggregateId: lotId,
          eventType: 'lot.headcount.updated',
          occurredAt: DateTime.utc(2026, 11, 10, 8),
          serverSeq: 41,
          payload: const {'headcount': 12},
        ),
      ],
      snapshots: SyncSnapshots(
        lots: [
          SyncSnapshot(
            aggregateType: 'lot',
            aggregateId: lotId,
            serverSeq: 41,
            payload: const {'name': 'Bande A', 'currentCount': 12},
          ),
        ],
      ),
    );

    final report = await engine.syncNow();

    expect(report.pushed, 1);
    expect(report.pulled, 1);
    expect(report.cursor, 42);
    expect(await db.outboxDao.pending(), isEmpty);

    final state = await db.syncStateDao.ensure();
    final sent = await db.select(db.outboxEvents).get();
    expect(sent.single.idempotencyKey, '${state.deviceId}:${sent.single.id}');
    expect(
      RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')
          .hasMatch(sent.single.id),
      isTrue,
      reason: 'the API only accepts UUID event identifiers',
    );
    expect(state.serverCursor, 42);
    expect(state.status, 'SYNCED');

    final lots = await db.localDataDao.lots();
    expect(lots.single.currentCount, 12);
    expect(lots.single.name, 'Bande A');
  });

  test('keeps the event idempotency key stable across retries', () async {
    await db.outboxDao.enqueue(
      aggregateType: 'lot',
      aggregateId: lotId,
      eventType: 'lot.headcount.updated',
      payload: const {'headcount': 10},
    );
    api.offline = true;
    await expectLater(engine.syncNow(), throwsA(isA<ApiFailure>()));
    final pending = await db.outboxDao.pending();
    final key = pending.single.idempotencyKey;
    expect(key, startsWith('mobile-'));

    api.offline = false;
    await engine.syncNow();

    expect(api.lastPush.single.idempotencyKey, key);
    expect(api.lastPush.single.aggregateType, 'lot');
  });

  // P13-14 - rejected events leave the queue with a stored reason

  test('removes rejected events from the pending outbox', () async {
    final event = await db.outboxDao.enqueue(
      aggregateType: 'lot',
      aggregateId: lotId,
      eventType: 'lot.headcount.updated',
      payload: const {'headcount': 10},
    );
    api.pushResult = PushResult(serverSeq: 5, rejected: [event.id]);

    final report = await engine.syncNow();

    expect(report.pushed, 0);
    expect(await db.outboxDao.pending(), isEmpty);
    final stored = await db.select(db.outboxEvents).get();
    expect(stored.single.lastError, 'REJECTED_BY_SERVER');
    expect(stored.single.sentAt, isNotNull);
  });

  // P13-15 - conflicts received on push are stored for explicit resolution

  test('stores conflicts reported by the server', () async {
    final event = await db.outboxDao.enqueue(
      aggregateType: 'lot',
      aggregateId: lotId,
      eventType: 'lot.mortality.recorded',
      payload: const {'count': 1, 'headcount': 19},
    );
    api.pushResult = PushResult(
      serverSeq: 7,
      accepted: [event.id],
      conflicts: const [
        SyncConflict(
          id: 'c1f0a3b2-2222-4a3b-9c44-000000000002',
          entityType: 'lot',
          entityId: lotId,
          reason: 'HEADCOUNT_MISMATCH',
          payload: {
            'reason': 'HEADCOUNT_MISMATCH',
            'expected': 19,
            'actual': 18,
          },
        ),
      ],
    );

    final report = await engine.syncNow();

    expect(report.conflicts, 1);
    final conflicts = await db.conflictDao.all();
    expect(conflicts.single.id, 'c1f0a3b2-2222-4a3b-9c44-000000000002');
    expect(conflicts.single.reason, 'HEADCOUNT_MISMATCH');
    expect(await db.conflictDao.pendingCount(), 1);
  });

  // P13-14 - offline keeps the outbox and records the failure

  test('marks the sync offline and keeps pending writes', () async {
    await db.outboxDao.enqueue(
      aggregateType: 'lot',
      aggregateId: lotId,
      eventType: 'lot.headcount.updated',
      payload: const {'headcount': 10},
    );
    api.offline = true;

    await expectLater(engine.syncNow(), throwsA(isA<ApiFailure>()));

    final pending = await db.outboxDao.pending();
    expect(pending, hasLength(1));
    expect(pending.single.attempts, 1);
    final state = await db.syncStateDao.ensure();
    expect(state.status, 'OFFLINE');
    expect(state.serverCursor, 0);
  });

  // P13-12 - local mutation updates the read model before the outbox

  test('local mortality decrements the cached lot headcount', () async {
    await db.localDataDao.upsertLot(
      id: lotId,
      name: 'Bande A',
      initialCount: 20,
      currentCount: 20,
    );
    final mutations = LocalMutationService(db.outboxDao, db.localDataDao);

    final event = await mutations.recordLotMortality(lotId: lotId, count: 3);

    expect(event.eventType, 'lot.mortality.recorded');
    final lots = await db.localDataDao.lots();
    expect(lots.single.currentCount, 17);
    final pending = await db.outboxDao.pending();
    expect(pending.single.payload, contains('"expectedHeadcount":20'));
  });
}
