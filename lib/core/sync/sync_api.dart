import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';
import 'sync_models.dart';

class SyncApi {
  SyncApi(this._dio);

  final Dio _dio;

  Future<PushResult> push({
    required String deviceId,
    required int clientCursor,
    required List<PushEventPayload> events,
  }) async {
    final data = await _post('/sync/push', {
      'deviceId': deviceId,
      'clientCursor': clientCursor,
      'events': events.map((event) => event.toJson()).toList(growable: false),
    });
    return PushResult.fromJson(data);
  }

  Future<PullResult> pull({
    required int since,
    required String deviceId,
    int limit = 200,
  }) async {
    final data = await _get('/sync/pull', query: {
      'since': since,
      'limit': limit,
      'deviceId': deviceId,
    });
    return PullResult.fromJson(data);
  }

  Future<SyncStatus> status(String deviceId) async {
    final data = await _get('/sync/status', query: {'deviceId': deviceId});
    return SyncStatus.fromJson(data);
  }

  Future<List<SyncConflict>> conflicts({bool includeResolved = false}) async {
    final data = await _getList('/sync/conflicts', query: {
      'includeResolved': includeResolved,
    });
    return data
        .whereType<Map<String, dynamic>>()
        .map(SyncConflict.fromJson)
        .toList(growable: false);
  }

  Future<SyncConflict> resolve(
    String conflictId,
    String resolution, {
    Map<String, dynamic>? payload,
  }) async {
    final data = await _post('/sync/conflicts/$conflictId/resolve', {
      'resolution': resolution,
      'payload': ?payload,
    });
    return SyncConflict.fromJson(data);
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return (response.data as Map<String, dynamic>?) ?? const {};
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<List<dynamic>> _getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      final data = response.data;
      return data is List ? data : const [];
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

final syncApiProvider = Provider<SyncApi>((ref) {
  return SyncApi(ref.watch(dioProvider));
});
