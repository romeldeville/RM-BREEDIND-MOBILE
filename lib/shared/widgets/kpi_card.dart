import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.icon,
  });

  final String label;
  final String value;
  final String? unit;
  final int? trend;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final trendColor = trend == null || trend == 0
        ? AppTokens.textMuted
        : trend! > 0
            ? AppTokens.success
            : AppTokens.danger;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: AppTokens.textMuted),
                  const SizedBox(width: AppTokens.space2),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 15, color: AppTokens.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 2),
                  Text(unit!, style: const TextStyle(color: AppTokens.textMuted, fontSize: 15)),
                ],
              ],
            ),
            if (trend != null) ...[
              const SizedBox(height: AppTokens.space1),
              Text(
                '${trend! > 0 ? '+' : ''}$trend%',
                style: TextStyle(fontSize: 14, color: trendColor, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
