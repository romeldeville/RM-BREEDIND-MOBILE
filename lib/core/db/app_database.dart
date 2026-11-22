import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

class Animals extends Table {
  TextColumn get id => text()();
  TextColumn get tag => text().withLength(min: 1, max: 50)();
  TextColumn get species => text()();
  TextColumn get sex => text().withDefault(const Constant('FEMALE'))();
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();
  DateTimeColumn get birthDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get severity => text()();
  TextColumn get title => text()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  BoolColumn get acknowledged => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PendingOperations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get method => text()();
  TextColumn get path => text()();
  TextColumn get body => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Offline event outbox. Every local mutation appends one row before the UI
/// acknowledges the write, so a crash or a network loss never loses the entry.
class OutboxEvents extends Table {
  TextColumn get id => text()();
  TextColumn get aggregateType => text()();
  TextColumn get aggregateId => text()();
  TextColumn get eventType => text()();
  IntColumn get eventVersion => integer().withDefault(const Constant(1))();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get idempotencyKey => text().unique()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get sentAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Single-row synchronization state: device identity, server cursor and
/// presentation status for the offline banner.
class SyncStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get deviceId => text().withDefault(const Constant(''))();
  IntColumn get serverCursor => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('IDLE'))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Read model for lots. Snapshots and local mutations update it without a
/// round-trip, which keeps field screens usable without network.
class LocalLots extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('OPEN'))();
  IntColumn get initialCount => integer().withDefault(const Constant(0))();
  IntColumn get currentCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Conflicts reported by the server or detected during a pull.
class LocalConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get reason => text().withDefault(const Constant(''))();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get resolution => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Animals,
    LocalAlerts,
    PendingOperations,
    OutboxEvents,
    SyncStates,
    LocalLots,
    LocalConflicts,
  ],
  daos: [AnimalDao, OutboxDao, SyncStateDao, LocalDataDao, ConflictDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(outboxEvents);
            await m.createTable(syncStates);
            await m.createTable(localLots);
            await m.createTable(localConflicts);
          }
        },
      );

  static QueryExecutor _openConnection() => driftDatabase(name: 'rm_breeding');

  Future<void> seedIfEmpty() async {
    final existing = await select(animals).get();
    if (existing.isNotEmpty) {
      return;
    }
    await batch((batch) {
      batch.insertAll(animals, [
        AnimalsCompanion.insert(
          id: 'a-001',
          tag: 'BOV-001',
          species: 'Bovin',
          sex: const Value('FEMALE'),
          birthDate: Value(DateTime(2022, 3, 12)),
        ),
        AnimalsCompanion.insert(
          id: 'a-002',
          tag: 'BOV-002',
          species: 'Bovin',
          sex: const Value('MALE'),
          birthDate: Value(DateTime(2021, 7, 4)),
        ),
        AnimalsCompanion.insert(
          id: 'a-003',
          tag: 'OVI-014',
          species: 'Ovin',
          sex: const Value('FEMALE'),
          birthDate: Value(DateTime(2023, 1, 22)),
        ),
      ]);
    });
  }
}

String newLocalId() {
  final random = Random().nextInt(1 << 32);
  return '${DateTime.now().microsecondsSinceEpoch}-${random.toRadixString(16)}';
}

/// RFC 4122 version 4 identifier. The API rejects non-UUID event identifiers,
/// so locally appended events use this generator.
String newUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex =
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

@DriftAccessor(tables: [Animals])
class AnimalDao extends DatabaseAccessor<AppDatabase> with _$AnimalDaoMixin {
  AnimalDao(super.db);

  Stream<List<Animal>> watchAll() => select(animals).watch();

  Future<List<Animal>> all() => select(animals).get();

  Future<void> upsert(AnimalsCompanion entry) => into(animals).insertOnConflictUpdate(entry);

  Future<void> addDemoAnimal(String tag, String species) {
    return upsert(
      AnimalsCompanion.insert(
        id: 'a-${DateTime.now().microsecondsSinceEpoch}',
        tag: tag,
        species: species,
        birthDate: Value(DateTime.now()),
      ),
    );
  }
}

@DriftAccessor(tables: [OutboxEvents])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  Future<OutboxEvent> enqueue({
    required String aggregateType,
    required String aggregateId,
    required String eventType,
    required Map<String, dynamic> payload,
    int eventVersion = 1,
    DateTime? occurredAt,
    String? eventId,
  }) async {
    final id = eventId ?? newUuidV4();
    final entry = OutboxEventsCompanion.insert(
      id: id,
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      eventType: eventType,
      eventVersion: Value(eventVersion),
      occurredAt: occurredAt ?? DateTime.now(),
      payload: Value(jsonEncode(payload)),
      idempotencyKey: 'pending:$id',
    );
    await into(outboxEvents).insert(entry);
    return (select(outboxEvents)..where((row) => row.id.equals(id))).getSingle();
  }

  /// Attach the stable device key once the device identity is known.
  Future<void> assignIdempotencyKeys(String deviceId) async {
    final pending = await (select(outboxEvents)
          ..where((row) => row.sentAt.isNull() & row.idempotencyKey.like('pending:%')))
        .get();
    for (final event in pending) {
      await (update(outboxEvents)..where((row) => row.id.equals(event.id))).write(
        OutboxEventsCompanion(
          idempotencyKey: Value('$deviceId:${event.id}'),
        ),
      );
    }
  }

  Future<List<OutboxEvent>> pending({int limit = 100}) {
    return (select(outboxEvents)
          ..where((row) => row.sentAt.isNull())
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<int> pendingCount() async {
    final count = outboxEvents.id.count();
    final query = selectOnly(outboxEvents)
      ..addColumns([count])
      ..where(outboxEvents.sentAt.isNull());
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<void> markSent(Iterable<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await (update(outboxEvents)..where((row) => row.id.isIn(ids)))
        .write(OutboxEventsCompanion(sentAt: Value(DateTime.now())));
  }

  Future<void> markFailed(String id, String error) async {
    final current = await (select(outboxEvents)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (current == null) {
      return;
    }
    await (update(outboxEvents)..where((row) => row.id.equals(id))).write(
      OutboxEventsCompanion(
        attempts: Value(current.attempts + 1),
        lastError: Value(error),
      ),
    );
  }

  Future<void> markRejected(String id, String reason) async {
    await (update(outboxEvents)..where((row) => row.id.equals(id))).write(
      OutboxEventsCompanion(
        sentAt: Value(DateTime.now()),
        lastError: Value(reason),
      ),
    );
  }

  Future<void> purgeSent({int keep = 500}) async {
    final sent = await (select(outboxEvents)
          ..where((row) => row.sentAt.isNotNull())
          ..orderBy([(row) => OrderingTerm.desc(row.sentAt)])
          ..limit(1000, offset: keep))
        .get();
    final ids = sent.map((event) => event.id).toList(growable: false);
    if (ids.isNotEmpty) {
      await (delete(outboxEvents)..where((row) => row.id.isIn(ids))).go();
    }
  }
}

@DriftAccessor(tables: [SyncStates])
class SyncStateDao extends DatabaseAccessor<AppDatabase> with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  static const _singletonId = 0;

  Future<SyncState> ensure() async {
    final existing =
        await (select(syncStates)..where((row) => row.id.equals(_singletonId))).getSingleOrNull();
    if (existing != null) {
      if (existing.deviceId.isNotEmpty) {
        return existing;
      }
      final deviceId = 'mobile-${newLocalId()}';
      await (update(syncStates)..where((row) => row.id.equals(_singletonId)))
          .write(SyncStatesCompanion(deviceId: Value(deviceId)));
      return (select(syncStates)..where((row) => row.id.equals(_singletonId))).getSingle();
    }
    final deviceId = 'mobile-${newLocalId()}';
    await into(syncStates).insert(
      SyncStatesCompanion.insert(
        id: const Value(_singletonId),
        deviceId: Value(deviceId),
      ),
    );
    return (select(syncStates)..where((row) => row.id.equals(_singletonId))).getSingle();
  }

  Future<void> updateCursor(int cursor) async {
    await ensure();
    await (update(syncStates)..where((row) => row.id.equals(_singletonId))).write(
      SyncStatesCompanion(serverCursor: Value(cursor)),
    );
  }

  Future<void> updateStatus(
    String status, {
    String? error,
    DateTime? lastSyncAt,
  }) async {
    await ensure();
    await (update(syncStates)..where((row) => row.id.equals(_singletonId))).write(
      SyncStatesCompanion(
        status: Value(status),
        lastError: Value(error),
        lastSyncAt: lastSyncAt == null ? const Value.absent() : Value(lastSyncAt),
      ),
    );
  }

  Stream<SyncState?> watch() {
    return (select(syncStates)..where((row) => row.id.equals(_singletonId))).watchSingleOrNull();
  }
}

@DriftAccessor(tables: [Animals, LocalAlerts, LocalLots])
class LocalDataDao extends DatabaseAccessor<AppDatabase> with _$LocalDataDaoMixin {
  LocalDataDao(super.db);

  Stream<List<LocalLot>> watchLots() => select(localLots).watch();

  Future<List<LocalLot>> lots() => select(localLots).get();

  Future<void> upsertLot({
    required String id,
    String? name,
    String? status,
    int? initialCount,
    int? currentCount,
  }) async {
    final existing =
        await (select(localLots)..where((row) => row.id.equals(id))).getSingleOrNull();
    await into(localLots).insertOnConflictUpdate(
      LocalLotsCompanion.insert(
        id: id,
        name: Value(name ?? existing?.name ?? ''),
        status: Value(status ?? existing?.status ?? 'OPEN'),
        initialCount: Value(initialCount ?? existing?.initialCount ?? 0),
        currentCount: Value(currentCount ?? existing?.currentCount ?? 0),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> applyHeadcount(String lotId, int headcount) async {
    final existing =
        await (select(localLots)..where((row) => row.id.equals(lotId))).getSingleOrNull();
    if (existing == null) {
      await upsertLot(id: lotId, currentCount: headcount);
      return;
    }
    await (update(localLots)..where((row) => row.id.equals(lotId))).write(
      LocalLotsCompanion(
        currentCount: Value(headcount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> upsertAnimalSnapshot(Map<String, dynamic> snapshot) async {
    final id = snapshot['id'] as String? ?? snapshot['aggregateId'] as String? ?? '';
    if (id.isEmpty) {
      return;
    }
    final raw = snapshot['payload'];
    final payload = raw is Map<String, dynamic> ? raw : snapshot;
    final tag = payload['tag'] as String? ?? payload['identifier'] as String? ?? id;
    final species = payload['species'] as String? ?? payload['speciesId'] as String? ?? '';
    await into(animals).insertOnConflictUpdate(
      AnimalsCompanion.insert(
        id: id,
        tag: tag,
        species: species,
        sex: Value(payload['sex'] as String? ?? 'FEMALE'),
        status: Value(payload['status'] as String? ?? 'ACTIVE'),
        birthDate: Value(_parseDate(payload['birthDate'])),
        createdAt: Value(_parseDate(payload['createdAt']) ?? DateTime.now()),
      ),
    );
  }

  Future<void> upsertAlertSnapshot(Map<String, dynamic> snapshot) async {
    final id = snapshot['id'] as String? ?? snapshot['aggregateId'] as String? ?? '';
    if (id.isEmpty) {
      return;
    }
    final raw = snapshot['payload'];
    final payload = raw is Map<String, dynamic> ? raw : snapshot;
    await into(localAlerts).insertOnConflictUpdate(
      LocalAlertsCompanion.insert(
        id: id,
        severity: payload['priority'] as String? ?? payload['severity'] as String? ?? 'INFO',
        title: payload['title'] as String? ?? 'Alerte',
        dueAt: Value(_parseDate(payload['dueDate']) ?? _parseDate(payload['dueAt'])),
        acknowledged: Value((payload['status'] as String? ?? 'OPEN') != 'OPEN'),
      ),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

@DriftAccessor(tables: [LocalConflicts])
class ConflictDao extends DatabaseAccessor<AppDatabase> with _$ConflictDaoMixin {
  ConflictDao(super.db);

  Stream<List<LocalConflict>> watchAll() {
    return (select(localConflicts)
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
        .watch();
  }

  Future<List<LocalConflict>> all() {
    return (select(localConflicts)
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
        .get();
  }

  Future<int> pendingCount() async {
    final count = localConflicts.id.count();
    final query = selectOnly(localConflicts)
      ..addColumns([count])
      ..where(localConflicts.resolvedAt.isNull());
    return (await query.getSingle()).read(count) ?? 0;
  }

  Future<void> upsertFromServer(Map<String, dynamic> conflict) async {
    final id = conflict['id'] as String? ?? '';
    if (id.isEmpty) {
      return;
    }
    final payload = conflict['payload'];
    final reason = payload is Map<String, dynamic>
        ? payload['reason'] as String? ?? ''
        : '';
    await into(localConflicts).insertOnConflictUpdate(
      LocalConflictsCompanion.insert(
        id: id,
        entityType: conflict['entityType'] as String? ?? '',
        entityId: conflict['entityId'] as String? ?? '',
        reason: Value(reason),
        payload: Value(jsonEncode(payload ?? const <String, dynamic>{})),
        resolution: Value(conflict['resolution'] as String?),
        createdAt: Value(DateTime.tryParse(conflict['createdAt'] as String? ?? '') ?? DateTime.now()),
        resolvedAt: Value(DateTime.tryParse(conflict['resolvedAt'] as String? ?? '')),
      ),
    );
  }

  Future<void> markResolved(String id, String resolution) async {
    await (update(localConflicts)..where((row) => row.id.equals(id))).write(
      LocalConflictsCompanion(
        resolution: Value(resolution),
        resolvedAt: Value(DateTime.now()),
      ),
    );
  }
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final animalDaoProvider = Provider<AnimalDao>((ref) {
  return ref.watch(databaseProvider).animalDao;
});

final outboxDaoProvider = Provider<OutboxDao>((ref) {
  return ref.watch(databaseProvider).outboxDao;
});

final syncStateDaoProvider = Provider<SyncStateDao>((ref) {
  return ref.watch(databaseProvider).syncStateDao;
});

final localDataDaoProvider = Provider<LocalDataDao>((ref) {
  return ref.watch(databaseProvider).localDataDao;
});

final conflictDaoProvider = Provider<ConflictDao>((ref) {
  return ref.watch(databaseProvider).conflictDao;
});

final animalsStreamProvider = StreamProvider<List<Animal>>((ref) {
  return ref.watch(animalDaoProvider).watchAll();
});

final pendingOutboxCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .customSelect(
        'SELECT COUNT(*) AS c FROM outbox_events WHERE sent_at IS NULL',
        readsFrom: {db.outboxEvents},
      )
      .watchSingle()
      .map((row) => row.read<int>('c'));
});

final syncStateStreamProvider = StreamProvider<SyncState?>((ref) {
  return ref.watch(syncStateDaoProvider).watch();
});

final localConflictsStreamProvider = StreamProvider<List<LocalConflict>>((ref) {
  return ref.watch(conflictDaoProvider).watchAll();
});
