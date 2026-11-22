import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../herd/herd_repository.dart';
import '../network/dio_client.dart';

class ReproductionCycle {
  const ReproductionCycle({
    required this.id,
    required this.farmId,
    required this.femaleId,
    required this.status,
    required this.parity,
    required this.startDate,
    this.endDate,
    this.expectedBirthDate,
    this.expectedDiagnosisDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ReproductionCycle.fromJson(Map<String, dynamic> json) {
    return ReproductionCycle(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      femaleId: json['femaleId'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      parity: json['parity'] as int? ?? 0,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String?,
      expectedBirthDate: json['expectedBirthDate'] as String?,
      expectedDiagnosisDate: json['expectedDiagnosisDate'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String femaleId;
  final String status;
  final int parity;
  final String startDate;
  final String? endDate;
  final String? expectedBirthDate;
  final String? expectedDiagnosisDate;
  final String? createdAt;
  final String? updatedAt;
}

class CyclePage {
  const CyclePage({required this.items, this.nextCursor, this.hasMore = false});

  factory CyclePage.fromJson(Map<String, dynamic> json) {
    return CyclePage(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map(
            (value) =>
                ReproductionCycle.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  final List<ReproductionCycle> items;
  final String? nextCursor;
  final bool hasMore;
}

class Heat {
  const Heat({
    required this.id,
    required this.cycleId,
    required this.animalId,
    required this.observedAt,
    this.intensity,
    this.nextExpectedAt,
    this.notes,
  });

  factory Heat.fromJson(Map<String, dynamic> json) {
    return Heat(
      id: json['id'] as String? ?? '',
      cycleId: json['cycleId'] as String? ?? '',
      animalId: json['animalId'] as String? ?? '',
      observedAt: json['observedAt'] as String? ?? '',
      intensity: json['intensity'] as String?,
      nextExpectedAt: json['nextExpectedAt'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String cycleId;
  final String animalId;
  final String observedAt;
  final String? intensity;
  final String? nextExpectedAt;
  final String? notes;
}

class Mating {
  const Mating({
    required this.id,
    required this.cycleId,
    required this.femaleId,
    required this.matedAt,
    this.maleId,
    this.semenCode,
    this.method,
    this.expectedBirthDate,
    this.expectedDiagnosisDate,
    this.notes,
  });

  factory Mating.fromJson(Map<String, dynamic> json) {
    return Mating(
      id: json['id'] as String? ?? '',
      cycleId: json['cycleId'] as String? ?? '',
      femaleId: json['femaleId'] as String? ?? '',
      maleId: json['maleId'] as String?,
      semenCode: json['semenCode'] as String?,
      method: json['method'] as String?,
      matedAt: json['matedAt'] as String? ?? '',
      expectedBirthDate: json['expectedBirthDate'] as String?,
      expectedDiagnosisDate: json['expectedDiagnosisDate'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String cycleId;
  final String femaleId;
  final String? maleId;
  final String? semenCode;
  final String? method;
  final String matedAt;
  final String? expectedBirthDate;
  final String? expectedDiagnosisDate;
  final String? notes;
}

class PregnancyDiagnosis {
  const PregnancyDiagnosis({
    required this.id,
    required this.cycleId,
    required this.diagnosedAt,
    required this.result,
    this.nextDiagnosisAt,
    this.notes,
  });

  factory PregnancyDiagnosis.fromJson(Map<String, dynamic> json) {
    return PregnancyDiagnosis(
      id: json['id'] as String? ?? '',
      cycleId: json['cycleId'] as String? ?? '',
      diagnosedAt: json['diagnosedAt'] as String? ?? '',
      result: json['result'] as String? ?? '',
      nextDiagnosisAt: json['nextDiagnosisAt'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String cycleId;
  final String diagnosedAt;
  final String result;
  final String? nextDiagnosisAt;
  final String? notes;
}

class Abortion {
  const Abortion({
    required this.id,
    required this.cycleId,
    required this.occurredAt,
    this.stage,
    this.suspectedCause,
  });

  factory Abortion.fromJson(Map<String, dynamic> json) {
    return Abortion(
      id: json['id'] as String? ?? '',
      cycleId: json['cycleId'] as String? ?? '',
      occurredAt: json['occurredAt'] as String? ?? '',
      stage: json['stage'] as String?,
      suspectedCause: json['suspectedCause'] as String?,
    );
  }

  final String id;
  final String cycleId;
  final String occurredAt;
  final String? stage;
  final String? suspectedCause;
}

class Birth {
  const Birth({
    required this.id,
    required this.cycleId,
    required this.femaleId,
    required this.occurredAt,
    required this.bornAlive,
    required this.stillborn,
    required this.mummified,
    required this.assistance,
    this.litterWeight,
    this.complications,
    this.litterId,
  });

  factory Birth.fromJson(Map<String, dynamic> json) {
    return Birth(
      id: json['id'] as String? ?? '',
      cycleId: json['cycleId'] as String? ?? '',
      femaleId: json['femaleId'] as String? ?? '',
      occurredAt: json['occurredAt'] as String? ?? '',
      bornAlive: json['bornAlive'] as int? ?? 0,
      stillborn: json['stillborn'] as int? ?? 0,
      mummified: json['mummified'] as int? ?? 0,
      litterWeight: (json['litterWeight'] as num?)?.toDouble(),
      assistance: json['assistance'] as bool? ?? false,
      complications: json['complications'] as String?,
      litterId: json['litterId'] as String?,
    );
  }

  final String id;
  final String cycleId;
  final String femaleId;
  final String occurredAt;
  final int bornAlive;
  final int stillborn;
  final int mummified;
  final double? litterWeight;
  final bool assistance;
  final String? complications;
  final String? litterId;
}

class BirthCreation {
  const BirthCreation({
    required this.birth,
    required this.litterId,
    required this.retroactiveMatingSuggested,
    this.suggestedMatingDate,
  });

  factory BirthCreation.fromJson(Map<String, dynamic> json) {
    return BirthCreation(
      birth: Birth.fromJson(json['birth'] as Map<String, dynamic>? ?? const {}),
      litterId: json['litterId'] as String? ?? '',
      retroactiveMatingSuggested:
          json['retroactiveMatingSuggested'] as bool? ?? false,
      suggestedMatingDate: json['suggestedMatingDate'] as String?,
    );
  }

  final Birth birth;
  final String litterId;
  final bool retroactiveMatingSuggested;
  final String? suggestedMatingDate;
}

class Weaning {
  const Weaning({
    required this.id,
    required this.litterId,
    required this.weanedAt,
    required this.count,
    this.averageWeight,
  });

  factory Weaning.fromJson(Map<String, dynamic> json) {
    return Weaning(
      id: json['id'] as String? ?? '',
      litterId: json['litterId'] as String? ?? '',
      weanedAt: json['weanedAt'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      averageWeight: (json['averageWeight'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String litterId;
  final String weanedAt;
  final int count;
  final double? averageWeight;
}

class Litter {
  const Litter({
    required this.id,
    required this.birthId,
    required this.name,
    required this.bornAlive,
    this.lotId,
    this.weanedCount,
    this.weaningDate,
    this.weanings = const [],
  });

  factory Litter.fromJson(Map<String, dynamic> json) {
    return Litter(
      id: json['id'] as String? ?? '',
      birthId: json['birthId'] as String? ?? '',
      lotId: json['lotId'] as String?,
      name: json['name'] as String? ?? '',
      bornAlive: json['bornAlive'] as int? ?? 0,
      weanedCount: json['weanedCount'] as int?,
      weaningDate: json['weaningDate'] as String?,
      weanings: (json['weanings'] as List<dynamic>? ?? const [])
          .map((value) => Weaning.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final String id;
  final String birthId;
  final String? lotId;
  final String name;
  final int bornAlive;
  final int? weanedCount;
  final String? weaningDate;
  final List<Weaning> weanings;
}

class CycleDetail {
  const CycleDetail({
    required this.cycle,
    this.heats = const [],
    this.matings = const [],
    this.diagnoses = const [],
    this.abortions = const [],
    this.births = const [],
    this.litters = const [],
  });

  factory CycleDetail.fromJson(Map<String, dynamic> json) {
    return CycleDetail(
      cycle: ReproductionCycle.fromJson(
        json['cycle'] as Map<String, dynamic>? ?? const {},
      ),
      heats: (json['heats'] as List<dynamic>? ?? const [])
          .map((value) => Heat.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
      matings: (json['matings'] as List<dynamic>? ?? const [])
          .map((value) => Mating.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
      diagnoses: (json['diagnoses'] as List<dynamic>? ?? const [])
          .map(
            (value) =>
                PregnancyDiagnosis.fromJson(value as Map<String, dynamic>),
          )
          .toList(growable: false),
      abortions: (json['abortions'] as List<dynamic>? ?? const [])
          .map((value) => Abortion.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
      births: (json['births'] as List<dynamic>? ?? const [])
          .map((value) => Birth.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
      litters: (json['litters'] as List<dynamic>? ?? const [])
          .map((value) => Litter.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final ReproductionCycle cycle;
  final List<Heat> heats;
  final List<Mating> matings;
  final List<PregnancyDiagnosis> diagnoses;
  final List<Abortion> abortions;
  final List<Birth> births;
  final List<Litter> litters;
}

class ReproductionRepository {
  ReproductionRepository(this._dio);

  final Dio _dio;

  Future<CyclePage> cycles({
    String? femaleId,
    String? status,
    int limit = 50,
    String? cursor,
  }) async {
    final data = await _get(
      '/reproduction/cycles',
      query: {
        if (femaleId != null && femaleId.isNotEmpty) 'femaleId': femaleId,
        if (status != null && status.isNotEmpty) 'status': status,
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
    return CyclePage.fromJson(data as Map<String, dynamic>);
  }

  Future<ReproductionCycle> createCycle(Map<String, dynamic> body) async {
    final data = await _post('/reproduction/cycles', body);
    return ReproductionCycle.fromJson(data);
  }

  Future<CycleDetail> cycle(String id) async {
    final data = await _get('/reproduction/cycles/$id');
    return CycleDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<Heat> recordHeat(Map<String, dynamic> body) async {
    final data = await _post('/reproduction/heats', body);
    return Heat.fromJson(data);
  }

  Future<Mating> recordMating(Map<String, dynamic> body) async {
    final data = await _post('/reproduction/services', body);
    return Mating.fromJson(data);
  }

  Future<PregnancyDiagnosis> recordDiagnosis(Map<String, dynamic> body) async {
    final data = await _post('/reproduction/diagnoses', body);
    return PregnancyDiagnosis.fromJson(data);
  }

  Future<Abortion> recordAbortion(Map<String, dynamic> body) async {
    final data = await _post('/reproduction/abortions', body);
    return Abortion.fromJson(data);
  }

  Future<BirthCreation> recordBirth(Map<String, dynamic> body) async {
    final data = await _post('/reproduction/farrowings', body);
    return BirthCreation.fromJson(data);
  }

  Future<Weaning> recordWeaning(Map<String, dynamic> body) async {
    final data = await _post('/reproduction/weanings', body);
    return Weaning.fromJson(data);
  }

  Future<Lot> createLotFromLitter(
    String litterId,
    Map<String, dynamic> body,
  ) async {
    final data = await _post('/reproduction/litters/$litterId/lot', body);
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
}

final reproductionRepositoryProvider = Provider<ReproductionRepository>((ref) {
  return ReproductionRepository(ref.watch(dioProvider));
});
