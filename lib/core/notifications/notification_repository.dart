import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class NotificationPreference {
  const NotificationPreference({
    required this.type,
    required this.channel,
    required this.enabled,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      type: json['type'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  final String type;
  final String channel;
  final bool enabled;

  String get key => '$type|$channel';

  NotificationPreference copyWith({bool? enabled}) {
    return NotificationPreference(
      type: type,
      channel: channel,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'channel': channel,
        'enabled': enabled,
      };
}

class NotificationLogEntry {
  const NotificationLogEntry({
    required this.id,
    required this.channel,
    required this.type,
    required this.status,
    this.sentAt,
    this.error,
  });

  factory NotificationLogEntry.fromJson(Map<String, dynamic> json) {
    return NotificationLogEntry(
      id: json['id'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      sentAt: _parseDate(json['sentAt']),
      error: json['error'] as String?,
    );
  }

  final String id;
  final String channel;
  final String type;
  final String status;
  final DateTime? sentAt;
  final String? error;
}

class NotificationRepository {
  NotificationRepository(this._dio);

  final Dio _dio;

  Future<void> registerToken(String token, String platform) async {
    try {
      await _dio.post<dynamic>(
        '/notifications/tokens',
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<void> revokeToken(String token) async {
    try {
      await _dio.delete<dynamic>(
        '/notifications/tokens',
        queryParameters: {'token': token},
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<List<NotificationPreference>> preferences() async {
    final data = await _get('/notifications/preferences');
    return _preferences(data);
  }

  Future<List<NotificationPreference>> updatePreferences(
    List<NotificationPreference> items,
  ) async {
    try {
      final response = await _dio.put<dynamic>(
        '/notifications/preferences',
        data: {'items': items.map((item) => item.toJson()).toList()},
      );
      return _preferences(response.data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<List<NotificationLogEntry>> log() async {
    final data = await _get('/notifications/log');
    if (data is! List) {
      return const [];
    }
    return data
        .map((value) =>
            NotificationLogEntry.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  List<NotificationPreference> _preferences(dynamic data) {
    if (data is! List) {
      return const [];
    }
    return data
        .map((value) =>
            NotificationPreference.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<dynamic> _get(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      return response.data;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(dioProvider));
});
