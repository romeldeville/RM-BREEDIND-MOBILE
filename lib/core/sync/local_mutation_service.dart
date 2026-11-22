import '../db/app_database.dart';

/// Local-first write path: update the read model and append an event to the
/// outbox in the same database transaction. Sync will deliver the event later.
class LocalMutationService {
  LocalMutationService(this._outboxDao, this._localDataDao);

  final OutboxDao _outboxDao;
  final LocalDataDao _localDataDao;

  Future<OutboxEvent> recordLotMortality({
    required String lotId,
    required int count,
    String? cause,
    DateTime? occurredAt,
  }) async {
    final lots = await _localDataDao.lots();
    final current = lots.where((lot) => lot.id == lotId).firstOrNull;
    final previous = current?.currentCount;
    final next =
        previous == null ? null : (previous - count).clamp(0, 1 << 30);
    if (next != null) {
      await _localDataDao.applyHeadcount(lotId, next);
    }
    return _outboxDao.enqueue(
      aggregateType: 'lot',
      aggregateId: lotId,
      eventType: 'lot.mortality.recorded',
      occurredAt: occurredAt,
      payload: {
        'count': count,
        'cause': ?cause,
        'headcount': ?next,
        'expectedHeadcount': ?previous,
      },
    );
  }

  Future<OutboxEvent> recordLotHeadcount({
    required String lotId,
    required int headcount,
    String eventType = 'lot.headcount.updated',
    DateTime? occurredAt,
  }) async {
    final lots = await _localDataDao.lots();
    final previous = lots.where((lot) => lot.id == lotId).firstOrNull?.currentCount;
    await _localDataDao.applyHeadcount(lotId, headcount);
    return _outboxDao.enqueue(
      aggregateType: 'lot',
      aggregateId: lotId,
      eventType: eventType,
      occurredAt: occurredAt,
      payload: {
        'headcount': headcount,
        'expectedHeadcount': ?previous,
      },
    );
  }

  Future<OutboxEvent> recordAnimalStatus({
    required String animalId,
    required String status,
    String? reason,
    DateTime? occurredAt,
  }) {
    return _outboxDao.enqueue(
      aggregateType: 'animal',
      aggregateId: animalId,
      eventType: 'animal.status.changed',
      occurredAt: occurredAt,
      payload: {
        'status': status,
        'reason': ?reason,
      },
    );
  }

  Future<OutboxEvent> record({
    required String aggregateType,
    required String aggregateId,
    required String eventType,
    required Map<String, dynamic> payload,
    DateTime? occurredAt,
  }) {
    return _outboxDao.enqueue(
      aggregateType: aggregateType,
      aggregateId: aggregateId,
      eventType: eventType,
      occurredAt: occurredAt,
      payload: payload,
    );
  }
}
