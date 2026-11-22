import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class Expense {
  const Expense({
    required this.id,
    required this.farmId,
    required this.category,
    required this.amount,
    required this.currency,
    required this.incurredAt,
    this.description,
    this.supplier,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      incurredAt: json['incurredAt'] as String? ?? '',
      description: json['description'] as String?,
      supplier: json['supplier'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String category;
  final double amount;
  final String currency;
  final String incurredAt;
  final String? description;
  final String? supplier;
}

class Revenue {
  const Revenue({
    required this.id,
    required this.farmId,
    required this.category,
    required this.amount,
    required this.currency,
    required this.receivedAt,
    this.description,
  });

  factory Revenue.fromJson(Map<String, dynamic> json) {
    return Revenue(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      receivedAt: json['receivedAt'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String category;
  final double amount;
  final String currency;
  final String receivedAt;
  final String? description;
}

class LotCost {
  const LotCost({
    required this.lotId,
    required this.feedCost,
    required this.allocatedCost,
    required this.totalCost,
  });

  factory LotCost.fromJson(Map<String, dynamic> json) {
    return LotCost(
      lotId: json['lotId'] as String? ?? '',
      feedCost: (json['feedCost'] as num?)?.toDouble() ?? 0,
      allocatedCost: (json['allocatedCost'] as num?)?.toDouble() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
    );
  }

  final String lotId;
  final double feedCost;
  final double allocatedCost;
  final double totalCost;
}

class LotMargin {
  const LotMargin({
    required this.lotId,
    required this.revenue,
    required this.cost,
    required this.margin,
    this.marginRate,
  });

  factory LotMargin.fromJson(Map<String, dynamic> json) {
    return LotMargin(
      lotId: json['lotId'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      margin: (json['margin'] as num?)?.toDouble() ?? 0,
      marginRate: (json['marginRate'] as num?)?.toDouble(),
    );
  }

  final String lotId;
  final double revenue;
  final double cost;
  final double margin;
  final double? marginRate;
}

class FinanceRepository {
  FinanceRepository(this._dio);

  final Dio _dio;

  Future<List<Expense>> expenses() async {
    final data = await _get('/expenses');
    return _list(data, Expense.fromJson);
  }

  Future<Expense> createExpense(Map<String, dynamic> body) async {
    final data = await _post('/expenses', body);
    return Expense.fromJson(data);
  }

  Future<List<Revenue>> revenues() async {
    final data = await _get('/revenues');
    return _list(data, Revenue.fromJson);
  }

  Future<Revenue> createRevenue(Map<String, dynamic> body) async {
    final data = await _post('/revenues', body);
    return Revenue.fromJson(data);
  }

  Future<LotCost> lotCost(String lotId) async {
    final data = await _get('/lots/$lotId/cost');
    return LotCost.fromJson(data as Map<String, dynamic>);
  }

  Future<LotMargin> lotMargin(String lotId) async {
    final data = await _get('/lots/$lotId/margin');
    return LotMargin.fromJson(data as Map<String, dynamic>);
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

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref.watch(dioProvider));
});
