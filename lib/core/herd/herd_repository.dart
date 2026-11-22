import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class Animal {
  const Animal({
    required this.id,
    required this.farmId,
    required this.speciesId,
    required this.identifier,
    required this.sex,
    required this.status,
    this.breedId,
    this.penId,
    this.name,
    this.birthDate,
    this.birthEstimated = false,
    this.origin,
    this.motherId,
    this.fatherId,
    this.photoKey,
    this.weightKg,
    this.acquiredAt,
    this.archivedAt,
    this.createdAt,
    this.updatedAt,
    this.version = 0,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      speciesId: json['speciesId'] as String? ?? '',
      breedId: json['breedId'] as String?,
      penId: json['penId'] as String?,
      identifier: json['identifier'] as String? ?? '',
      name: json['name'] as String?,
      sex: json['sex'] as String? ?? 'UNKNOWN',
      birthDate: json['birthDate'] as String?,
      birthEstimated: json['birthEstimated'] as bool? ?? false,
      origin: json['origin'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      motherId: json['motherId'] as String?,
      fatherId: json['fatherId'] as String?,
      photoKey: json['photoKey'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      acquiredAt: json['acquiredAt'] as String?,
      archivedAt: json['archivedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      version: json['version'] as int? ?? 0,
    );
  }

  final String id;
  final String farmId;
  final String speciesId;
  final String? breedId;
  final String? penId;
  final String identifier;
  final String? name;
  final String sex;
  final String? birthDate;
  final bool birthEstimated;
  final String? origin;
  final String status;
  final String? motherId;
  final String? fatherId;
  final String? photoKey;
  final double? weightKg;
  final String? acquiredAt;
  final String? archivedAt;
  final String? createdAt;
  final String? updatedAt;
  final int version;
}

class AnimalStatusEntry {
  const AnimalStatusEntry({
    required this.id,
    required this.animalId,
    required this.status,
    required this.changedAt,
    this.reason,
    this.actorId,
  });

  factory AnimalStatusEntry.fromJson(Map<String, dynamic> json) {
    return AnimalStatusEntry(
      id: json['id'] as String? ?? '',
      animalId: json['animalId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      changedAt: json['changedAt'] as String? ?? '',
      reason: json['reason'] as String?,
      actorId: json['actorId'] as String?,
    );
  }

  final String id;
  final String animalId;
  final String status;
  final String changedAt;
  final String? reason;
  final String? actorId;
}

class AnimalPage {
  const AnimalPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  factory AnimalPage.fromJson(Map<String, dynamic> json) {
    return AnimalPage(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((value) => Animal.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  final List<Animal> items;
  final String? nextCursor;
  final bool hasMore;
}

class Lot {
  const Lot({
    required this.id,
    required this.farmId,
    required this.speciesId,
    required this.name,
    required this.status,
    required this.initialCount,
    required this.currentCount,
    this.code,
    this.productionType,
    this.entryDate,
    this.origin,
    this.unitCost,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
    this.version = 0,
  });

  factory Lot.fromJson(Map<String, dynamic> json) {
    return Lot(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      speciesId: json['speciesId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      productionType: json['productionType'] as String?,
      status: json['status'] as String? ?? 'OPEN',
      entryDate: json['entryDate'] as String?,
      initialCount: json['initialCount'] as int? ?? 0,
      currentCount: json['currentCount'] as int? ?? 0,
      origin: json['origin'] as String?,
      unitCost: (json['unitCost'] as num?)?.toDouble(),
      closedAt: json['closedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      version: json['version'] as int? ?? 0,
    );
  }

  final String id;
  final String farmId;
  final String speciesId;
  final String name;
  final String? code;
  final String? productionType;
  final String status;
  final String? entryDate;
  final int initialCount;
  final int currentCount;
  final String? origin;
  final double? unitCost;
  final String? closedAt;
  final String? createdAt;
  final String? updatedAt;
  final int version;
}

class LotPage {
  const LotPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  factory LotPage.fromJson(Map<String, dynamic> json) {
    return LotPage(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((value) => Lot.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  final List<Lot> items;
  final String? nextCursor;
  final bool hasMore;
}

class LotMovement {
  const LotMovement({
    required this.id,
    required this.lotId,
    required this.type,
    required this.quantity,
    required this.occurredAt,
    this.reason,
    this.actorId,
    this.createdAt,
  });

  factory LotMovement.fromJson(Map<String, dynamic> json) {
    return LotMovement(
      id: json['id'] as String? ?? '',
      lotId: json['lotId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      occurredAt: json['occurredAt'] as String? ?? '',
      reason: json['reason'] as String?,
      actorId: json['actorId'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  final String id;
  final String lotId;
  final String type;
  final int quantity;
  final String occurredAt;
  final String? reason;
  final String? actorId;
  final String? createdAt;
}

class LotClosure {
  const LotClosure({
    required this.lotId,
    required this.closedAt,
    this.mortalityRate,
    this.feedConversion,
    this.gmq,
    this.cost,
    this.revenue,
    this.margin,
  });

  factory LotClosure.fromJson(Map<String, dynamic> json) {
    return LotClosure(
      lotId: json['lotId'] as String? ?? '',
      mortalityRate: (json['mortalityRate'] as num?)?.toDouble(),
      feedConversion: (json['feedConversion'] as num?)?.toDouble(),
      gmq: (json['gmq'] as num?)?.toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      revenue: (json['revenue'] as num?)?.toDouble(),
      margin: (json['margin'] as num?)?.toDouble(),
      closedAt: json['closedAt'] as String? ?? '',
    );
  }

  final String lotId;
  final double? mortalityRate;
  final double? feedConversion;
  final double? gmq;
  final double? cost;
  final double? revenue;
  final double? margin;
  final String closedAt;
}

class HerdRepository {
  HerdRepository(this._dio);

  final Dio _dio;

  Future<AnimalPage> animals({
    String? search,
    String? status,
    String? speciesId,
    String? penId,
    String? lotId,
    int limit = 50,
    String? cursor,
  }) async {
    final data = await _get('/animals', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (speciesId != null && speciesId.isNotEmpty) 'speciesId': speciesId,
      if (penId != null && penId.isNotEmpty) 'penId': penId,
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
      'limit': limit,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    });
    return AnimalPage.fromJson(data as Map<String, dynamic>);
  }

  Future<Animal> animal(String id) async {
    final data = await _get('/animals/$id');
    return Animal.fromJson(data as Map<String, dynamic>);
  }

  Future<Animal> createAnimal(Map<String, dynamic> body) async {
    final data = await _post('/animals', body);
    return Animal.fromJson(data);
  }

  Future<Animal> patchAnimal(String id, Map<String, dynamic> body) async {
    final data = await _patch('/animals/$id', body);
    return Animal.fromJson(data);
  }

  Future<AnimalStatusEntry> changeStatus(
    String id,
    Map<String, dynamic> body,
  ) async {
    final data = await _post('/animals/$id/status', body);
    return AnimalStatusEntry.fromJson(data);
  }

  Future<List<AnimalStatusEntry>> statusHistory(String id) async {
    final data = await _get('/animals/$id/status-history');
    return (data as List<dynamic>)
        .map((value) => AnimalStatusEntry.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Animal> individualize(String lotId, Map<String, dynamic> body) async {
    final data = await _post('/animals/$lotId/individualize', body);
    return Animal.fromJson(data);
  }

  Future<LotPage> lots({
    String? status,
    String? speciesId,
    int limit = 50,
    String? cursor,
  }) async {
    final data = await _get('/lots', query: {
      if (status != null && status.isNotEmpty) 'status': status,
      if (speciesId != null && speciesId.isNotEmpty) 'speciesId': speciesId,
      'limit': limit,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    });
    return LotPage.fromJson(data as Map<String, dynamic>);
  }

  Future<Lot> lot(String id) async {
    final data = await _get('/lots/$id');
    return Lot.fromJson(data as Map<String, dynamic>);
  }

  Future<Lot> createLot(Map<String, dynamic> body) async {
    final data = await _post('/lots', body);
    return Lot.fromJson(data);
  }

  Future<Lot> patchLot(String id, Map<String, dynamic> body) async {
    final data = await _patch('/lots/$id', body);
    return Lot.fromJson(data);
  }

  Future<LotMovement> moveLot(String id, Map<String, dynamic> body) async {
    final data = await _post('/lots/$id/movements', body);
    return LotMovement.fromJson(data);
  }

  Future<List<LotMovement>> lotMovements(String id) async {
    final data = await _get('/lots/$id/movements');
    return (data as List<dynamic>)
        .map((value) => LotMovement.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<LotClosure> closeLot(String id) async {
    final data = await _post('/lots/$id/close', const {});
    return LotClosure.fromJson(data);
  }

  Future<Lot> splitLot(String id, Map<String, dynamic> body) async {
    final data = await _post('/lots/$id/split', body);
    return Lot.fromJson(data);
  }

  Future<Lot> mergeLot(String id, Map<String, dynamic> body) async {
    final data = await _post('/lots/$id/merge', body);
    return Lot.fromJson(data);
  }

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return response.data;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      return (response.data as Map<String, dynamic>?) ?? const {};
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> _patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: body);
      return (response.data as Map<String, dynamic>?) ?? const {};
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final herdRepositoryProvider = Provider<HerdRepository>((ref) {
  return HerdRepository(ref.watch(dioProvider));
});
