import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/features/billing/subscription_page.dart';
import 'package:rm_breeding_mobile/features/platform/platform_dashboard_page.dart';

void main() {
  testWidgets('SubscriptionPage renders active plan and options', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SubscriptionPage(),
        ),
      ),
    );

    expect(find.text('Abonnement et Quotas'), findsOneWidget);
    expect(find.text('Plan Actuel : PRO'), findsOneWidget);
    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('Professionnel'), findsOneWidget);
    expect(find.text('Entreprise'), findsOneWidget);
  });

  testWidgets('PlatformDashboardPage renders metrics and tenants', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PlatformDashboardPage(),
        ),
      ),
    );

    expect(find.text('Console Plateforme Admin'), findsOneWidget);
    expect(find.text('Exploitations'), findsOneWidget);
    expect(find.text('Animaux'), findsOneWidget);
    expect(find.text('MRR Plateforme'), findsOneWidget);
    expect(find.text('Ferme Démo'), findsOneWidget);
  });
}
