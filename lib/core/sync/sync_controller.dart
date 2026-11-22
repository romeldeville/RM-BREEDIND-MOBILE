import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_repository.dart';
import '../db/app_database.dart';
import 'local_mutation_service.dart';
import 'sync_api.dart';
import 'sync_engine.dart';

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    outboxDao: ref.watch(outboxDaoProvider),
    syncStateDao: ref.watch(syncStateDaoProvider),
    localDataDao: ref.watch(localDataDaoProvider),
    conflictDao: ref.watch(conflictDaoProvider),
    api: ref.watch(syncApiProvider),
  );
});

final localMutationServiceProvider = Provider<LocalMutationService>((ref) {
  return LocalMutationService(
    ref.watch(outboxDaoProvider),
    ref.watch(localDataDaoProvider),
  );
});

class SyncUiState {
  const SyncUiState({
    this.syncing = false,
    this.online = true,
    this.lastSyncAt,
    this.pending = 0,
    this.conflicts = 0,
    this.error,
    this.lastReport,
  });

  final bool syncing;
  final bool online;
  final DateTime? lastSyncAt;
  final int pending;
  final int conflicts;
  final String? error;
  final SyncReport? lastReport;

  bool get hasBacklog => pending > 0 || conflicts > 0;

  SyncUiState copyWith({
    bool? syncing,
    bool? online,
    DateTime? lastSyncAt,
    int? pending,
    int? conflicts,
    String? error,
    SyncReport? lastReport,
    bool clearError = false,
  }) {
    return SyncUiState(
      syncing: syncing ?? this.syncing,
      online: online ?? this.online,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      pending: pending ?? this.pending,
      conflicts: conflicts ?? this.conflicts,
      error: clearError ? null : (error ?? this.error),
      lastReport: lastReport ?? this.lastReport,
    );
  }
}

class SyncController extends StateNotifier<SyncUiState> {
  SyncController(this._ref) : super(const SyncUiState()) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    try {
      final pending = await _ref.read(outboxDaoProvider).pendingCount();
      final conflicts = await _ref.read(conflictDaoProvider).pendingCount();
      final persisted = await _ref.read(syncStateDaoProvider).ensure();
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        pending: pending,
        conflicts: conflicts,
        lastSyncAt: persisted.lastSyncAt,
        online: persisted.status == 'OFFLINE' ? false : state.online,
      );
    } catch (_) {
      // The database may not be ready yet; the next refresh will retry.
    }
  }

  Future<SyncReport?> syncNow() async {
    if (state.syncing) {
      return null;
    }
    state = state.copyWith(syncing: true, clearError: true);
    try {
      final report = await _ref.read(syncEngineProvider).syncNow();
      if (!mounted) {
        return report;
      }
      state = state.copyWith(
        syncing: false,
        online: true,
        lastSyncAt: DateTime.now(),
        pending: report.pending,
        lastReport: report,
        clearError: true,
      );
      await _refreshConflictCount();
      return report;
    } on ApiFailure catch (error) {
      if (mounted) {
        state = state.copyWith(
          syncing: false,
          online: false,
          error: error.message,
        );
      }
      return null;
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          syncing: false,
          error: error.toString(),
        );
      }
      return null;
    }
  }

  void setOnline(bool online) {
    if (state.online == online) {
      return;
    }
    state = state.copyWith(online: online, clearError: online);
    if (online) {
      syncNow();
    }
  }

  Future<void> _refreshConflictCount() async {
    final conflicts = await _ref.read(conflictDaoProvider).pendingCount();
    final pending = await _ref.read(outboxDaoProvider).pendingCount();
    if (mounted) {
      state = state.copyWith(conflicts: conflicts, pending: pending);
    }
  }
}

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncUiState>((ref) {
  return SyncController(ref);
});

/// Reacts to connectivity changes and triggers a sync as soon as the device is
/// back online. Created once by the application widget.
final connectivitySyncProvider = Provider<void>((ref) {
  final connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? subscription;

  void handle(List<ConnectivityResult> results) {
    final online = results.any((result) => result != ConnectivityResult.none);
    final authenticated = ref.read(authControllerProvider).isAuthenticated;
    ref.read(syncControllerProvider.notifier).setOnline(online);
    if (online && authenticated) {
      ref.read(syncControllerProvider.notifier).syncNow();
    }
  }

  Future<void> detect() async {
    try {
      handle(await connectivity.checkConnectivity());
    } catch (_) {
      // Connectivity is unavailable (desktop or test environment); keep the
      // optimistic online state and let a manual sync report the truth.
    }
  }

  detect();
  try {
    subscription = connectivity.onConnectivityChanged.listen(handle, onError: (_) {});
  } catch (_) {
    // Ignore missing platform implementation.
  }
  ref.onDispose(() => subscription?.cancel());
});
