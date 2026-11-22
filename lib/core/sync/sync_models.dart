import 'dart:convert';

class PushEventPayload {
  const PushEventPayload({
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.eventType,
    required this.occurredAt,
    required this.idempotencyKey,
    required this.payload,
    this.eventVersion = 1,
    this.farmId,
    this.clientId,
  });

  final String id;
  final String aggregateType;
  final String aggregateId;
  final String eventType;
  final int eventVersion;
  final DateTime occurredAt;
  final String idempotencyKey;
  final Map<String, dynamic> payload;
  final String? farmId;
  final String? clientId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aggregateType': aggregateType,
      'aggregateId': aggregateId,
      'eventType': eventType,
      'eventVersion': eventVersion,
      'occurredAt': occurredAt.toUtc().toIso8601String(),
      'idempotencyKey': idempotencyKey,
      'payload': payload,
      if (farmId != null) 'farmId': farmId,
      if (clientId != null) 'clientId': clientId,
    };
  }
}

class SyncConflict {
  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.clientEventId,
    this.serverEventId,
    this.resolution,
    this.resolvedAt,
    this.createdAt,
    this.reason = '',
    this.payload = const {},
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    final payload = rawPayload is Map<String, dynamic> ? rawPayload : const <String, dynamic>{};
    return SyncConflict(
      id: json['id'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      clientEventId: json['clientEventId'] as String?,
      serverEventId: json['serverEventId'] as String?,
      resolution: json['resolution'] as String?,
      resolvedAt: json['resolvedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      reason: payload['reason'] as String? ?? '',
      payload: payload,
    );
  }

  final String id;
  final String entityType;
  final String entityId;
  final String? clientEventId;
  final String? serverEventId;
  final String? resolution;
  final String? resolvedAt;
  final String? createdAt;
  final String reason;
  final Map<String, dynamic> payload;

  bool get resolved => resolvedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      if (clientEventId != null) 'clientEventId': clientEventId,
      if (serverEventId != null) 'serverEventId': serverEventId,
      if (resolution != null) 'resolution': resolution,
      if (resolvedAt != null) 'resolvedAt': resolvedAt,
      if (createdAt != null) 'createdAt': createdAt,
      'payload': payload,
    };
  }

  String get label {
    final type = entityType.isEmpty ? 'élément' : entityType;
    return 'Conflit sur $type';
  }

  String get description {
    return switch (reason) {
      'HEADCOUNT_MISMATCH' => 'Effectif divergent entre le mobile et le serveur.',
      'STOCK_MISMATCH' => 'Stock divergent entre le mobile et le serveur.',
      _ when reason.isNotEmpty => reason,
      _ => 'Valeurs divergentes détectées pendant la synchronisation.',
    };
  }
}

class SyncEvent {
  const SyncEvent({
    required this.id,
    required this.aggregateType,
    required this.aggregateId,
    required this.eventType,
    required this.occurredAt,
    this.eventVersion = 1,
    this.serverSeq = 0,
    this.payload = const {},
  });

  factory SyncEvent.fromJson(Map<String, dynamic> json) {
    return SyncEvent(
      id: json['id'] as String? ?? '',
      aggregateType: json['aggregateType'] as String? ?? '',
      aggregateId: json['aggregateId'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      eventVersion: json['eventVersion'] as int? ?? 1,
      occurredAt: DateTime.tryParse(json['occurredAt'] as String? ?? '') ?? DateTime.now(),
      serverSeq: (json['serverSeq'] as num?)?.toInt() ?? 0,
      payload: _map(json['payload']),
    );
  }

  final String id;
  final String aggregateType;
  final String aggregateId;
  final String eventType;
  final int eventVersion;
  final DateTime occurredAt;
  final int serverSeq;
  final Map<String, dynamic> payload;
}

class SyncSnapshot {
  const SyncSnapshot({
    required this.aggregateType,
    required this.aggregateId,
    required this.payload,
    this.serverSeq = 0,
    this.eventType = '',
    this.occurredAt,
  });

  factory SyncSnapshot.fromJson(Map<String, dynamic> json) {
    return SyncSnapshot(
      aggregateType: json['aggregateType'] as String? ?? '',
      aggregateId: json['aggregateId'] as String? ?? '',
      serverSeq: (json['serverSeq'] as num?)?.toInt() ?? 0,
      eventType: json['eventType'] as String? ?? '',
      occurredAt: DateTime.tryParse(json['occurredAt'] as String? ?? ''),
      payload: _map(json['payload']),
    );
  }

  final String aggregateType;
  final String aggregateId;
  final int serverSeq;
  final String eventType;
  final DateTime? occurredAt;
  final Map<String, dynamic> payload;
}

class SyncSnapshots {
  const SyncSnapshots({
    this.lots = const [],
    this.animals = const [],
    this.alerts = const [],
  });

  factory SyncSnapshots.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SyncSnapshots();
    }
    List<SyncSnapshot> read(String key) {
      final values = json[key];
      if (values is! List) {
        return const [];
      }
      return values
          .whereType<Map<String, dynamic>>()
          .map(SyncSnapshot.fromJson)
          .toList(growable: false);
    }

    return SyncSnapshots(
      lots: read('lots'),
      animals: read('animals'),
      alerts: read('alerts'),
    );
  }

  final List<SyncSnapshot> lots;
  final List<SyncSnapshot> animals;
  final List<SyncSnapshot> alerts;
}

class PullResult {
  const PullResult({
    required this.serverSeq,
    this.events = const [],
    this.snapshots = const SyncSnapshots(),
    this.hasMore = false,
  });

  factory PullResult.fromJson(Map<String, dynamic> json) {
    final events = json['events'];
    return PullResult(
      serverSeq: (json['serverSeq'] as num?)?.toInt() ?? 0,
      events: events is List
          ? events
              .whereType<Map<String, dynamic>>()
              .map(SyncEvent.fromJson)
              .toList(growable: false)
          : const [],
      snapshots: SyncSnapshots.fromJson(
        json['snapshots'] is Map<String, dynamic>
            ? json['snapshots'] as Map<String, dynamic>
            : null,
      ),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  final int serverSeq;
  final List<SyncEvent> events;
  final SyncSnapshots snapshots;
  final bool hasMore;
}

class PushResult {
  const PushResult({
    required this.serverSeq,
    this.accepted = const [],
    this.duplicates = const [],
    this.rejected = const [],
    this.conflicts = const [],
  });

  factory PushResult.fromJson(Map<String, dynamic> json) {
    List<String> ids(String key) {
      final values = json[key];
      if (values is! List) {
        return const [];
      }
      return values.whereType<String>().toList(growable: false);
    }

    final conflicts = json['conflicts'];
    return PushResult(
      serverSeq: (json['serverSeq'] as num?)?.toInt() ?? 0,
      accepted: ids('accepted'),
      duplicates: ids('duplicates'),
      rejected: (json['rejected'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((value) => value['id'] as String? ?? '')
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      conflicts: conflicts is List
          ? conflicts
              .whereType<Map<String, dynamic>>()
              .map(SyncConflict.fromJson)
              .toList(growable: false)
          : const [],
    );
  }

  final int serverSeq;
  final List<String> accepted;
  final List<String> duplicates;
  final List<String> rejected;
  final List<SyncConflict> conflicts;

  Set<String> get acknowledged => {...accepted, ...duplicates};
}

class SyncStatus {
  const SyncStatus({
    required this.serverSeq,
    required this.clientCursor,
    required this.pendingServerEvents,
    required this.pendingConflicts,
    this.lastSeenAt,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      serverSeq: (json['serverSeq'] as num?)?.toInt() ?? 0,
      clientCursor: (json['clientCursor'] as num?)?.toInt() ?? 0,
      pendingServerEvents: (json['pendingServerEvents'] as num?)?.toInt() ?? 0,
      pendingConflicts: (json['pendingConflicts'] as num?)?.toInt() ?? 0,
      lastSeenAt: json['lastSeenAt'] as String?,
    );
  }

  final int serverSeq;
  final int clientCursor;
  final int pendingServerEvents;
  final int pendingConflicts;
  final String? lastSeenAt;
}

class OfflineEventDraft {
  const OfflineEventDraft({
    required this.aggregateType,
    required this.aggregateId,
    required this.eventType,
    required this.payload,
    this.eventVersion = 1,
    this.farmId,
  });

  final String aggregateType;
  final String aggregateId;
  final String eventType;
  final Map<String, dynamic> payload;
  final int eventVersion;
  final String? farmId;
}

Map<String, dynamic> decodePayload(String raw) {
  if (raw.isEmpty) {
    return const {};
  }
  final decoded = jsonDecode(raw);
  return decoded is Map<String, dynamic> ? decoded : const {};
}

Map<String, dynamic> _map(Object? value) {
  return value is Map<String, dynamic> ? value : const {};
}
