import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/feeding/feeding_repository.dart';
import 'package:rm_breeding_mobile/core/herd/herd_repository.dart';
import 'package:rm_breeding_mobile/features/feeding/distribution_page.dart';
import 'package:rm_breeding_mobile/features/feeding/feeding_page.dart';
import 'package:rm_breeding_mobile/features/feeding/feeds_page.dart';
import 'package:rm_breeding_mobile/features/feeding/plans_page.dart';
import 'package:rm_breeding_mobile/features/feeding/receipt_page.dart';
import 'package:rm_breeding_mobile/features/feeding/stock_page.dart';

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

class FakeFeedingRepository extends FeedingRepository {
  FakeFeedingRepository() : super(Dio());

  static const feed = Feed(
    id: 'feed-1',
    name: 'Maïs',
    type: 'CONCENTRATE',
    unit: 'kg',
    price: 0.35,
    supplier: 'Sarl',
  );

  static const receipt = FeedReceipt(
    id: 'receipt-1',
    feedId: 'feed-1',
    quantity: 100,
    unitPrice: 0.4,
    receivedAt: '2026-11-13T08:00:00Z',
    supplier: 'Sarl',
  );

  static const distribution = FeedDistribution(
    id: 'distribution-1',
    feedId: 'feed-1',
    lotId: 'lot-1',
    quantity: 20,
    distributedAt: '2026-11-13T09:00:00Z',
  );

  static const stock = FeedStock(
    feedId: 'feed-1',
    feedName: 'Maïs',
    unit: 'kg',
    quantity: 42,
    averagePrice: 0.35,
  );

  static const alert = LowStockAlert(
    feedId: 'feed-1',
    feedName: 'Maïs',
    unit: 'kg',
    quantity: 8,
    threshold: 10,
  );

  static const plan = FeedingPlan(
    id: 'plan-1',
    speciesId: 'species-1',
    name: 'Poussin démarrage',
    stages: [
      {'name': 'Démarrage', 'days': 14},
    ],
    active: true,
  );

  @override
  Future<List<Feed>> feeds({String? search, bool includeArchived = false}) async {
    return const [feed];
  }

  @override
  Future<List<FeedReceipt>> receipts(String feedId) async {
    return const [receipt];
  }

  @override
  Future<List<FeedDistribution>> distributions({String? feedId}) async {
    return const [distribution];
  }

  @override
  Future<List<FeedStock>> stocks() async {
    return const [stock];
  }

  @override
  Future<List<LowStockAlert>> lowStock({double? threshold}) async {
    return const [alert];
  }

  @override
  Future<List<FeedingPlan>> feedingPlans({String? speciesId}) async {
    return const [plan];
  }
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      herdRepositoryProvider.overrideWithValue(FakeHerdRepository()),
      feedingRepositoryProvider.overrideWithValue(FakeFeedingRepository()),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _wrapBody(Widget child) {
  return _wrap(Scaffold(body: child));
}

void main() {
  testWidgets('FeedingPage renders actions and low stock alerts', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapBody(const FeedingPage()));
    await tester.pumpAndSettle();

    expect(find.text('Aliments'), findsOneWidget);
    expect(find.text('Réception'), findsOneWidget);
    expect(find.text('Distribution'), findsOneWidget);
    expect(find.text('Stocks'), findsOneWidget);
    expect(find.text('Plans'), findsOneWidget);
    expect(find.text('Stocks bas'), findsOneWidget);
    expect(find.text('Maïs'), findsOneWidget);
  });

  testWidgets('FeedsPage renders feeds and create action', (tester) async {
    await tester.pumpWidget(_wrap(const FeedsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Aliments'), findsWidgets);
    expect(find.text('Maïs'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('FeedsPage opens the create dialog', (tester) async {
    await tester.pumpWidget(_wrap(const FeedsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Nouvel aliment'), findsOneWidget);
    expect(find.text('Unité'), findsOneWidget);
    expect(find.text('Prix unitaire'), findsOneWidget);
  });

  testWidgets('ReceiptPage renders the receipt form and history', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ReceiptPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle réception'), findsOneWidget);
    expect(find.text('Aliment'), findsOneWidget);
    expect(find.text('Quantité'), findsOneWidget);
    expect(find.text('Date de réception'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Réceptions récentes'), findsOneWidget);
  });

  testWidgets('DistributionPage renders the distribution form', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const DistributionPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle distribution'), findsOneWidget);
    expect(find.text('Cible'), findsOneWidget);
    expect(find.text('Quantité'), findsOneWidget);
    expect(find.text('Date de distribution'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Distributions récentes'), findsOneWidget);
    expect(find.text('Lot lot-1'), findsOneWidget);
  });

  testWidgets('StockPage renders stocks and alerts', (tester) async {
    await tester.pumpWidget(_wrap(const StockPage()));
    await tester.pumpAndSettle();

    expect(find.text('Seuil de stock bas'), findsOneWidget);
    expect(find.text('Stocks'), findsWidgets);
    expect(find.text('Maïs'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Alertes de stock bas'), findsOneWidget);
  });

  testWidgets('FeedingPlansPage renders plans', (tester) async {
    await tester.pumpWidget(_wrap(const FeedingPlansPage()));
    await tester.pumpAndSettle();

    expect(find.text('Plans'), findsWidgets);
    expect(find.text('Poussin démarrage'), findsOneWidget);
    expect(find.text('1 étape(s) - Actif'), findsOneWidget);
  });
}
