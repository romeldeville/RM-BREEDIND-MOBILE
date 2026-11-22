import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class Weighing {
  const Weighing({
    required this.id,
    this.animalId,
    this.lotId,
    required this.weighedAt,
    required this.weightKg,
    this.sampleCount,
    this.averageWeight,
  });

  factory Weighing.fromJson(Map<String, dynamic> json) {
    return Weighing(
      id: json['id'] as String? ?? '',
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      weighedAt: json['weighedAt'] as String? ?? '',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      sampleCount: (json['sampleCount'] as num?)?.toInt(),
      averageWeight: (json['averageWeight'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String? animalId;
  final String? lotId;
  final String weighedAt;
  final double weightKg;
  final int? sampleCount;
  final double? averageWeight;
}

class Gmq {
  const Gmq({
    this.animalId,
    this.lotId,
    required this.days,
    required this.startWeightKg,
    required this.endWeightKg,
    required this.gmq,
  });

  factory Gmq.fromJson(Map<String, dynamic> json) {
    return Gmq(
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      days: (json['days'] as num?)?.toInt() ?? 0,
      startWeightKg: (json['startWeightKg'] as num?)?.toDouble() ?? 0,
      endWeightKg: (json['endWeightKg'] as num?)?.toDouble() ?? 0,
      gmq: (json['gmq'] as num?)?.toDouble() ?? 0,
    );
  }

  final String? animalId;
  final String? lotId;
  final int days;
  final double startWeightKg;
  final double endWeightKg;
  final double gmq;
}

class GrowthPoint {
  const GrowthPoint({
    required this.weighedAt,
    required this.weightKg,
    this.ageDays,
  });

  factory GrowthPoint.fromJson(Map<String, dynamic> json) {
    return GrowthPoint(
      weighedAt: json['weighedAt'] as String? ?? '',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      ageDays: (json['ageDays'] as num?)?.toInt(),
    );
  }

  final String weighedAt;
  final double weightKg;
  final int? ageDays;
}

class GrowthCurve {
  const GrowthCurve({
    this.animalId,
    this.lotId,
    this.speciesId,
    this.points = const [],
    this.reference = const [],
  });

  factory GrowthCurve.fromJson(Map<String, dynamic> json) {
    return GrowthCurve(
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      speciesId: json['speciesId'] as String?,
      points: (json['points'] as List<dynamic>? ?? const [])
          .map((value) => GrowthPoint.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
      reference: (json['reference'] as List<dynamic>? ?? const [])
          .map((value) => value as Map<String, dynamic>)
          .toList(growable: false),
    );
  }

  final String? animalId;
  final String? lotId;
  final String? speciesId;
  final List<GrowthPoint> points;
  final List<Map<String, dynamic>> reference;
}

class EggCollection {
  const EggCollection({
    required this.id,
    required this.farmId,
    this.lotId,
    required this.collectedAt,
    required this.collected,
    required this.broken,
    required this.downgraded,
    required this.sellable,
  });

  factory EggCollection.fromJson(Map<String, dynamic> json) {
    return EggCollection(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      lotId: json['lotId'] as String?,
      collectedAt: json['collectedAt'] as String? ?? '',
      collected: (json['collected'] as num?)?.toInt() ?? 0,
      broken: (json['broken'] as num?)?.toInt() ?? 0,
      downgraded: (json['downgraded'] as num?)?.toInt() ?? 0,
      sellable: (json['sellable'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String farmId;
  final String? lotId;
  final String collectedAt;
  final int collected;
  final int broken;
  final int downgraded;
  final int sellable;
}

class EggMovement {
  const EggMovement({
    required this.id,
    required this.farmId,
    this.lotId,
    required this.type,
    required this.quantity,
    required this.occurredAt,
    this.reason,
  });

  factory EggMovement.fromJson(Map<String, dynamic> json) {
    return EggMovement(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      lotId: json['lotId'] as String?,
      type: json['type'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      occurredAt: json['occurredAt'] as String? ?? '',
      reason: json['reason'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String? lotId;
  final String type;
  final int quantity;
  final String occurredAt;
  final String? reason;
}

class EggStock {
  const EggStock({
    required this.farmId,
    this.lotId,
    required this.quantity,
    this.updatedAt,
  });

  factory EggStock.fromJson(Map<String, dynamic> json) {
    return EggStock(
      farmId: json['farmId'] as String? ?? '',
      lotId: json['lotId'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String farmId;
  final String? lotId;
  final int quantity;
  final String? updatedAt;
}

class LayingRate {
  const LayingRate({
    required this.lotId,
    required this.days,
    required this.henCount,
    required this.totalCollected,
    required this.layingRate,
  });

  factory LayingRate.fromJson(Map<String, dynamic> json) {
    return LayingRate(
      lotId: json['lotId'] as String? ?? '',
      days: (json['days'] as num?)?.toInt() ?? 0,
      henCount: (json['henCount'] as num?)?.toInt() ?? 0,
      totalCollected: (json['totalCollected'] as num?)?.toInt() ?? 0,
      layingRate: (json['layingRate'] as num?)?.toDouble() ?? 0,
    );
  }

  final String lotId;
  final int days;
  final int henCount;
  final int totalCollected;
  final double layingRate;
}

class ProductionRepository {
  ProductionRepository(this._dio);

  final Dio _dio;

  Future<List<Weighing>> weighings({String? animalId, String? lotId}) async {
    final data = await _get('/production/weighings', query: {
      if (animalId != null && animalId.isNotEmpty) 'animalId': animalId,
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
    });
    return _list(data, Weighing.fromJson);
  }

  Future<Weighing> createWeighing(Map<String, dynamic> body) async {
    final data = await _post('/production/weighings', body);
    return Weighing.fromJson(data);
  }

  Future<Gmq> gmq({String? animalId, String? lotId}) async {
    final data = await _get('/production/weighings/gmq', query: {
      if (animalId != null && animalId.isNotEmpty) 'animalId': animalId,
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
    });
    return Gmq.fromJson(data as Map<String, dynamic>);
  }

  Future<GrowthCurve> growthCurve({String? animalId, String? lotId}) async {
    final data = await _get('/production/growth-curve', query: {
      if (animalId != null && animalId.isNotEmpty) 'animalId': animalId,
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
    });
    return GrowthCurve.fromJson(data as Map<String, dynamic>);
  }

  Future<List<EggCollection>> collections({String? lotId}) async {
    final data = await _get('/production/egg-collections', query: {
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
    });
    return _list(data, EggCollection.fromJson);
  }

  Future<EggCollection> createCollection(Map<String, dynamic> body) async {
    final data = await _post('/production/egg-collections', body);
    return EggCollection.fromJson(data);
  }

  Future<List<EggMovement>> movements({String? lotId}) async {
    final data = await _get('/production/egg-movements', query: {
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
    });
    return _list(data, EggMovement.fromJson);
  }

  Future<EggMovement> createMovement(Map<String, dynamic> body) async {
    final data = await _post('/production/egg-movements', body);
    return EggMovement.fromJson(data);
  }

  Future<List<EggStock>> eggStocks() async {
    final data = await _get('/production/egg-stocks');
    return _list(data, EggStock.fromJson);
  }

  Future<LayingRate> layingRate({
    required String lotId,
    required String from,
    required String to,
  }) async {
    final data = await _get('/production/laying-rate', query: {
      'lotId': lotId,
      'from': from,
      'to': to,
    });
    return LayingRate.fromJson(data as Map<String, dynamic>);
  }

  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is! List) {
      return const [];
    }
    return data
        .map((value) => fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
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
}

final productionRepositoryProvider = Provider<ProductionRepository>((ref) {
  return ProductionRepository(ref.watch(dioProvider));
});
