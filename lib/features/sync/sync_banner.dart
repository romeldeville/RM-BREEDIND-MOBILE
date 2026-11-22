import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/sync/sync_controller.dart';
import '../../core/theme/app_tokens.dart';

/// Compact banner displayed above the page content. It surfaces offline mode,
/// pending local writes and unsolved synchronization conflicts, and links to
/// the conflict screen when an explicit decision is required.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncControllerProvider);
    if (state.online && !state.hasBacklog) {
      return const SizedBox.shrink();
    }

    final Color color;
    final IconData icon;
    final String message;
    if (!state.online) {
      color = AppTokens.warning;
      icon = Icons.cloud_off_outlined;
      message = 'Hors ligne — les saisies restent sur l’appareil.';
    } else if (state.conflicts > 0) {
      color = AppTokens.danger;
      icon = Icons.sync_problem_outlined;
      message =
          '${state.conflicts} conflit(s) de synchronisation à résoudre.';
    } else {
      color = AppTokens.info;
      icon = Icons.cloud_upload_outlined;
      message = '${state.pending} modification(s) en attente d’envoi.';
    }

    final actionable = state.conflicts > 0;
    return Material(
      color: color.withValues(alpha: 0.12),
      child: InkWell(
        onTap: actionable ? () => context.go('/sync/conflicts') : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space4,
            vertical: AppTokens.space2,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppTokens.space2),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
              ),
              if (actionable)
                Icon(Icons.chevron_right, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
