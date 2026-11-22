import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../alerts/alerts_repository.dart';
import '../auth/auth_repository.dart';
import '../network/dio_client.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.herdSize,
    required this.openAlerts,
    required this.birthsThisMonth,
    this.averageDailyGain,
    this.grossMargin,
    this.criticalAlerts = const [],
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      herdSize: (json['herdSize'] as num?)?.toInt() ?? 0,
      openAlerts: (json['openAlerts'] as num?)?.toInt() ?? 0,
      birthsThisMonth: (json['birthsThisMonth'] as num?)?.toInt() ?? 0,
      averageDailyGain: (json['averageDailyGain'] as num?)?.toDouble(),
      grossMargin: (json['grossMargin'] as num?)?.toDouble(),
      criticalAlerts: (json['criticalAlerts'] as List<dynamic>? ?? const [])
          .map((value) => Alert.fromJson(value as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final int herdSize;
  final int openAlerts;
  final int birthsThisMonth;
  final double? averageDailyGain;
  final double? grossMargin;
  final List<Alert> criticalAlerts;
}

class IndicatorValue {
  const IndicatorValue({
    required this.code,
    required this.label,
    required this.unit,
    this.value,
    this.periodStart,
    this.periodEnd,
  });

  factory IndicatorValue.fromJson(Map<String, dynamic> json) {
    return IndicatorValue(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble(),
      periodStart: json['periodStart'] as String?,
      periodEnd: json['periodEnd'] as String?,
    );
  }

  final String code;
  final String label;
  final String unit;
  final double? value;
  final String? periodStart;
  final String? periodEnd;
}

class IndicatorPoint {
  const IndicatorPoint({required this.label, required this.value});

  final String label;
  final double? value;
}

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<DashboardSummary> dashboard() async {
    final data = await _get('/dashboard');
    return DashboardSummary.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  Future<List<IndicatorValue>> indicators({
    String? from,
    String? to,
  }) async {
    final data = await _get('/indicators', query: {
      if (from != null && from.isNotEmpty) 'from': from,
      if (to != null && to.isNotEmpty) 'to': to,
    });
    if (data is! List) {
      return const [];
    }
    return data
        .map((value) => IndicatorValue.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<IndicatorValue> indicator(String code, {String? from, String? to}) async {
    final data = await _get('/indicators/$code', query: {
      if (from != null && from.isNotEmpty) 'from': from,
      if (to != null && to.isNotEmpty) 'to': to,
    });
    return IndicatorValue.fromJson((data as Map<String, dynamic>?) ?? const {});
  }

  /// Monthly values for [code], oldest first, ending with the current month.
  Future<List<IndicatorPoint>> indicatorSeries(String code, {int months = 6}) async {
    final now = DateTime.now();
    final points = <IndicatorPoint>[];
    for (var offset = months - 1; offset >= 0; offset--) {
      final start = DateTime(now.year, now.month - offset, 1);
      final end = DateTime(start.year, start.month + 1, 0);
      final value = await indicator(
        code,
        from: _date(start),
        to: _date(end),
      );
      points.add(IndicatorPoint(label: monthLabel(start.month), value: value.value));
    }
    return points;
  }

  String _date(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return response.data;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }
}

const _monthLabels = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

String monthLabel(int month) => _monthLabels[month - 1];

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(dioProvider));
});
