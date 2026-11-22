import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_state.dart';
import 'notification_repository.dart';
import 'push_gateway.dart';

class PushState {
  const PushState({
    this.supported = false,
    this.permission = PushPermission.unsupported,
    this.token,
    this.busy = false,
    this.error,
  });

  final bool supported;
  final PushPermission permission;
  final String? token;
  final bool busy;
  final String? error;

  bool get isEnabled => token != null;

  bool get needsPermission =>
      supported && permission != PushPermission.granted;

  PushState copyWith({
    bool? supported,
    PushPermission? permission,
    String? token,
    bool? busy,
    String? error,
    bool clearToken = false,
    bool clearError = false,
  }) {
    return PushState(
      supported: supported ?? this.supported,
      permission: permission ?? this.permission,
      token: clearToken ? null : (token ?? this.token),
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PushController extends StateNotifier<PushState> {
  PushController(this._ref, this._gateway) : super(const PushState()) {
    _subscription = _gateway.tokenRefreshes.listen((token) {
      if (token.isNotEmpty) {
        _register(token);
      }
    });
    _ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        _bootstrap();
      }
      if (!next.isAuthenticated && previous?.isAuthenticated == true) {
        state = state.copyWith(clearToken: true);
      }
    });
    ready = _bootstrap();
  }

  final Ref _ref;
  final PushGateway _gateway;
  StreamSubscription<String>? _subscription;
  late final Future<void> ready;

  Future<void> _bootstrap() async {
    if (!_gateway.supported) {
      state = state.copyWith(
        supported: false,
        permission: PushPermission.unsupported,
      );
      return;
    }
    state = state.copyWith(supported: true, clearError: true);
    try {
      final permission = await _gateway.permissionStatus();
      state = state.copyWith(permission: permission);
      if (permission == PushPermission.granted) {
        await _register();
      }
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> refresh() => _bootstrap();

  Future<void> requestPermission() async {
    if (!state.supported || state.busy) {
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      final permission = await _gateway.requestPermission();
      state = state.copyWith(permission: permission, busy: false);
      if (permission == PushPermission.granted) {
        await _register();
      }
    } catch (error) {
      state = state.copyWith(busy: false, error: error.toString());
    }
  }

  Future<void> disable() async {
    if (!state.supported || state.busy) {
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      final token = state.token ?? await _gateway.token();
      if (token != null && token.isNotEmpty) {
        await _ref.read(notificationRepositoryProvider).revokeToken(token);
      }
      await _gateway.deleteToken();
      state = state.copyWith(
        busy: false,
        clearToken: true,
        permission: PushPermission.denied,
      );
    } catch (error) {
      state = state.copyWith(busy: false, error: error.toString());
    }
  }

  Future<void> _register([String? providedToken]) async {
    if (!_ref.read(authControllerProvider).isAuthenticated) {
      return;
    }
    try {
      final token = providedToken ?? await _gateway.token();
      if (token == null || token.isEmpty) {
        return;
      }
      await _ref
          .read(notificationRepositoryProvider)
          .registerToken(token, _platform);
      state = state.copyWith(token: token, clearError: true);
    } on ApiFailure catch (failure) {
      state = state.copyWith(error: failure.message);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  String get _platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID';

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final pushGatewayProvider = Provider<PushGateway>((ref) {
  return FirebasePushGateway();
});

final pushControllerProvider =
    StateNotifierProvider<PushController, PushState>((ref) {
  return PushController(ref, ref.watch(pushGatewayProvider));
});
