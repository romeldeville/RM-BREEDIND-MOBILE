import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/auth/auth_state.dart';

void main() {
  group('AuthState', () {
    test('computes initials from display name', () {
      const state = AuthState(
        isAuthenticated: true,
        displayName: 'Awa Diallo',
      );
      expect(state.initials, 'AD');
    });

    test('falls back to the email initial', () {
      const state = AuthState(
        isAuthenticated: true,
        email: 'owner@farm.test',
      );
      expect(state.initials, 'O');
    });

    test('resolves the current membership by tenant id', () {
      const state = AuthState(
        isAuthenticated: true,
        tenantId: 'tenant-2',
        memberships: [
          TenantMembership(tenantId: 'tenant-1', tenantName: 'Farm One', role: 'OWNER'),
          TenantMembership(tenantId: 'tenant-2', tenantName: 'Farm Two', role: 'WORKER'),
        ],
      );
      expect(state.currentMembership?.tenantName, 'Farm Two');
      expect(state.currentMembership?.role, 'WORKER');
    });

    test('round-trips a membership through json', () {
      const membership = TenantMembership(
        tenantId: 'tenant-1',
        tenantName: 'Farm One',
        role: 'MANAGER',
        farmScope: ['farm-1'],
      );
      final restored = TenantMembership.fromJson(membership.toJson());
      expect(restored.tenantId, 'tenant-1');
      expect(restored.role, 'MANAGER');
      expect(restored.farmScope, ['farm-1']);
    });
  });
}
