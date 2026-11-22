import 'package:flutter/material.dart';

import '../../core/alerts/alerts_repository.dart';
import '../../core/theme/app_tokens.dart';

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

String formatDate(String? value) {
  if (value == null || value.isEmpty) {
    return '-';
  }
  return value.replaceFirst('T', ' ').replaceFirst('Z', '');
}

String priorityLabel(String priority) {
  switch (priority) {
    case 'CRITICAL':
      return 'Critique';
    case 'IMPORTANT':
      return 'Importante';
    default:
      return 'Information';
  }
}

Color priorityColor(String priority) {
  switch (priority) {
    case 'CRITICAL':
      return AppTokens.danger;
    case 'IMPORTANT':
      return AppTokens.warning;
    default:
      return AppTokens.info;
  }
}

String alertStatusLabel(String status) {
  switch (status) {
    case 'POSTPONED':
      return 'Reportée';
    case 'CLOSED':
      return 'Clôturée';
    case 'CANCELLED':
      return 'Annulée';
    default:
      return 'Ouverte';
  }
}

bool isAlertOpen(Alert alert) =>
    alert.status == 'OPEN' || alert.status == 'POSTPONED';

String taskStatusLabel(String status) {
  switch (status) {
    case 'COMPLETED':
      return 'Terminée';
    case 'CANCELLED':
      return 'Annulée';
    default:
      return 'Ouverte';
  }
}
