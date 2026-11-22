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

String? dateToInstant(String value) {
  final date = normalizeDate(value);
  return date == null ? null : '${date}T12:00:00Z';
}

String shortId(String value) {
  if (value.isEmpty) {
    return '-';
  }
  return value.length <= 8 ? value : value.substring(0, 8);
}

String formatTimestamp(String? value) {
  if (value == null || value.isEmpty) {
    return '-';
  }
  return value.replaceFirst('T', ' ').replaceFirst('Z', '');
}

String formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}

Future<List<Animal>> loadAnimals(WidgetRef ref) async {
  final page = await ref.read(herdRepositoryProvider).animals(limit: 100);
  return page.items;
}

Future<List<Lot>> loadLots(WidgetRef ref) async {
  final page = await ref.read(herdRepositoryProvider).lots(limit: 100);
  return page.items;
}
