import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class Customer {
  const Customer({
    required this.id,
    required this.farmId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.balance,
    this.archivedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      archivedAt: json['archivedAt'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final double balance;
  final String? archivedAt;
}

class SaleLine {
  const SaleLine({
    required this.id,
    required this.itemType,
    this.animalId,
    this.lotId,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory SaleLine.fromJson(Map<String, dynamic> json) {
    return SaleLine(
      id: json['id'] as String? ?? '',
      itemType: json['itemType'] as String? ?? '',
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  final String id;
  final String itemType;
  final String? animalId;
  final String? lotId;
  final String? description;
  final double quantity;
  final double unitPrice;
  final double amount;
}

class Sale {
  const Sale({
    required this.id,
    required this.farmId,
    this.customerId,
    required this.number,
    required this.type,
    required this.status,
    required this.soldAt,
    required this.totalAmount,
    required this.currency,
    required this.paymentStatus,
    this.notes,
    this.cancellationDeadline,
    this.lines = const [],
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      customerId: json['customerId'] as String?,
      number: json['number'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      soldAt: json['soldAt'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      paymentStatus: json['paymentStatus'] as String? ?? 'UNPAID',
      notes: json['notes'] as String?,
      cancellationDeadline: json['cancellationDeadline'] as String?,
      lines: (json['lines'] as List<dynamic>? ?? const [])
          .map((value) => SaleLine.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final String id;
  final String farmId;
  final String? customerId;
  final String number;
  final String type;
  final String status;
  final String soldAt;
  final double totalAmount;
  final String currency;
  final String paymentStatus;
  final String? notes;
  final String? cancellationDeadline;
  final List<SaleLine> lines;
}

class Payment {
  const Payment({
    required this.id,
    required this.saleId,
    required this.amount,
    required this.method,
    required this.status,
    required this.paidAt,
    this.reference,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String? ?? '',
      saleId: json['saleId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: json['method'] as String? ?? '',
      status: json['status'] as String? ?? '',
      paidAt: json['paidAt'] as String? ?? '',
      reference: json['reference'] as String?,
    );
  }

  final String id;
  final String saleId;
  final double amount;
  final String method;
  final String status;
  final String paidAt;
  final String? reference;
}

class SalesRepository {
  SalesRepository(this._dio);

  final Dio _dio;

  Future<List<Customer>> customers({bool includeArchived = false}) async {
    final data = await _get('/customers', query: {
      'includeArchived': includeArchived,
    });
    return _list(data, Customer.fromJson);
  }

  Future<Customer> createCustomer(Map<String, dynamic> body) async {
    final data = await _post('/customers', body);
    return Customer.fromJson(data);
  }

  Future<List<Sale>> sales({String? status}) async {
    final data = await _get('/sales', query: {
      if (status != null && status.isNotEmpty) 'status': status,
    });
    return _list(data, Sale.fromJson);
  }

  Future<Sale> sale(String saleId) async {
    final data = await _get('/sales/$saleId');
    return Sale.fromJson(data as Map<String, dynamic>);
  }

  Future<Sale> createSale(Map<String, dynamic> body) async {
    final data = await _post('/sales', body);
    return Sale.fromJson(data);
  }

  Future<Sale> cancelSale(String saleId, String reason) async {
    final data = await _post('/sales/$saleId/cancel', {'reason': reason});
    return Sale.fromJson(data);
  }

  Future<List<Payment>> payments(String saleId) async {
    final data = await _get('/sales/$saleId/payments');
    return _list(data, Payment.fromJson);
  }

  Future<Payment> addPayment(String saleId, Map<String, dynamic> body) async {
    final data = await _post('/sales/$saleId/payments', body);
    return Payment.fromJson(data);
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

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(dioProvider));
});
