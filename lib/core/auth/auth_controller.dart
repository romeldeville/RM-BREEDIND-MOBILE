import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restore();
    return const AuthState.unauthenticated();
  }

  Future<void> _restore() async {
    final restored = await ref.read(authRepositoryProvider).restore();
    if (restored.isAuthenticated) {
      state = restored;
    }
  }

  Future<void> login({
    required String email,
    required String password,
    String? tenantSlug,
  }) async {
    final result = await ref.read(authRepositoryProvider).login(
          email: email,
          password: password,
          tenantSlug: tenantSlug,
        );
    state = _fromResult(result);
  }

  Future<void> verifyMfa({
    required String challengeId,
    required String code,
  }) async {
    final result = await ref.read(authRepositoryProvider).verifyMfa(
          challengeId: challengeId,
          code: code,
        );
    state = _fromResult(result);
  }

  Future<void> requestOtp(String destination) =>
      ref.read(authRepositoryProvider).requestOtp(destination: destination);

  Future<void> verifyOtp({
    required String destination,
    required String code,
  }) async {
    final result = await ref.read(authRepositoryProvider).verifyOtp(
          destination: destination,
          code: code,
        );
    state = _fromResult(result);
  }

  Future<void> switchTenant(String tenantId) async {
    final result = await ref.read(authRepositoryProvider).switchTenant(tenantId);
    state = _fromResult(result);
  }

  Future<void> loginDemo() async {
    final repository = ref.read(authRepositoryProvider);
    const result = LoginResult(
      accessToken: 'demo-token',
      tenantId: AppConfig.defaultTenantId,
      email: 'demo@rmbreeding.local',
      displayName: 'Demo Éleveur',
      memberships: [
        TenantMembership(
          tenantId: AppConfig.defaultTenantId,
          tenantName: 'Ferme Démo',
          role: 'OWNER',
        ),
      ],
    );
    await repository.persistDemo(result);
    state = _fromResult(result);
  }

  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? locale,
  }) async {
    final updated = await ref.read(authRepositoryProvider).updateProfile(
          fullName: fullName,
          phone: phone,
          locale: locale,
        );
    state = state.copyWith(
      displayName: updated['fullName'] as String? ?? fullName,
      phone: updated['phone'] as String? ?? phone,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState.unauthenticated();
  }

  AuthState _fromResult(LoginResult result) {
    return AuthState(
      isAuthenticated: true,
      accessToken: result.accessToken,
      tenantId: result.tenantId,
      email: result.email,
      phone: result.phone,
      displayName: result.displayName,
      platformAdmin: result.platformAdmin,
      memberships: result.memberships,
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
