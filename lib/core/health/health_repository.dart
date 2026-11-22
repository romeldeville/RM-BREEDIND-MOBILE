import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class HealthProduct {
  const HealthProduct({
    required this.id,
    required this.name,
    this.type,
    this.dose,
    this.route,
    this.withdrawalMeatDays = 0,
    this.withdrawalEggsDays = 0,
    this.withdrawalMilkDays = 0,
    this.supplier,
    this.stockQty,
    this.archivedAt,
  });

  factory HealthProduct.fromJson(Map<String, dynamic> json) {
    return HealthProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String?,
      dose: json['dose'] as String?,
      route: json['route'] as String?,
      withdrawalMeatDays: json['withdrawalMeatDays'] as int? ?? 0,
      withdrawalEggsDays: json['withdrawalEggsDays'] as int? ?? 0,
      withdrawalMilkDays: json['withdrawalMilkDays'] as int? ?? 0,
      supplier: json['supplier'] as String?,
      stockQty: (json['stockQty'] as num?)?.toDouble(),
      archivedAt: json['archivedAt'] as String?,
    );
  }

  final String id;
  final String name;
  final String? type;
  final String? dose;
  final String? route;
  final int withdrawalMeatDays;
  final int withdrawalEggsDays;
  final int withdrawalMilkDays;
  final String? supplier;
  final double? stockQty;
  final String? archivedAt;
}

class Vaccination {
  const Vaccination({
    required this.id,
    this.animalId,
    this.lotId,
    required this.productId,
    this.planId,
    this.vaccineLot,
    this.dose,
    this.route,
    this.count = 1,
    required this.performedAt,
    this.notes,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'] as String? ?? '',
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      productId: json['productId'] as String? ?? '',
      planId: json['planId'] as String?,
      vaccineLot: json['vaccineLot'] as String?,
      dose: json['dose'] as String?,
      route: json['route'] as String?,
      count: json['count'] as int? ?? 1,
      performedAt: json['performedAt'] as String? ?? '',
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String? animalId;
  final String? lotId;
  final String productId;
  final String? planId;
  final String? vaccineLot;
  final String? dose;
  final String? route;
  final int count;
  final String performedAt;
  final String? notes;
}

class TreatmentAdministration {
  const TreatmentAdministration({
    required this.id,
    required this.treatmentId,
    required this.administeredAt,
    this.dose,
    this.actorId,
  });

  factory TreatmentAdministration.fromJson(Map<String, dynamic> json) {
    return TreatmentAdministration(
      id: json['id'] as String? ?? '',
      treatmentId: json['treatmentId'] as String? ?? '',
      administeredAt: json['administeredAt'] as String? ?? '',
      dose: json['dose'] as String?,
      actorId: json['actorId'] as String?,
    );
  }

  final String id;
  final String treatmentId;
  final String administeredAt;
  final String? dose;
  final String? actorId;
}

class Treatment {
  const Treatment({
    required this.id,
    this.animalId,
    this.lotId,
    required this.productId,
    this.diagnosis,
    this.symptoms,
    this.dose,
    this.route,
    required this.startDate,
    this.durationDays,
    this.endDate,
    this.status = 'ACTIVE',
    this.notes,
    this.withdrawalEndDate,
    this.administrations = const [],
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'] as String? ?? '',
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      productId: json['productId'] as String? ?? '',
      diagnosis: json['diagnosis'] as String?,
      symptoms: json['symptoms'] as String?,
      dose: json['dose'] as String?,
      route: json['route'] as String?,
      startDate: json['startDate'] as String? ?? '',
      durationDays: json['durationDays'] as int?,
      endDate: json['endDate'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      notes: json['notes'] as String?,
      withdrawalEndDate: json['withdrawalEndDate'] as String?,
      administrations: (json['administrations'] as List<dynamic>? ?? const [])
          .map(
            (value) =>
                TreatmentAdministration.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final String? animalId;
  final String? lotId;
  final String productId;
  final String? diagnosis;
  final String? symptoms;
  final String? dose;
  final String? route;
  final String startDate;
  final int? durationDays;
  final String? endDate;
  final String status;
  final String? notes;
  final String? withdrawalEndDate;
  final List<TreatmentAdministration> administrations;
}

class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.treatmentId,
    this.animalId,
    this.lotId,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.status = 'ACTIVE',
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'] as String? ?? '',
      treatmentId: json['treatmentId'] as String? ?? '',
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      type: json['type'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  final String id;
  final String treatmentId;
  final String? animalId;
  final String? lotId;
  final String type;
  final String startDate;
  final String endDate;
  final String status;
}

class Mortality {
  const Mortality({
    required this.id,
    this.animalId,
    this.lotId,
    this.count = 1,
    this.cause,
    required this.occurredAt,
  });

  factory Mortality.fromJson(Map<String, dynamic> json) {
    return Mortality(
      id: json['id'] as String? ?? '',
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      count: json['count'] as int? ?? 1,
      cause: json['cause'] as String?,
      occurredAt: json['occurredAt'] as String? ?? '',
    );
  }

  final String id;
  final String? animalId;
  final String? lotId;
  final int count;
  final String? cause;
  final String occurredAt;
}

class Quarantine {
  const Quarantine({
    required this.id,
    this.animalId,
    this.lotId,
    required this.startDate,
    this.endDate,
    this.reason,
    this.status = 'ACTIVE',
  });

  factory Quarantine.fromJson(Map<String, dynamic> json) {
    return Quarantine(
      id: json['id'] as String? ?? '',
      animalId: json['animalId'] as String?,
      lotId: json['lotId'] as String?,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  final String id;
  final String? animalId;
  final String? lotId;
  final String startDate;
  final String? endDate;
  final String? reason;
  final String status;
}

class SaleEligibility {
  const SaleEligibility({required this.allowed, this.blockingWithdrawals = const []});

  factory SaleEligibility.fromJson(Map<String, dynamic> json) {
    return SaleEligibility(
      allowed: json['allowed'] as bool? ?? false,
      blockingWithdrawals:
          (json['blockingWithdrawals'] as List<dynamic>? ?? const [])
              .map((value) => Withdrawal.fromJson(value as Map<String, dynamic>))
              .toList(growable: false),
    );
  }

  final bool allowed;
  final List<Withdrawal> blockingWithdrawals;
}

class HealthRepository {
  HealthRepository(this._dio);

  final Dio _dio;

  Future<List<HealthProduct>> products({
    String? search,
    bool includeArchived = false,
  }) async {
    final data = await _get('/health/products', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      'includeArchived': includeArchived,
    });
    return _list(data, HealthProduct.fromJson);
  }

  Future<HealthProduct> createProduct(Map<String, dynamic> body) async {
    final data = await _post('/health/products', body);
    return HealthProduct.fromJson(data);
  }

  Future<List<Vaccination>> vaccinations({
    String? animalId,
    String? lotId,
  }) async {
    final data = await _get('/health/vaccinations', query: {
      if (animalId != null && animalId.isNotEmpty) 'animalId': animalId,
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
    });
    return _list(data, Vaccination.fromJson);
  }

  Future<Vaccination> recordVaccination(Map<String, dynamic> body) async {
    final data = await _post('/health/vaccinations', body);
    return Vaccination.fromJson(data);
  }

  Future<List<Treatment>> treatments({
    String? status,
    String? animalId,
    String? lotId,
  }) async {
    final data = await _get('/health/treatments', query: {
      if (status != null && status.isNotEmpty) 'status': status,
      if (animalId != null && animalId.isNotEmpty) 'animalId': animalId,
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
    });
    return _list(data, Treatment.fromJson);
  }

  Future<Treatment> createTreatment(Map<String, dynamic> body) async {
    final data = await _post('/health/treatments', body);
    return Treatment.fromJson(data);
  }

  Future<TreatmentAdministration> addAdministration(
    String treatmentId,
    Map<String, dynamic> body,
  ) async {
    final data = await _post(
      '/health/treatments/$treatmentId/administrations',
      body,
    );
    return TreatmentAdministration.fromJson(data);
  }

  Future<List<Withdrawal>> withdrawals({String? status}) async {
    final data = await _get('/health/withdrawals', query: {
      if (status != null && status.isNotEmpty) 'status': status,
    });
    return _list(data, Withdrawal.fromJson);
  }

  Future<SaleEligibility> saleEligibility({
    String? animalId,
    String? lotId,
    String? type,
    String? date,
  }) async {
    final data = await _get('/health/sale-eligibility', query: {
      if (animalId != null && animalId.isNotEmpty) 'animalId': animalId,
      if (lotId != null && lotId.isNotEmpty) 'lotId': lotId,
      if (type != null && type.isNotEmpty) 'type': type,
      if (date != null && date.isNotEmpty) 'date': date,
    });
    return SaleEligibility.fromJson(data as Map<String, dynamic>? ?? const {});
  }

  Future<List<Mortality>> mortalities({String? animalId}) async {
    final data = await _get('/health/mortalities', query: {
      if (animalId != null && animalId.isNotEmpty) 'animalId': animalId,
    });
    return _list(data, Mortality.fromJson);
  }

  Future<Mortality> recordMortality(Map<String, dynamic> body) async {
    final data = await _post('/health/mortalities', body);
    return Mortality.fromJson(data);
  }

  Future<List<Quarantine>> quarantines({String? status}) async {
    final data = await _get('/health/quarantines', query: {
      if (status != null && status.isNotEmpty) 'status': status,
    });
    return _list(data, Quarantine.fromJson);
  }

  Future<Quarantine> createQuarantine(Map<String, dynamic> body) async {
    final data = await _post('/health/quarantines', body);
    return Quarantine.fromJson(data);
  }

  Future<Quarantine> releaseQuarantine(String id) async {
    final data = await _post('/health/quarantines/$id/release', const {});
    return Quarantine.fromJson(data);
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

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(ref.watch(dioProvider));
});
