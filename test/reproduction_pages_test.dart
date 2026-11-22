import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/herd/herd_repository.dart';
import 'package:rm_breeding_mobile/core/reproduction/reproduction_repository.dart';
import 'package:rm_breeding_mobile/features/reproduction/birth_form_page.dart';
import 'package:rm_breeding_mobile/features/reproduction/cycle_detail_page.dart';
import 'package:rm_breeding_mobile/features/reproduction/diagnosis_form_page.dart';
import 'package:rm_breeding_mobile/features/reproduction/heat_form_page.dart';
import 'package:rm_breeding_mobile/features/reproduction/mating_form_page.dart';
import 'package:rm_breeding_mobile/features/reproduction/reproduction_page.dart';
import 'package:rm_breeding_mobile/features/reproduction/weaning_form_page.dart';

class FakeHerdRepository extends HerdRepository {
  FakeHerdRepository() : super(Dio());

  static const female = Animal(
    id: 'animal-1',
    farmId: 'farm-1',
    speciesId: 'species-1',
    identifier: 'A-001',
    name: 'Bella',
    sex: 'FEMALE',
    status: 'ACTIVE',
  );

  static const male = Animal(
    id: 'animal-2',
    farmId: 'farm-1',
    speciesId: 'species-1',
    identifier: 'M-001',
    name: 'Taureau',
    sex: 'MALE',
    status: 'ACTIVE',
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
    return const AnimalPage(items: [female, male]);
  }
}

class FakeReproductionRepository extends ReproductionRepository {
  FakeReproductionRepository() : super(Dio());

  static const cycleSample = ReproductionCycle(
    id: 'cycle-1',
    farmId: 'farm-1',
    femaleId: 'animal-1',
    status: 'PREGNANT',
    parity: 2,
    startDate: '2026-01-10',
    expectedDiagnosisDate: '2026-02-14',
    expectedBirthDate: '2026-10-17',
  );

  static const heat = Heat(
    id: 'heat-1',
    cycleId: 'cycle-1',
    animalId: 'animal-1',
    observedAt: '2026-01-10T10:00:00Z',
    intensity: 'HIGH',
    nextExpectedAt: '2026-01-31',
  );

  static const mating = Mating(
    id: 'mating-1',
    cycleId: 'cycle-1',
    femaleId: 'animal-1',
    maleId: 'animal-2',
    method: 'NATURAL',
    matedAt: '2026-01-12T10:00:00Z',
    expectedBirthDate: '2026-10-19',
    expectedDiagnosisDate: '2026-02-16',
  );

  static const diagnosis = PregnancyDiagnosis(
    id: 'diagnosis-1',
    cycleId: 'cycle-1',
    diagnosedAt: '2026-02-14T10:00:00Z',
    result: 'POSITIVE',
  );

  static const birth = Birth(
    id: 'birth-1',
    cycleId: 'cycle-1',
    femaleId: 'animal-1',
    occurredAt: '2026-10-17T10:00:00Z',
    bornAlive: 2,
    stillborn: 0,
    mummified: 0,
    assistance: false,
    litterId: 'litter-1',
  );

  static const weaning = Weaning(
    id: 'weaning-1',
    litterId: 'litter-1',
    weanedAt: '2026-12-01T10:00:00Z',
    count: 2,
    averageWeight: 24,
  );

  static const litter = Litter(
    id: 'litter-1',
    birthId: 'birth-1',
    name: 'Portée 2026-10-17',
    bornAlive: 2,
    weanedCount: 2,
    weaningDate: '2026-12-01',
    weanings: [weaning],
  );

  static const detail = CycleDetail(
    cycle: cycleSample,
    heats: [heat],
    matings: [mating],
    diagnoses: [diagnosis],
    births: [birth],
    litters: [litter],
  );

  @override
  Future<CyclePage> cycles({
    String? femaleId,
    String? status,
    int limit = 50,
    String? cursor,
  }) async {
    return const CyclePage(items: [cycleSample]);
  }

  @override
  Future<ReproductionCycle> createCycle(Map<String, dynamic> body) async =>
      cycleSample;

  @override
  Future<CycleDetail> cycle(String id) async => detail;

  @override
  Future<Heat> recordHeat(Map<String, dynamic> body) async => heat;

  @override
  Future<Mating> recordMating(Map<String, dynamic> body) async => mating;

  @override
  Future<PregnancyDiagnosis> recordDiagnosis(Map<String, dynamic> body) async =>
      diagnosis;

  @override
  Future<BirthCreation> recordBirth(Map<String, dynamic> body) async {
    return const BirthCreation(
      birth: birth,
      litterId: 'litter-1',
      retroactiveMatingSuggested: true,
      suggestedMatingDate: '2026-04-15',
    );
  }

  @override
  Future<Weaning> recordWeaning(Map<String, dynamic> body) async => weaning;

  @override
  Future<Lot> createLotFromLitter(
    String litterId,
    Map<String, dynamic> body,
  ) async {
    return const Lot(
      id: 'lot-1',
      farmId: 'farm-1',
      speciesId: 'species-1',
      name: 'Portée 2026-10-17',
      status: 'OPEN',
      initialCount: 2,
      currentCount: 2,
    );
  }
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      herdRepositoryProvider.overrideWithValue(FakeHerdRepository()),
      reproductionRepositoryProvider.overrideWithValue(
        FakeReproductionRepository(),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _wrapBody(Widget child) {
  return _wrap(Scaffold(body: child));
}

void main() {
  testWidgets('ReproductionPage renders cycles and actions', (tester) async {
    await tester.pumpWidget(_wrapBody(const ReproductionPage()));
    await tester.pumpAndSettle();

    expect(find.text('Cycles de reproduction'), findsOneWidget);
    expect(find.text('A-001 - Bella - PREGNANT'), findsOneWidget);
    expect(find.text('Nouveau cycle'), findsOneWidget);
    expect(find.text('Chaleurs'), findsOneWidget);
    expect(find.text('Saillie'), findsOneWidget);
    expect(find.text('Diagnostic'), findsOneWidget);
    expect(find.text('Mise bas'), findsOneWidget);
    expect(find.text('Sevrage'), findsOneWidget);
  });

  testWidgets('HeatFormPage renders the heat form', (tester) async {
    await tester.pumpWidget(_wrap(const HeatFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Chaleurs'), findsOneWidget);
    expect(find.text('Détection des chaleurs'), findsOneWidget);
    expect(find.text('Femelle'), findsOneWidget);
    expect(find.text("Date d'observation"), findsOneWidget);
    expect(find.text('Intensité'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets('MatingFormPage renders the mating form', (tester) async {
    await tester.pumpWidget(_wrap(const MatingFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Saillie'), findsOneWidget);
    expect(find.text('Saillie ou insémination'), findsOneWidget);
    expect(find.text('Femelle'), findsOneWidget);
    expect(find.text('Mâle'), findsOneWidget);
    expect(find.text('Méthode'), findsOneWidget);
    expect(find.text('Date de saillie'), findsOneWidget);
    expect(find.text('Code semence'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets('DiagnosisFormPage renders the diagnosis form', (tester) async {
    await tester.pumpWidget(_wrap(const DiagnosisFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Diagnostic de gestation'), findsOneWidget);
    expect(find.text('Cycle'), findsOneWidget);
    expect(find.text('Date du diagnostic'), findsOneWidget);
    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets('BirthFormPage renders the birth form', (tester) async {
    await tester.pumpWidget(_wrap(const BirthFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Mise bas'), findsWidgets);
    expect(find.text('Date de mise bas'), findsOneWidget);
    expect(find.text('Nés vivants'), findsOneWidget);
    expect(find.text('Mort-nés'), findsOneWidget);
    expect(find.text('Momifiés'), findsOneWidget);
    expect(find.text('Assistance à la mise bas'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets('WeaningFormPage renders the weaning form', (tester) async {
    await tester.pumpWidget(_wrap(const WeaningFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Sevrage'), findsOneWidget);
    expect(find.text('Sevrage de la portée'), findsOneWidget);
    expect(find.text('Cycle'), findsOneWidget);
    expect(find.text('Portée'), findsOneWidget);
    expect(find.text('Date de sevrage'), findsOneWidget);
    expect(find.text('Nombre sevré'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets('CycleDetailPage renders the cycle and litter actions', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CycleDetailPage(cycleId: 'cycle-1')));
    await tester.pumpAndSettle();

    expect(find.text('Cycle de reproduction'), findsOneWidget);
    expect(find.text('Cycle'), findsOneWidget);
    expect(find.text('A-001 - Bella'), findsOneWidget);
    expect(find.text('PREGNANT'), findsOneWidget);
    expect(find.text('Chaleurs'), findsWidgets);

    await tester.scrollUntilVisible(find.text('Portées'), 300);
    expect(find.text('Portées'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Créer un lot'), 300);
    expect(find.text('Sevrage'), findsWidgets);
    expect(find.text('Créer un lot'), findsOneWidget);
  });

  testWidgets('CycleDetailPage opens the lot creation dialog', (tester) async {
    await tester.pumpWidget(_wrap(const CycleDetailPage(cycleId: 'cycle-1')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Créer un lot'), 300);
    await tester.ensureVisible(find.text('Créer un lot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer un lot'));
    await tester.pumpAndSettle();

    expect(find.text('Créer un lot depuis la portée'), findsOneWidget);
    expect(find.text('Nom du lot'), findsOneWidget);
    expect(find.text('Production'), findsOneWidget);
  });
}
