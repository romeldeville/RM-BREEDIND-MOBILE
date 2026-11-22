import '../auth/auth_repository.dart';
import '../db/app_database.dart';
import 'sync_api.dart';
import 'sync_models.dart';

class SyncReport {
  const SyncReport({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
    required this.cursor,
    required this.pending,
  });

  final int pushed;
  final int pulled;
  final int conflicts;
  final int cursor;
  final int pending;
}

/// Orchestrates the push/pull cycle. Push always drains the outbox first, then
/// pull applies the server delta and snapshots so local projections converge.
class SyncEngine {
  SyncEngine({
    required OutboxDao outboxDao,
    required SyncStateDao syncStateDao,
    required LocalDataDao localDataDao,
    required ConflictDao conflictDao,
    required SyncApi api,
  })  : _outboxDao = outboxDao,
        _syncStateDao = syncStateDao,
        _localDataDao = localDataDao,
        _conflictDao = conflictDao,
        _api = api;

  final OutboxDao _outboxDao;
  final SyncStateDao _syncStateDao;
  final LocalDataDao _localDataDao;
  final ConflictDao _conflictDao;
  final SyncApi _api;

  Future<SyncReport> syncNow() async {
    final state = await _syncStateDao.ensure();
    final deviceId = state.deviceId;
    await _outboxDao.assignIdempotencyKeys(deviceId);
    final pending = await _outboxDao.pending();
    var cursor = state.serverCursor;
    var pushed = 0;
    var pulled = 0;
    var conflicts = 0;

    try {
      if (pending.isNotEmpty) {
        final result = await _api.push(
          deviceId: deviceId,
          clientCursor: cursor,
          events: pending
              .map(
                (event) => PushEventPayload(
                  id: event.id,
                  aggregateType: event.aggregateType,
                  aggregateId: event.aggregateId,
                  eventType: event.eventType,
                  eventVersion: event.eventVersion,
                  occurredAt: event.occurredAt,
                  idempotencyKey: event.idempotencyKey,
                  payload: decodePayload(event.payload),
                  clientId: deviceId,
                ),
              )
              .toList(growable: false),
        );
        await _outboxDao.markSent(result.acknowledged);
        for (final rejected in result.rejected) {
          await _outboxDao.markRejected(rejected, 'REJECTED_BY_SERVER');
        }
        for (final conflict in result.conflicts) {
          await _conflictDao.upsertFromServer(conflict.toJson());
        }
        pushed = result.acknowledged.length;
        conflicts += result.conflicts.length;
      }

      for (var page = 0; page < 20; page++) {
        final pull = await _api.pull(since: cursor, deviceId: deviceId);
        await _applyPull(pull);
        pulled += pull.events.length;
        cursor = pull.serverSeq;
        if (!pull.hasMore) {
          break;
        }
      }

      await _syncStateDao.updateCursor(cursor);
      await _syncStateDao.updateStatus('SYNCED', lastSyncAt: DateTime.now());
      final remaining = await _outboxDao.pendingCount();
      final openConflicts = await _conflictDao.pendingCount();
      return SyncReport(
        pushed: pushed,
        pulled: pulled,
        conflicts: conflicts,
        cursor: cursor,
        pending: remaining + openConflicts,
      );
    } on ApiFailure catch (error) {
      await _failPending(pending, error.message);
      await _syncStateDao.updateStatus('OFFLINE', error: error.message);
      rethrow;
    } catch (error) {
      await _failPending(pending, error.toString());
      await _syncStateDao.updateStatus('ERROR', error: error.toString());
      rethrow;
    }
  }

  Future<void> _applyPull(PullResult result) async {
    for (final event in result.events) {
      final payload = event.payload;
      final headcount = payload['headcount'];
      if (event.aggregateType == 'lot' && headcount is num) {
        await _localDataDao.applyHeadcount(event.aggregateId, headcount.toInt());
      }
    }
    for (final lot in result.snapshots.lots) {
      final payload = lot.payload;
      await _localDataDao.upsertLot(
        id: lot.aggregateId,
        name: payload['name'] as String?,
        status: payload['status'] as String?,
        initialCount: _asInt(payload['initialCount']),
        currentCount: _asInt(payload['currentCount'] ?? payload['headcount']),
      );
    }
    for (final animal in result.snapshots.animals) {
      await _localDataDao.upsertAnimalSnapshot({
        'aggregateId': animal.aggregateId,
        'payload': animal.payload,
      });
    }
    for (final alert in result.snapshots.alerts) {
      await _localDataDao.upsertAlertSnapshot({
        'aggregateId': alert.aggregateId,
        'payload': alert.payload,
      });
    }
  }

  Future<void> _failPending(List<OutboxEvent> pending, String error) async {
    for (final event in pending) {
      await _outboxDao.markFailed(event.id, error);
    }
  }

  static int? _asInt(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
