import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/auth/auth_controller.dart';
import 'package:rm_breeding_mobile/core/auth/auth_state.dart';
import 'package:rm_breeding_mobile/core/notifications/notification_repository.dart';
import 'package:rm_breeding_mobile/core/notifications/push_controller.dart';
import 'package:rm_breeding_mobile/core/notifications/push_gateway.dart';

class _AuthenticatedAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      isAuthenticated: true,
      tenantId: 'tenant-1',
      displayName: 'Demo Éleveur',
      memberships: [
        TenantMembership(
          tenantId: 'tenant-1',
          tenantName: 'Ferme Démo',
          role: 'OWNER',
        ),
      ],
    );
  }
}

class _FakePushGateway implements PushGateway {
  _FakePushGateway({
    this.supported = true,
    this.permission = PushPermission.granted,
    this.tokenValue = 'device-token',
  });

  @override
  bool supported;

  PushPermission permission;
  String? tokenValue;
  bool deleted = false;
  int permissionRequests = 0;
  final StreamController<String> refreshes =
      StreamController<String>.broadcast();

  @override
  Future<PushPermission> permissionStatus() async => permission;

  @override
  Future<PushPermission> requestPermission() async {
    permissionRequests++;
    permission = PushPermission.granted;
    return permission;
  }

  @override
  Future<String?> token() async => tokenValue;

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;

  @override
  Future<void> deleteToken() async {
    deleted = true;
  }
}

class _FakeNotificationRepository extends NotificationRepository {
  _FakeNotificationRepository() : super(Dio());

  final List<String> registered = [];
  final List<String> revoked = [];

  @override
  Future<void> registerToken(String token, String platform) async {
    registered.add('$token|$platform');
  }

  @override
  Future<void> revokeToken(String token) async {
    revoked.add(token);
  }
}

ProviderContainer _container(
  _FakePushGateway gateway,
  _FakeNotificationRepository repository,
) {
  final container = ProviderContainer(
    overrides: [
      authControllerProvider.overrideWith(_AuthenticatedAuthController.new),
      pushGatewayProvider.overrideWithValue(gateway),
      notificationRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('registers the device token when permission is granted', () async {
    final gateway = _FakePushGateway(tokenValue: 'device-token');
    addTearDown(gateway.refreshes.close);
    final repository = _FakeNotificationRepository();
    final container = _container(gateway, repository);

    final controller = container.read(pushControllerProvider.notifier);
    await controller.ready;

    final state = container.read(pushControllerProvider);
    expect(state.supported, isTrue);
    expect(state.permission, PushPermission.granted);
    expect(state.token, 'device-token');
    expect(state.isEnabled, isTrue);
    expect(repository.registered, ['device-token|ANDROID']);
  });

  test('does not register when permission was denied', () async {
    final gateway = _FakePushGateway(permission: PushPermission.denied);
    addTearDown(gateway.refreshes.close);
    final repository = _FakeNotificationRepository();
    final container = _container(gateway, repository);

    await container.read(pushControllerProvider.notifier).ready;

    final state = container.read(pushControllerProvider);
    expect(state.permission, PushPermission.denied);
    expect(state.token, isNull);
    expect(repository.registered, isEmpty);
  });

  test('waits for permission before registering', () async {
    final gateway = _FakePushGateway(permission: PushPermission.notDetermined);
    addTearDown(gateway.refreshes.close);
    final repository = _FakeNotificationRepository();
    final container = _container(gateway, repository);

    final controller = container.read(pushControllerProvider.notifier);
    await controller.ready;
    expect(repository.registered, isEmpty);

    await controller.requestPermission();

    expect(gateway.permissionRequests, 1);
    expect(container.read(pushControllerProvider).token, 'device-token');
    expect(repository.registered, ['device-token|ANDROID']);
  });

  test('reports unsupported devices without touching the provider', () async {
    final gateway = _FakePushGateway(supported: false);
    addTearDown(gateway.refreshes.close);
    final repository = _FakeNotificationRepository();
    final container = _container(gateway, repository);

    final controller = container.read(pushControllerProvider.notifier);
    await controller.ready;
    await controller.requestPermission();

    final state = container.read(pushControllerProvider);
    expect(state.supported, isFalse);
    expect(state.permission, PushPermission.unsupported);
    expect(state.needsPermission, isFalse);
    expect(gateway.permissionRequests, 0);
    expect(repository.registered, isEmpty);
  });

  test('disable revokes the token and unregisters the device', () async {
    final gateway = _FakePushGateway();
    addTearDown(gateway.refreshes.close);
    final repository = _FakeNotificationRepository();
    final container = _container(gateway, repository);

    final controller = container.read(pushControllerProvider.notifier);
    await controller.ready;
    expect(container.read(pushControllerProvider).isEnabled, isTrue);

    await controller.disable();

    final state = container.read(pushControllerProvider);
    expect(repository.revoked, ['device-token']);
    expect(gateway.deleted, isTrue);
    expect(state.token, isNull);
    expect(state.isEnabled, isFalse);
    expect(state.permission, PushPermission.denied);
  });

  test('registers a refreshed token pushed by the provider', () async {
    final gateway = _FakePushGateway();
    addTearDown(gateway.refreshes.close);
    final repository = _FakeNotificationRepository();
    final container = _container(gateway, repository);

    final controller = container.read(pushControllerProvider.notifier);
    await controller.ready;

    gateway.refreshes.add('refreshed-token');
    await Future<void>.delayed(Duration.zero);

    expect(repository.registered, contains('refreshed-token|ANDROID'));
    expect(container.read(pushControllerProvider).token, 'refreshed-token');
  });
}
