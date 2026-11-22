import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class Species {
  const Species({
    required this.id,
    required this.name,
    required this.code,
    required this.productionType,
    required this.trackingMode,
    this.gestationDays,
    this.heatCycleDays,
    this.weaningAgeDays,
    this.incubationDays,
    this.settings = const {},
    this.archivedAt,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      productionType: json['productionType'] as String? ?? 'MIXED',
      trackingMode: json['trackingMode'] as String? ?? 'INDIVIDUAL',
      gestationDays: json['gestationDays'] as int?,
      heatCycleDays: json['heatCycleDays'] as int?,
      weaningAgeDays: json['weaningAgeDays'] as int?,
      incubationDays: json['incubationDays'] as int?,
      settings: (json['settings'] as Map<String, dynamic>?) ?? const {},
      archivedAt: json['archivedAt'] as String?,
    );
  }

  final String id;
  final String name;
  final String code;
  final String productionType;
  final String trackingMode;
  final int? gestationDays;
  final int? heatCycleDays;
  final int? weaningAgeDays;
  final int? incubationDays;
  final Map<String, dynamic> settings;
  final String? archivedAt;
}

class SpeciesTemplate {
  const SpeciesTemplate({
    required this.id,
    required this.speciesId,
    required this.name,
  });

  factory SpeciesTemplate.fromJson(Map<String, dynamic> json) {
    return SpeciesTemplate(
      id: json['id'] as String? ?? '',
      speciesId: json['speciesId'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  final String id;
  final String speciesId;
  final String name;
}

class Breed {
  const Breed({
    required this.id,
    required this.speciesId,
    required this.name,
    this.code,
    this.archivedAt,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      id: json['id'] as String? ?? '',
      speciesId: json['speciesId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      archivedAt: json['archivedAt'] as String?,
    );
  }

  final String id;
  final String speciesId;
  final String name;
  final String? code;
  final String? archivedAt;
}

class VaccinationPlan {
  const VaccinationPlan({
    required this.id,
    required this.speciesId,
    required this.name,
    this.ageDays,
    this.boosterDays,
    this.active = true,
  });

  factory VaccinationPlan.fromJson(Map<String, dynamic> json) {
    return VaccinationPlan(
      id: json['id'] as String? ?? '',
      speciesId: json['speciesId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      ageDays: json['ageDays'] as int?,
      boosterDays: json['boosterDays'] as int?,
      active: json['active'] as bool? ?? true,
    );
  }

  final String id;
  final String speciesId;
  final String name;
  final int? ageDays;
  final int? boosterDays;
  final bool active;
}

class FeedingPlan {
  const FeedingPlan({
    required this.id,
    required this.speciesId,
    required this.name,
    this.stageCount = 0,
    this.active = true,
  });

  factory FeedingPlan.fromJson(Map<String, dynamic> json) {
    return FeedingPlan(
      id: json['id'] as String? ?? '',
      speciesId: json['speciesId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      stageCount: (json['stages'] as List<dynamic>? ?? const []).length,
      active: json['active'] as bool? ?? true,
    );
  }

  final String id;
  final String speciesId;
  final String name;
  final int stageCount;
  final bool active;
}

class Farm {
  const Farm({required this.id, required this.name, this.code = ''});

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String code;
}

class Building {
  const Building({
    required this.id,
    required this.farmId,
    required this.name,
    this.code,
    this.type,
    this.archivedAt,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      type: json['type'] as String?,
      archivedAt: json['archivedAt'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String name;
  final String? code;
  final String? type;
  final String? archivedAt;
}

class Pen {
  const Pen({
    required this.id,
    required this.farmId,
    required this.buildingId,
    required this.name,
    this.code,
    this.type,
    this.capacity = 0,
    this.archivedAt,
  });

  factory Pen.fromJson(Map<String, dynamic> json) {
    return Pen(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      buildingId: json['buildingId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String?,
      type: json['type'] as String?,
      capacity: json['capacity'] as int? ?? 0,
      archivedAt: json['archivedAt'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String buildingId;
  final String name;
  final String? code;
  final String? type;
  final int capacity;
  final String? archivedAt;
}

class PenOccupancy {
  const PenOccupancy({
    required this.penId,
    required this.capacity,
    required this.occupied,
  });

  factory PenOccupancy.fromJson(Map<String, dynamic> json) {
    return PenOccupancy(
      penId: json['penId'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      occupied: json['occupied'] as int? ?? 0,
    );
  }

  final String penId;
  final int capacity;
  final int occupied;
}

class ReferentialRepository {
  ReferentialRepository(this._dio);

  final Dio _dio;

  Future<List<Species>> species({bool includeArchived = false}) async {
    final data = await _get('/species', query: {'includeArchived': includeArchived});
    return (data as List<dynamic>)
        .map((value) => Species.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Species> speciesById(String id) async {
    final data = await _get('/species/$id');
    return Species.fromJson(data as Map<String, dynamic>);
  }

  Future<Species> createSpecies(Map<String, dynamic> body) async {
    final data = await _post('/species', body);
    return Species.fromJson(data);
  }

  Future<Species> patchSpecies(String id, Map<String, dynamic> body) async {
    final data = await _patch('/species/$id', body);
    return Species.fromJson(data);
  }

  Future<void> archiveSpecies(String id) async {
    await _delete('/species/$id');
  }

  Future<List<SpeciesTemplate>> templates(String speciesId) async {
    final data = await _get('/species/$speciesId/templates');
    return (data as List<dynamic>)
        .map((value) => SpeciesTemplate.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<SpeciesTemplate> createTemplate(
    String speciesId,
    Map<String, dynamic> body,
  ) async {
    final data = await _post('/species/$speciesId/templates', body);
    return SpeciesTemplate.fromJson(data);
  }

  Future<void> deleteTemplate(String templateId) async {
    await _delete('/species/templates/$templateId');
  }

  Future<List<Breed>> breeds(String speciesId) async {
    final data = await _get('/species/$speciesId/breeds');
    return (data as List<dynamic>)
        .map((value) => Breed.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Breed> createBreed(String speciesId, Map<String, dynamic> body) async {
    final data = await _post('/species/$speciesId/breeds', body);
    return Breed.fromJson(data);
  }

  Future<void> archiveBreed(String breedId) async {
    await _delete('/species/breeds/$breedId');
  }

  Future<List<VaccinationPlan>> vaccinationPlans(String speciesId) async {
    final data = await _get('/species/$speciesId/vaccination-plans');
    return (data as List<dynamic>)
        .map((value) => VaccinationPlan.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<VaccinationPlan> createVaccinationPlan(
    String speciesId,
    Map<String, dynamic> body,
  ) async {
    final data = await _post('/species/$speciesId/vaccination-plans', body);
    return VaccinationPlan.fromJson(data);
  }

  Future<void> deleteVaccinationPlan(String planId) async {
    await _delete('/species/vaccination-plans/$planId');
  }

  Future<List<FeedingPlan>> feedingPlans(String speciesId) async {
    final data = await _get('/species/$speciesId/feeding-plans');
    return (data as List<dynamic>)
        .map((value) => FeedingPlan.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<FeedingPlan> createFeedingPlan(
    String speciesId,
    Map<String, dynamic> body,
  ) async {
    final data = await _post('/species/$speciesId/feeding-plans', body);
    return FeedingPlan.fromJson(data);
  }

  Future<void> deleteFeedingPlan(String planId) async {
    await _delete('/species/feeding-plans/$planId');
  }

  Future<List<Farm>> farms() async {
    final data = await _get('/farms');
    return (data as List<dynamic>)
        .map((value) => Farm.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<Building>> buildings(String farmId) async {
    final data = await _get('/buildings', query: {'farmId': farmId});
    return (data as List<dynamic>)
        .map((value) => Building.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Building> createBuilding(Map<String, dynamic> body) async {
    final data = await _post('/buildings', body);
    return Building.fromJson(data);
  }

  Future<void> archiveBuilding(String buildingId) async {
    await _delete('/buildings/$buildingId');
  }

  Future<List<Pen>> pens(String buildingId) async {
    final data = await _get('/pens', query: {'buildingId': buildingId});
    return (data as List<dynamic>)
        .map((value) => Pen.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Pen> createPen(Map<String, dynamic> body) async {
    final data = await _post('/pens', body);
    return Pen.fromJson(data);
  }

  Future<void> archivePen(String penId) async {
    await _delete('/pens/$penId');
  }

  Future<PenOccupancy> occupancy(String penId) async {
    final data = await _get('/pens/$penId/occupancy');
    return PenOccupancy.fromJson(data as Map<String, dynamic>);
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

  Future<void> _delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

final referentialRepositoryProvider = Provider<ReferentialRepository>((ref) {
  return ReferentialRepository(ref.watch(dioProvider));
});
