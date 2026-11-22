import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/herd/herd_repository.dart';
import 'package:rm_breeding_mobile/core/referential/referential_repository.dart';
import 'package:rm_breeding_mobile/features/herd/animal_detail_page.dart';
import 'package:rm_breeding_mobile/features/herd/animal_form_page.dart';
import 'package:rm_breeding_mobile/features/herd/animal_status_page.dart';
import 'package:rm_breeding_mobile/features/herd/herd_page.dart';
import 'package:rm_breeding_mobile/features/herd/lot_close_page.dart';
import 'package:rm_breeding_mobile/features/herd/lot_detail_page.dart';
import 'package:rm_breeding_mobile/features/herd/lot_form_page.dart';
import 'package:rm_breeding_mobile/features/herd/lot_movements_page.dart';
import 'package:rm_breeding_mobile/features/herd/lots_page.dart';

class FakeReferentialRepository extends ReferentialRepository {
  FakeReferentialRepository() : super(Dio());

  @override
  Future<List<Species>> species({bool includeArchived = false}) async {
    return const [
      Species(
        id: 'species-1',
        name: 'Bovin',
        code: 'bovin',
        productionType: 'MILK',
        trackingMode: 'INDIVIDUAL',
      ),
    ];
  }

  @override
  Future<List<Breed>> breeds(String speciesId) async {
    return const [
      Breed(id: 'breed-1', speciesId: 'species-1', name: 'Holstein'),
    ];
  }

  @override
  Future<List<Farm>> farms() async {
    return const [Farm(id: 'farm-1', name: 'Ferme test')];
  }
}

class FakeHerdRepository extends HerdRepository {
  FakeHerdRepository() : super(Dio());

  static const animalSample = Animal(
    id: 'animal-1',
    farmId: 'farm-1',
    speciesId: 'species-1',
    breedId: 'breed-1',
    identifier: 'A-001',
    name: 'Bella',
    sex: 'FEMALE',
    birthDate: '2025-01-15',
    origin: 'NAISSANCE',
    status: 'ACTIVE',
    motherId: 'animal-2',
    weightKg: 420,
    createdAt: '2026-01-01T10:00:00Z',
    updatedAt: '2026-01-02T10:00:00Z',
  );

  static const motherSample = Animal(
    id: 'animal-2',
    farmId: 'farm-1',
    speciesId: 'species-1',
    identifier: 'M-001',
    sex: 'FEMALE',
    status: 'ACTIVE',
  );

  static const lotSample = Lot(
    id: 'lot-1',
    farmId: 'farm-1',
    speciesId: 'species-1',
    name: 'Bandes 2026',
    code: 'B26',
    productionType: 'MEAT',
    status: 'OPEN',
    entryDate: '2026-02-01',
    initialCount: 10,
    currentCount: 7,
    origin: 'CREATED',
    unitCost: 12.5,
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
    return const AnimalPage(items: [animalSample, motherSample]);
  }

  @override
  Future<Animal> animal(String id) async =>
      id == 'animal-2' ? motherSample : animalSample;

  @override
  Future<List<AnimalStatusEntry>> statusHistory(String id) async {
    return const [
      AnimalStatusEntry(
        id: 'history-1',
        animalId: 'animal-1',
        status: 'ACTIVE',
        changedAt: '2026-01-01T10:00:00Z',
        reason: 'Initial status',
      ),
    ];
  }

  @override
  Future<AnimalStatusEntry> changeStatus(
    String id,
    Map<String, dynamic> body,
  ) async {
    return AnimalStatusEntry(
      id: 'history-2',
      animalId: id,
      status: body['status'] as String? ?? 'ACTIVE',
      changedAt: '2026-01-02T10:00:00Z',
    );
  }

  @override
  Future<Animal> createAnimal(Map<String, dynamic> body) async => animalSample;

  @override
  Future<Animal> patchAnimal(String id, Map<String, dynamic> body) async =>
      animalSample;

  @override
  Future<Animal> individualize(String lotId, Map<String, dynamic> body) async =>
      animalSample;

  @override
  Future<LotPage> lots({
    String? status,
    String? speciesId,
    int limit = 50,
    String? cursor,
  }) async {
    return const LotPage(items: [lotSample]);
  }

  @override
  Future<Lot> lot(String id) async => lotSample;

  @override
  Future<List<LotMovement>> lotMovements(String id) async {
    return const [
      LotMovement(
        id: 'movement-1',
        lotId: 'lot-1',
        type: 'ENTRY',
        quantity: 10,
        occurredAt: '2026-02-01T10:00:00Z',
        reason: 'Entrée initiale',
      ),
    ];
  }

  @override
  Future<LotMovement> moveLot(String id, Map<String, dynamic> body) async {
    return LotMovement(
      id: 'movement-2',
      lotId: id,
      type: body['type'] as String? ?? 'ENTRY',
      quantity: body['quantity'] as int? ?? 1,
      occurredAt: '2026-02-02T10:00:00Z',
    );
  }

  @override
  Future<LotClosure> closeLot(String id) async {
    return const LotClosure(
      lotId: 'lot-1',
      mortalityRate: 0.2,
      cost: 25,
      closedAt: '2026-03-01T10:00:00Z',
    );
  }

  @override
  Future<Lot> createLot(Map<String, dynamic> body) async => lotSample;

  @override
  Future<Lot> patchLot(String id, Map<String, dynamic> body) async => lotSample;

  @override
  Future<Lot> splitLot(String id, Map<String, dynamic> body) async => lotSample;

  @override
  Future<Lot> mergeLot(String id, Map<String, dynamic> body) async => lotSample;
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      herdRepositoryProvider.overrideWithValue(FakeHerdRepository()),
      referentialRepositoryProvider.overrideWithValue(FakeReferentialRepository()),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _wrapBody(Widget child) {
  return _wrap(Scaffold(body: child));
}

void main() {
  testWidgets('HerdPage renders animals with search and filters', (tester) async {
    await tester.pumpWidget(_wrapBody(const HerdPage()));
    await tester.pumpAndSettle();

    expect(find.text('A-001 · Bella'), findsOneWidget);
    expect(find.text('Bovin · FEMALE · ACTIVE'), findsWidgets);
    expect(find.text('Nouvel animal'), findsOneWidget);
    expect(find.text('Lots'), findsOneWidget);
    expect(find.text('Identifiant ou nom'), findsOneWidget);
  });

  testWidgets('AnimalDetailPage renders identity and filiation', (tester) async {
    await tester.pumpWidget(_wrap(const AnimalDetailPage(animalId: 'animal-1')));
    await tester.pumpAndSettle();

    expect(find.text('A-001'), findsWidgets);
    expect(find.text('Bella'), findsOneWidget);
    expect(find.text('Bovin'), findsOneWidget);
    expect(find.text('Holstein'), findsOneWidget);
    expect(find.text('Filiation'), findsOneWidget);
    expect(find.text('animal-2'), findsOneWidget);
  });

  testWidgets('AnimalFormPage renders the creation form', (tester) async {
    await tester.pumpWidget(_wrap(const AnimalFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvel animal'), findsOneWidget);
    expect(find.text('Identité'), findsOneWidget);
    expect(find.text('Rattachement'), findsOneWidget);
    expect(find.text('Ferme test'), findsOneWidget);
    expect(find.text('Bovin'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets('AnimalStatusPage renders status and history', (tester) async {
    await tester.pumpWidget(_wrap(const AnimalStatusPage(animalId: 'animal-1')));
    await tester.pumpAndSettle();

    expect(find.text('Statut et filiation'), findsOneWidget);
    expect(find.text('Changer le statut'), findsWidgets);
    expect(find.text('Filiation'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Historique'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.textContaining('Initial status'), findsOneWidget);
    expect(find.text('M-001'), findsOneWidget);
  });

  testWidgets('LotsPage renders lots', (tester) async {
    await tester.pumpWidget(_wrapBody(const LotsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Bandes 2026'), findsOneWidget);
    expect(find.text('Bovin · 7/10 · OPEN'), findsOneWidget);
    expect(find.text('Nouveau lot'), findsOneWidget);
  });

  testWidgets('LotDetailPage renders lot and actions', (tester) async {
    await tester.pumpWidget(_wrap(const LotDetailPage(lotId: 'lot-1')));
    await tester.pumpAndSettle();

    expect(find.text('Bandes 2026'), findsWidgets);
    expect(find.text('B26'), findsOneWidget);
    expect(find.text('MEAT'), findsOneWidget);
    expect(find.text('OPEN'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Mouvements'), findsOneWidget);
    expect(find.text('Clôturer'), findsOneWidget);
    expect(find.text('Individualiser un animal'), findsOneWidget);
  });

  testWidgets('LotFormPage renders the creation form', (tester) async {
    await tester.pumpWidget(_wrap(const LotFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau lot'), findsOneWidget);
    expect(find.text('Lot'), findsOneWidget);
    expect(find.text('Rattachement'), findsOneWidget);
    expect(find.text('Effectif et coût'), findsOneWidget);
    expect(find.text('Effectif initial'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
  });

  testWidgets('LotMovementsPage renders form and history', (tester) async {
    await tester.pumpWidget(_wrap(const LotMovementsPage(lotId: 'lot-1')));
    await tester.pumpAndSettle();

    expect(find.text('Mouvements · Bandes 2026'), findsOneWidget);
    expect(find.text('Nouveau mouvement'), findsOneWidget);
    expect(find.text('ENTRY · 10'), findsOneWidget);
    expect(find.text('Historique'), findsOneWidget);
  });

  testWidgets('LotClosePage shows closure action', (tester) async {
    await tester.pumpWidget(_wrap(const LotClosePage(lotId: 'lot-1')));
    await tester.pumpAndSettle();

    expect(find.text('Clôture du lot'), findsOneWidget);
    expect(find.text('Effectif actuel'), findsOneWidget);
    expect(find.text('Clôturer le lot'), findsOneWidget);
    expect(find.text("L'effectif doit être nul avant la clôture."), findsOneWidget);
  });
}
