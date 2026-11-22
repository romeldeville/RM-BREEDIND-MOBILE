import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class Alert {
  const Alert({
    required this.id,
    required this.farmId,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.dueDate,
    required this.status,
    this.entityType,
    this.entityId,
    this.assignedRole,
    this.postponeReason,
    this.createdAt,
    this.closedAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      priority: json['priority'] as String? ?? 'INFO',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      dueDate: json['dueDate'] as String?,
      status: json['status'] as String? ?? 'OPEN',
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      assignedRole: json['assignedRole'] as String?,
      postponeReason: json['postponeReason'] as String?,
      createdAt: json['createdAt'] as String?,
      closedAt: json['closedAt'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String type;
  final String priority;
  final String title;
  final String message;
  final String? dueDate;
  final String status;
  final String? entityType;
  final String? entityId;
  final String? assignedRole;
  final String? postponeReason;
  final String? createdAt;
  final String? closedAt;
}

class Task {
  const Task({
    required this.id,
    required this.farmId,
    required this.title,
    this.description,
    this.dueDate,
    this.assignedTo,
    this.recurrence,
    required this.status,
    this.createdAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '',
      farmId: json['farmId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dueDate: json['dueDate'] as String?,
      assignedTo: json['assignedTo'] as String?,
      recurrence: json['recurrence'] as String?,
      status: json['status'] as String? ?? 'OPEN',
      createdAt: json['createdAt'] as String?,
      completedAt: json['completedAt'] as String?,
    );
  }

  final String id;
  final String farmId;
  final String title;
  final String? description;
  final String? dueDate;
  final String? assignedTo;
  final String? recurrence;
  final String status;
  final String? createdAt;
  final String? completedAt;
}

class TodayBundle {
  const TodayBundle({this.alerts = const [], this.tasks = const []});

  factory TodayBundle.fromJson(Map<String, dynamic> json) {
    return TodayBundle(
      alerts: (json['alerts'] as List<dynamic>? ?? const [])
          .map((value) => Alert.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
      tasks: (json['tasks'] as List<dynamic>? ?? const [])
          .map((value) => Task.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final List<Alert> alerts;
  final List<Task> tasks;
}

class AlertsRepository {
  AlertsRepository(this._dio);

  final Dio _dio;

  Future<List<Alert>> alerts({
    String? status,
    String? priority,
    String? dueBefore,
  }) async {
    final data = await _get('/alerts', query: {
      if (status != null && status.isNotEmpty) 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (dueBefore != null && dueBefore.isNotEmpty) 'dueBefore': dueBefore,
    });
    return _list(data, Alert.fromJson);
  }

  Future<TodayBundle> today() async {
    final data = await _get('/alerts/today');
    return TodayBundle.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  Future<Alert> close(String alertId) async {
    final data = await _post('/alerts/$alertId/close', const {});
    return Alert.fromJson(data);
  }

  Future<Alert> postpone(
    String alertId, {
    required String dueDate,
    required String reason,
  }) async {
    final data = await _post('/alerts/$alertId/postpone', {
      'dueDate': dueDate,
      'reason': reason,
    });
    return Alert.fromJson(data);
  }

  Future<Alert> cancel(String alertId, String reason) async {
    final data = await _post('/alerts/$alertId/cancel', {'reason': reason});
    return Alert.fromJson(data);
  }

  Future<List<Task>> tasks() async {
    final data = await _get('/tasks');
    return _list(data, Task.fromJson);
  }

  Future<Task> createTask(Map<String, dynamic> body) async {
    final data = await _post('/tasks', body);
    return Task.fromJson(data);
  }

  Future<Task> completeTask(String taskId) async {
    final data = await _post('/tasks/$taskId/complete', const {});
    return Task.fromJson(data);
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

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(ref.watch(dioProvider));
});
