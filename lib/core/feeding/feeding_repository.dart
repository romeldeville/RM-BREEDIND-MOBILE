import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class Feed {
  const Feed({
    required this.id,
    required this.name,
    this.type,
    required this.unit,
    this.price,
    this.supplier,
    this.archivedAt,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      unit: json['unit'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble(),
      supplier: json['supplier'] as String?,
      archivedAt: json['archivedAt'] as String?,
    );
  }

  final String id;
  final String name;
  final String? type;
  final String unit;
  final double? price;
  final String? supplier;
  final String? archivedAt;
}

class FeedReceipt {
  const FeedReceipt({
    required this.id,
    required this.feedId,
    required this.quantity,
    this.unitPrice,
    required this.receivedAt,
    this.supplier,
    this.expiryDate,
    this.notes,
  });

  factory FeedReceipt.fromJson(Map<String, dynamic> json) {
    return FeedReceipt(
      id: json['id'] as String? ?? '',
      feedId: json['feedId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      receivedAt: json['receivedAt'] as String? ?? '',
      supplier: json['supplier'] as String?,
      expiryDate: json['expiryDate'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String feedId;
  final double quantity;
  final double? unitPrice;
  final String receivedAt;
  final String? supplier;
  final String? expiryDate;
  final String? notes;
}

class FeedDistribution {
  const FeedDistribution({
    required this.id,
    required this.feedId,
    this.lotId,
    this.animalId,
    required this.quantity,
    required this.distributedAt,
    this.planId,
    this.notes,
  });

  factory FeedDistribution.fromJson(Map<String, dynamic> json) {
    return FeedDistribution(
      id: json['id'] as String? ?? '',
      feedId: json['feedId'] as String? ?? '',
      lotId: json['lotId'] as String?,
      animalId: json['animalId'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      distributedAt: json['distributedAt'] as String? ?? '',
      planId: json['planId'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String feedId;
  final String? lotId;
  final String? animalId;
  final double quantity;
  final String distributedAt;
  final String? planId;
  final String? notes;
}

class FeedStock {
  const FeedStock({
    required this.feedId,
    this.feedName,
    this.unit,
    required this.quantity,
    this.averagePrice,
    this.updatedAt,
  });

  factory FeedStock.fromJson(Map<String, dynamic> json) {
    return FeedStock(
      feedId: json['feedId'] as String? ?? '',
      feedName: json['feedName'] as String?,
      unit: json['unit'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      averagePrice: (json['averagePrice'] as num?)?.toDouble(),
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String feedId;
  final String? feedName;
  final String? unit;
  final double quantity;
  final double? averagePrice;
  final String? updatedAt;
}

class LowStockAlert {
  const LowStockAlert({
    required this.feedId,
    this.feedName,
    this.unit,
    required this.quantity,
    required this.threshold,
  });

  factory LowStockAlert.fromJson(Map<String, dynamic> json) {
    return LowStockAlert(
      feedId: json['feedId'] as String? ?? '',
      feedName: json['feedName'] as String?,
      unit: json['unit'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0,
    );
  }

  final String feedId;
  final String? feedName;
  final String? unit;
  final double quantity;
  final double threshold;
}

class FeedingPlan {
  const FeedingPlan({
    required this.id,
    this.speciesId,
    required this.name,
    this.stages = const [],
    this.active = true,
  });

  factory FeedingPlan.fromJson(Map<String, dynamic> json) {
    return FeedingPlan(
      id: json['id'] as String? ?? '',
      speciesId: json['speciesId'] as String?,
      name: json['name'] as String? ?? '',
      stages: (json['stages'] as List<dynamic>? ?? const [])
          .map((value) => value as Map<String, dynamic>)
          .toList(growable: false),
      active: json['active'] as bool? ?? true,
    );
  }

  final String id;
  final String? speciesId;
  final String name;
  final List<Map<String, dynamic>> stages;
  final bool active;
}

class FeedCost {
  const FeedCost({
    required this.id,
    this.lotId,
    this.animalId,
    required this.amount,
    this.periodStart,
    this.periodEnd,
  });

  factory FeedCost.fromJson(Map<String, dynamic> json) {
    return FeedCost(
      id: json['id'] as String? ?? '',
      lotId: json['lotId'] as String?,
      animalId: json['animalId'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      periodStart: json['periodStart'] as String?,
      periodEnd: json['periodEnd'] as String?,
    );
  }

  final String id;
  final String? lotId;
  final String? animalId;
  final double amount;
  final String? periodStart;
  final String? periodEnd;
}

class FeedingRepository {
  FeedingRepository(this._dio);

  final Dio _dio;

  Future<List<Feed>> feeds({String? search, bool includeArchived = false}) async {
    final data = await _get('/feeds', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      'includeArchived': includeArchived,
    });
    return _list(data, Feed.fromJson);
  }

  Future<Feed> createFeed(Map<String, dynamic> body) async {
    final data = await _post('/feeds', body);
    return Feed.fromJson(data);
  }

  Future<List<FeedReceipt>> receipts(String feedId) async {
    final data = await _get('/feeds/$feedId/receipts');
    return _list(data, FeedReceipt.fromJson);
  }

  Future<FeedReceipt> receiveFeed(String feedId, Map<String, dynamic> body) async {
    final data = await _post('/feeds/$feedId/receipts', body);
    return FeedReceipt.fromJson(data);
  }

  Future<List<FeedDistribution>> distributions({String? feedId}) async {
    final data = await _get('/feed-distributions', query: {
      if (feedId != null && feedId.isNotEmpty) 'feedId': feedId,
    });
    return _list(data, FeedDistribution.fromJson);
  }

  Future<FeedDistribution> distribute(Map<String, dynamic> body) async {
    final data = await _post('/feed-distributions', body);
    return FeedDistribution.fromJson(data);
  }

  Future<List<FeedStock>> stocks() async {
    final data = await _get('/feed-stocks');
    return _list(data, FeedStock.fromJson);
  }

  Future<List<LowStockAlert>> lowStock({double? threshold}) async {
    final data = await _get('/feed-stocks/low', query: {
      'threshold': ?threshold,
    });
    return _list(data, LowStockAlert.fromJson);
  }

  Future<List<FeedingPlan>> feedingPlans({String? speciesId}) async {
    final data = await _get('/feeding-plans', query: {
      if (speciesId != null && speciesId.isNotEmpty) 'speciesId': speciesId,
    });
    return _list(data, FeedingPlan.fromJson);
  }

  Future<List<FeedCost>> costs() async {
    final data = await _get('/feed-costs');
    return _list(data, FeedCost.fromJson);
  }

  Future<FeedCost> computeCost(Map<String, dynamic> body) async {
    final data = await _post('/feed-costs', body);
    return FeedCost.fromJson(data);
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

final feedingRepositoryProvider = Provider<FeedingRepository>((ref) {
  return FeedingRepository(ref.watch(dioProvider));
});
