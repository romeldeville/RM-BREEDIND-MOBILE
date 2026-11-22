import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/db/app_database.dart';
import '../../core/sync/sync_api.dart';
import '../../core/sync/sync_controller.dart';
import '../../core/sync/sync_models.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/section_card.dart';

/// Explicit conflict resolution screen. The server never silently overwrites a
/// divergent headcount or stock: the user decides which value wins.
class ConflictsPage extends ConsumerStatefulWidget {
  const ConflictsPage({super.key});

  @override
  ConsumerState<ConflictsPage> createState() => _ConflictsPageState();
}

class _ConflictsPageState extends ConsumerState<ConflictsPage> {
  bool _loading = true;
  String? _error;
  String? _resolvingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshFromServer());
  }

  Future<void> _refreshFromServer() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final conflicts =
          await ref.read(syncApiProvider).conflicts(includeResolved: false);
      final dao = ref.read(conflictDaoProvider);
      for (final conflict in conflicts) {
        await dao.upsertFromServer(conflict.toJson());
      }
      await ref.read(syncControllerProvider.notifier).refresh();
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Serveur injoignable : ${error.message} '
              'Les conflits déjà reçus restent affichés.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resolve(
    LocalConflict conflict,
    String resolution,
    String label,
  ) async {
    setState(() {
      _resolvingId = conflict.id;
      _error = null;
    });
    try {
      final resolved =
          await ref.read(syncApiProvider).resolve(conflict.id, resolution);
      await ref.read(conflictDaoProvider).upsertFromServer(resolved.toJson());
      await ref.read(syncControllerProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conflit résolu : $label.')),
        );
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _resolvingId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conflicts = ref.watch(localConflictsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflits de synchronisation'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _loading ? null : _refreshFromServer,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFromServer,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: AppTokens.danger),
              ),
              const SizedBox(height: AppTokens.space3),
            ],
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppTokens.space8),
                child: Center(child: CircularProgressIndicator()),
              ),
            conflicts.when(
              loading: () => const SizedBox.shrink(),
              error: (error, _) => Text(
                error.toString(),
                style: const TextStyle(color: AppTokens.danger),
              ),
              data: (items) {
                final open =
                    items.where((item) => item.resolvedAt == null).toList();
                final resolved =
                    items.where((item) => item.resolvedAt != null).toList();
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: AppTokens.space8),
                    child: EmptyState(
                      message: 'Aucun conflit : les données sont alignées.',
                      icon: Icons.verified_outlined,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (open.isNotEmpty) ...[
                      const Text(
                        'À résoudre',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTokens.space2),
                      for (final conflict in open)
                        _ConflictCard(
                          conflict: conflict,
                          resolving: _resolvingId == conflict.id,
                          onResolve: (resolution, label) =>
                              _resolve(conflict, resolution, label),
                        ),
                      const SizedBox(height: AppTokens.space4),
                    ],
                    if (resolved.isNotEmpty) ...[
                      const Text(
                        'Historique',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTokens.space2),
                      for (final conflict in resolved)
                        _ConflictCard(
                          conflict: conflict,
                          resolving: false,
                          onResolve: null,
                        ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({
    required this.conflict,
    required this.resolving,
    required this.onResolve,
  });

  final LocalConflict conflict;
  final bool resolving;
  final void Function(String resolution, String label)? onResolve;

  @override
  Widget build(BuildContext context) {
    final payload = decodePayload(conflict.payload);
    final expected = payload['expected'];
    final actual = payload['actual'];
    final resolved = conflict.resolvedAt != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space3),
      child: SectionCard(
        title: _entityLabel(conflict.entityType),
        trailing: resolved
            ? Chip(
                label: Text(_resolutionLabel(conflict.resolution)),
                visualDensity: VisualDensity.compact,
              )
            : const Chip(
                label: Text('Ouvert'),
                visualDensity: VisualDensity.compact,
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_reasonLabel(conflict.reason)),
            const SizedBox(height: AppTokens.space2),
            if (expected != null || actual != null)
              Text(
                'Mobile : ${_value(expected)}   •   Serveur : ${_value(actual)}',
                style: const TextStyle(color: AppTokens.textMuted),
              ),
            const SizedBox(height: AppTokens.space1),
            Text(
              'Élément ${_shortId(conflict.entityId)} — '
              '${_formatDate(conflict.createdAt)}',
              style: const TextStyle(color: AppTokens.textMuted, fontSize: 14),
            ),
            if (!resolved && onResolve != null) ...[
              const SizedBox(height: AppTokens.space3),
              Wrap(
                spacing: AppTokens.space2,
                runSpacing: AppTokens.space2,
                children: [
                  FilledButton(
                    onPressed: resolving
                        ? null
                        : () => onResolve!('CLIENT_WINS', 'garder le mobile'),
                    child: const Text('Garder le mobile'),
                  ),
                  OutlinedButton(
                    onPressed: resolving
                        ? null
                        : () => onResolve!('SERVER_WINS', 'garder le serveur'),
                    child: const Text('Garder le serveur'),
                  ),
                  OutlinedButton(
                    onPressed: resolving
                        ? null
                        : () => onResolve!('MERGED', 'fusionner'),
                    child: const Text('Fusionner'),
                  ),
                ],
              ),
              if (resolving) ...[
                const SizedBox(height: AppTokens.space2),
                const LinearProgressIndicator(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static String _entityLabel(String type) {
    return switch (type) {
      'lot' => 'Lot',
      'animal' => 'Animal',
      'feed_stock' => 'Stock d’aliment',
      'alert' => 'Alerte',
      _ when type.isNotEmpty => type,
      _ => 'Élément',
    };
  }

  static String _reasonLabel(String reason) {
    return switch (reason) {
      'HEADCOUNT_MISMATCH' =>
        'L’effectif saisi sur le mobile ne correspond plus à celui du serveur.',
      'STOCK_MISMATCH' =>
        'Le stock saisi sur le mobile ne correspond plus à celui du serveur.',
      _ when reason.isNotEmpty => reason,
      _ => 'Des valeurs divergentes ont été détectées pendant la synchronisation.',
    };
  }

  static String _resolutionLabel(String? resolution) {
    return switch (resolution) {
      'CLIENT_WINS' => 'Mobile retenu',
      'SERVER_WINS' => 'Serveur retenu',
      'MERGED' => 'Fusionné',
      _ => 'Résolu',
    };
  }

  static String _value(Object? value) {
    if (value == null) {
      return '—';
    }
    return value.toString();
  }

  static String _shortId(String id) {
    if (id.isEmpty) {
      return '—';
    }
    return id.length <= 8 ? id : id.substring(0, 8);
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}
