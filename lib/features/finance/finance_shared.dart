import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/herd/herd_repository.dart';

String todayDate() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

String? normalizeDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) {
    return null;
  }
  return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
}

String shortId(String value) {
  if (value.isEmpty) {
    return '-';
  }
  return value.length <= 8 ? value : value.substring(0, 8);
}

String formatAmount(double value, [String currency = 'XOF']) {
  final rounded = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  return '$rounded $currency';
}

Future<List<Lot>> loadLots(WidgetRef ref) async {
  final page = await ref.read(herdRepositoryProvider).lots(limit: 100);
  return page.items;
}
