import 'package:flutter/material.dart';

import '../../../core/dashboard/dashboard_repository.dart';
import '../../../core/theme/app_tokens.dart';

/// Lightweight bar chart used by the dashboard (no external chart dependency).
class TrendBarChart extends StatelessWidget {
  const TrendBarChart({
    super.key,
    required this.points,
    required this.unit,
    this.emptyLabel = 'Aucune donnée',
  });

  final List<IndicatorPoint> points;
  final String unit;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Text(emptyLabel, style: const TextStyle(color: AppTokens.textMuted));
    }
    final values = points.map((point) => point.value).whereType<double>();
    final max = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final hasValues = max > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < points.length; index++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatValue(points[index].value),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          key: ValueKey('trend-bar-$index'),
                          height: hasValues
                              ? 90 * ((points[index].value ?? 0) / max)
                              : 2,
                          decoration: BoxDecoration(
                            color: AppTokens.primary,
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space2),
        Row(
          children: [
            for (final point in points)
              Expanded(
                child: Text(
                  point.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: AppTokens.textMuted),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTokens.space1),
        Text(unit, style: const TextStyle(fontSize: 12.5, color: AppTokens.textMuted)),
      ],
    );
  }

  String _formatValue(double? value) {
    if (value == null) {
      return '—';
    }
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}
