import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/health/health_repository.dart';
import 'package:rm_breeding_mobile/core/herd/herd_repository.dart';
import 'package:rm_breeding_mobile/features/health/health_page.dart';
import 'package:rm_breeding_mobile/features/health/mortality_form_page.dart';
import 'package:rm_breeding_mobile/features/health/products_page.dart';
import 'package:rm_breeding_mobile/features/health/quarantine_form_page.dart';
import 'package:rm_breeding_mobile/features/health/treatment_form_page.dart';
import 'package:rm_breeding_mobile/features/health/vaccination_form_page.dart';
import 'package:rm_breeding_mobile/features/health/withdrawals_page.dart';

class FakeHerdRepository extends HerdRepository {
  FakeHerdRepository() : super(Dio());

  static const sampleAnimal = Animal(
    id: 'animal-1',
    farmId: 'farm-1',
    speciesId: 'species-1',
    identifier: 'A-001',
    name: 'Bella',
    sex: 'FEMALE',
    status: 'ACTIVE',
  );

  static const sampleLot = Lot(
    id: 'lot-1',
    farmId: 'farm-1',
    speciesId: 'species-1',
    name: 'Bande 1',
    status: 'OPEN',
    initialCount: 10,
    currentCount: 10,
  );

  @override
  Future<AnimalPage> animals({
    String? search,
    String? status,
    String? speciesId,
    String? penId,
    String? lotId,
    int limit = 50,
    String? cursor,
  }) async {
    return const AnimalPage(items: [sampleAnimal]);
  }

  @override
  Future<LotPage> lots({
    String? status,
    String? speciesId,
    int limit = 50,
    String? cursor,
  }) async {
    return const LotPage(items: [sampleLot]);
  }
}

class FakeHealthRepository extends HealthRepository {
  FakeHealthRepository() : super(Dio());

  static const product = HealthProduct(
    id: 'product-1',
    name: 'Vaccin PPR',
    type: 'VACCINE',
    withdrawalMeatDays: 7,
    withdrawalMilkDays: 3,
    stockQty: 12,
  );

  static const vaccination = Vaccination(
    id: 'vaccination-1',
    animalId: 'animal-1',
    productId: 'product-1',
    vaccineLot: 'LOT-2026',
    performedAt: '2026-11-13T10:00:00Z',
  );

  static const treatment = Treatment(
    id: 'treatment-1',
    animalId: 'animal-1',
    productId: 'product-1',
    diagnosis: 'Mammite',
    startDate: '2026-11-10',
    durationDays: 5,
    status: 'ACTIVE',
    withdrawalEndDate: '2026-11-18',
  );

  static const withdrawal = Withdrawal(
    id: 'withdrawal-1',
    treatmentId: 'treatment-1',
    animalId: 'animal-1',
    type: 'MEAT',
    startDate: '2026-11-10',
    endDate: '2026-11-18',
    status: 'ACTIVE',
  );

  static const mortality = Mortality(
    id: 'mortality-1',
    animalId: 'animal-1',
    count: 1,
    cause: 'Maladie',
    occurredAt: '2026-11-12T10:00:00Z',
  );

  static const quarantine = Quarantine(
    id: 'quarantine-1',
    animalId: 'animal-1',
    startDate: '2026-11-01',
    endDate: '2026-11-15',
    reason: 'Suspicion',
    status: 'ACTIVE',
  );

  @override
  Future<List<HealthProduct>> products({
    String? search,
    bool includeArchived = false,
  }) async {
    return const [product];
  }

  @override
  Future<List<Vaccination>> vaccinations({
    String? animalId,
    String? lotId,
  }) async {
    return const [vaccination];
  }

  @override
  Future<List<Treatment>> treatments({
    String? status,
    String? animalId,
    String? lotId,
  }) async {
    return const [treatment];
  }

  @override
  Future<List<Withdrawal>> withdrawals({String? status}) async {
    return const [withdrawal];
  }

  @override
  Future<SaleEligibility> saleEligibility({
    String? animalId,
    String? lotId,
    String? type,
    String? date,
  }) async {
    return const SaleEligibility(
      allowed: false,
      blockingWithdrawals: [withdrawal],
    );
  }

  @override
  Future<List<Mortality>> mortalities({String? animalId}) async {
    return const [mortality];
  }

  @override
  Future<List<Quarantine>> quarantines({String? status}) async {
    return const [quarantine];
  }
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      herdRepositoryProvider.overrideWithValue(FakeHerdRepository()),
      healthRepositoryProvider.overrideWithValue(FakeHealthRepository()),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _wrapBody(Widget child) {
  return _wrap(Scaffold(body: child));
}

void main() {
  testWidgets('HealthPage renders actions and active withdrawals', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapBody(const HealthPage()));
    await tester.pumpAndSettle();

    expect(find.text('Produits'), findsOneWidget);
    expect(find.text('Vaccination'), findsOneWidget);
    expect(find.text('Traitement'), findsOneWidget);
    expect(find.text('Délais d’attente'), findsOneWidget);
    expect(find.text('Mortalité'), findsOneWidget);
    expect(find.text('Quarantaine'), findsOneWidget);
    expect(find.text('Délais d’attente actifs'), findsOneWidget);
    expect(find.text('MEAT'), findsOneWidget);
  });

  testWidgets('ProductsPage renders products and create action', (tester) async {
    await tester.pumpWidget(_wrap(const ProductsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Produits vétérinaires'), findsOneWidget);
    expect(find.text('Vaccin PPR'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('ProductsPage opens the create dialog', (tester) async {
    await tester.pumpWidget(_wrap(const ProductsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau produit'), findsOneWidget);
    expect(find.text('Nom'), findsOneWidget);
    expect(find.text('Délai viande (jours)'), findsOneWidget);
  });

  testWidgets('VaccinationFormPage renders the vaccination form', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const VaccinationFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle vaccination'), findsOneWidget);
    expect(find.text('Animal'), findsOneWidget);
    expect(find.text('Produit'), findsOneWidget);
    expect(find.text('Date de vaccination'), findsOneWidget);
    expect(find.text('N° de lot du vaccin'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Vaccinations récentes'), findsOneWidget);
  });

  testWidgets('TreatmentFormPage renders the treatment form', (tester) async {
    await tester.pumpWidget(_wrap(const TreatmentFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau traitement'), findsOneWidget);
    expect(find.text('Diagnostic'), findsOneWidget);
    expect(find.text('Symptômes'), findsOneWidget);
    expect(find.text('Durée (jours)'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Traitements en cours'), findsOneWidget);
    expect(find.text('Mammite'), findsOneWidget);
  });

  testWidgets('WithdrawalsPage renders withdrawals and eligibility check', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const WithdrawalsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Délais d’attente'), findsWidgets);
    expect(find.text('MEAT'), findsOneWidget);
    expect(find.text('Vérification vente'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Vérifier'), 300);
    await tester.tap(find.text('Vérifier'));
    await tester.pumpAndSettle();

    expect(find.text('Vente bloquée (1 délai(s))'), findsOneWidget);
  });

  testWidgets('MortalityFormPage renders the mortality form', (tester) async {
    await tester.pumpWidget(_wrap(const MortalityFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle mortalité'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Cause'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    expect(find.text('Mortalités récentes'), findsOneWidget);
  });

  testWidgets('QuarantineFormPage renders the quarantine form', (tester) async {
    await tester.pumpWidget(_wrap(const QuarantineFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle quarantaine'), findsOneWidget);
    expect(find.text('Date de début'), findsOneWidget);
    expect(find.text('Date de fin prévue'), findsOneWidget);
    expect(find.text('Motif'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    expect(find.text('Quarantaines'), findsOneWidget);
  });
}
