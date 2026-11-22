import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/herd/herd_repository.dart';
import 'package:rm_breeding_mobile/core/production/production_repository.dart';
import 'package:rm_breeding_mobile/features/production/collection_page.dart';
import 'package:rm_breeding_mobile/features/production/egg_stock_page.dart';
import 'package:rm_breeding_mobile/features/production/growth_page.dart';
import 'package:rm_breeding_mobile/features/production/production_page.dart';
import 'package:rm_breeding_mobile/features/production/weighing_page.dart';

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

class FakeProductionRepository extends ProductionRepository {
  FakeProductionRepository() : super(Dio());

  static const weighing = Weighing(
    id: 'weighing-1',
    animalId: 'animal-1',
    weighedAt: '2026-11-13T08:00:00Z',
    weightKg: 42.5,
  );

  static const sampleGmq = Gmq(
    animalId: 'animal-1',
    days: 10,
    startWeightKg: 30,
    endWeightKg: 40,
    gmq: 1,
  );

  static const curve = GrowthCurve(
    animalId: 'animal-1',
    speciesId: 'species-1',
    points: [
      GrowthPoint(weighedAt: '2026-11-13T08:00:00Z', weightKg: 42.5, ageDays: 120),
    ],
    reference: [
      {'ageDays': 120, 'weightKg': 40},
    ],
  );

  static const collection = EggCollection(
    id: 'collection-1',
    farmId: 'farm-1',
    lotId: 'lot-1',
    collectedAt: '2026-11-13T06:00:00Z',
    collected: 100,
    broken: 5,
    downgraded: 3,
    sellable: 92,
  );

  static const movement = EggMovement(
    id: 'movement-1',
    farmId: 'farm-1',
    lotId: 'lot-1',
    type: 'SALE',
    quantity: 20,
    occurredAt: '2026-11-13T09:00:00Z',
  );

  static const eggStock = EggStock(
    farmId: 'farm-1',
    lotId: 'lot-1',
    quantity: 72,
    updatedAt: '2026-11-13T09:00:00Z',
  );

  @override
  Future<List<Weighing>> weighings({String? animalId, String? lotId}) async {
    return const [weighing];
  }

  @override
  Future<Gmq> gmq({String? animalId, String? lotId}) async {
    return sampleGmq;
  }

  @override
  Future<GrowthCurve> growthCurve({String? animalId, String? lotId}) async {
    return curve;
  }

  @override
  Future<List<EggCollection>> collections({String? lotId}) async {
    return const [collection];
  }

  @override
  Future<List<EggMovement>> movements({String? lotId}) async {
    return const [movement];
  }

  @override
  Future<List<EggStock>> eggStocks() async {
    return const [eggStock];
  }
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      herdRepositoryProvider.overrideWithValue(FakeHerdRepository()),
      productionRepositoryProvider.overrideWithValue(
        FakeProductionRepository(),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _wrapBody(Widget child) {
  return _wrap(Scaffold(body: child));
}

void main() {
  testWidgets('ProductionPage renders actions and egg stock', (tester) async {
    await tester.pumpWidget(_wrapBody(const ProductionPage()));
    await tester.pumpAndSettle();

    expect(find.text('Pesées'), findsOneWidget);
    expect(find.text('Croissance'), findsOneWidget);
    expect(find.text('Ramassage'), findsOneWidget);
    expect(find.text('Stock d’œufs'), findsWidgets);
    expect(find.text('Lot lot-1'), findsOneWidget);
  });

  testWidgets('WeighingPage renders the weighing form and history', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const WeighingPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle pesée'), findsOneWidget);
    expect(find.text('Poids (kg)'), findsOneWidget);
    expect(find.text('Date de pesée'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Pesées récentes'), findsOneWidget);
    expect(find.text('42.5 kg'), findsOneWidget);
  });

  testWidgets('GrowthPage renders GMQ and growth points', (tester) async {
    await tester.pumpWidget(_wrap(const GrowthPage()));
    await tester.pumpAndSettle();

    expect(find.text('Gain moyen quotidien'), findsOneWidget);
    expect(find.text('1 kg/jour'), findsOneWidget);
    expect(find.text('Points de croissance'), findsOneWidget);
  });

  testWidgets('CollectionPage renders the collection form and history', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const CollectionPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau ramassage'), findsOneWidget);
    expect(find.text('Œufs collectés'), findsOneWidget);
    expect(find.text('Cassés'), findsOneWidget);
    expect(find.text('Écartés'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Ramassages récents'), findsOneWidget);
    expect(find.text('100 collectés, 92 vendables'), findsOneWidget);
  });

  testWidgets('EggStockPage renders stocks and movements', (tester) async {
    await tester.pumpWidget(_wrap(const EggStockPage()));
    await tester.pumpAndSettle();

    expect(find.text('72 œufs'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Nouveau mouvement'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Mouvements récents'), findsOneWidget);
  });
}
