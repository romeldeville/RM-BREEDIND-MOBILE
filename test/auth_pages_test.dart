import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/auth/auth_controller.dart';
import 'package:rm_breeding_mobile/core/auth/auth_state.dart';
import 'package:rm_breeding_mobile/features/auth/otp_page.dart';
import 'package:rm_breeding_mobile/features/invitations/invitation_page.dart';
import 'package:rm_breeding_mobile/features/tenant/select_tenant_page.dart';

class _FakeAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState(
      isAuthenticated: true,
      tenantId: 'tenant-1',
      displayName: 'Demo éleveur',
      memberships: [
        TenantMembership(
          tenantId: 'tenant-1',
          tenantName: 'Ferme Démo',
          role: 'OWNER',
        ),
        TenantMembership(
          tenantId: 'tenant-2',
          tenantName: 'Ferme Nord',
          role: 'WORKER',
        ),
      ],
    );
  }
}

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: child),
  );
}

void main() {
  group('OtpPage', () {
    testWidgets('renders the MFA challenge form', (tester) async {
      await tester.pumpWidget(
        _wrap(const OtpPage(challengeId: 'challenge-1')),
      );
      expect(find.text('Vérification en deux étapes'), findsOneWidget);
      expect(find.text('Code à 6 chiffres'), findsOneWidget);
      expect(find.text('E-mail ou téléphone'), findsNothing);
    });

    testWidgets('renders the email OTP request form', (tester) async {
      await tester.pumpWidget(
        _wrap(const OtpPage(destination: 'owner@farm.test')),
      );
      expect(find.text('Connexion par code'), findsOneWidget);
      expect(find.text('Envoyer le code'), findsOneWidget);
      expect(find.text('Code à 6 chiffres'), findsNothing);
    });
  });

  group('SelectTenantPage', () {
    testWidgets('lists memberships and marks the active tenant', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith(_FakeAuthController.new),
          ],
          child: const MaterialApp(home: SelectTenantPage()),
        ),
      );

      expect(find.text('Choisir une exploitation'), findsOneWidget);
      expect(find.text('Ferme Démo'), findsOneWidget);
      expect(find.text('Ferme Nord'), findsOneWidget);
      expect(find.text('OWNER'), findsOneWidget);
      expect(find.text('WORKER'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Basculer'), findsOneWidget);
    });
  });

  group('InvitationPage', () {
    testWidgets('shows an error without token', (tester) async {
      await tester.pumpWidget(_wrap(const InvitationPage()));
      expect(
        find.text('Lien d’invitation invalide ou incomplet.'),
        findsOneWidget,
      );
    });

    testWidgets('renders the acceptance form with a token', (tester) async {
      await tester.pumpWidget(_wrap(const InvitationPage(token: 'token-1')));
      expect(find.text('Nom complet'), findsOneWidget);
      expect(find.text('Accepter l’invitation'), findsOneWidget);
    });
  });
}
