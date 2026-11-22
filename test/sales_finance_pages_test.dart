import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/finance/finance_repository.dart';
import 'package:rm_breeding_mobile/core/herd/herd_repository.dart';
import 'package:rm_breeding_mobile/core/sales/sales_repository.dart';
import 'package:rm_breeding_mobile/features/finance/costs_page.dart';
import 'package:rm_breeding_mobile/features/finance/expense_page.dart';
import 'package:rm_breeding_mobile/features/finance/finance_page.dart';
import 'package:rm_breeding_mobile/features/finance/revenue_page.dart';
import 'package:rm_breeding_mobile/features/sales/clients_page.dart';
import 'package:rm_breeding_mobile/features/sales/payments_page.dart';
import 'package:rm_breeding_mobile/features/sales/sale_form_page.dart';
import 'package:rm_breeding_mobile/features/sales/sales_page.dart';

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

class FakeSalesRepository extends SalesRepository {
  FakeSalesRepository() : super(Dio());

  static const customer = Customer(
    id: 'customer-1',
    farmId: 'farm-1',
    name: 'Kouassi',
    phone: '0700',
    balance: 0,
  );

  static const sampleSale = Sale(
    id: 'sale-1',
    farmId: 'farm-1',
    customerId: 'customer-1',
    number: 'S-00001',
    type: 'ANIMAL',
    status: 'CONFIRMED',
    soldAt: '2026-11-13T10:00:00Z',
    totalAmount: 150000,
    currency: 'XOF',
    paymentStatus: 'UNPAID',
  );

  static const payment = Payment(
    id: 'payment-1',
    saleId: 'sale-1',
    amount: 50000,
    method: 'CASH',
    status: 'COMPLETED',
    paidAt: '2026-11-13T11:00:00Z',
  );

  @override
  Future<List<Customer>> customers({bool includeArchived = false}) async {
    return const [customer];
  }

  @override
  Future<List<Sale>> sales({String? status}) async {
    return const [sampleSale];
  }

  @override
  Future<List<Payment>> payments(String saleId) async {
    return const [payment];
  }
}

class FakeFinanceRepository extends FinanceRepository {
  FakeFinanceRepository() : super(Dio());

  static const expense = Expense(
    id: 'expense-1',
    farmId: 'farm-1',
    category: 'VETERINARY',
    amount: 25000,
    currency: 'XOF',
    incurredAt: '2026-11-13',
  );

  static const revenue = Revenue(
    id: 'revenue-1',
    farmId: 'farm-1',
    category: 'MILK',
    amount: 80000,
    currency: 'XOF',
    receivedAt: '2026-11-13',
  );

  static const sampleLotCost = LotCost(
    lotId: 'lot-1',
    feedCost: 100000,
    allocatedCost: 25000,
    totalCost: 125000,
  );

  static const sampleLotMargin = LotMargin(
    lotId: 'lot-1',
    revenue: 200000,
    cost: 125000,
    margin: 75000,
    marginRate: 37.5,
  );

  @override
  Future<List<Expense>> expenses() async {
    return const [expense];
  }

  @override
  Future<List<Revenue>> revenues() async {
    return const [revenue];
  }

  @override
  Future<LotCost> lotCost(String lotId) async {
    return sampleLotCost;
  }

  @override
  Future<LotMargin> lotMargin(String lotId) async {
    return sampleLotMargin;
  }
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      herdRepositoryProvider.overrideWithValue(FakeHerdRepository()),
      salesRepositoryProvider.overrideWithValue(FakeSalesRepository()),
      financeRepositoryProvider.overrideWithValue(FakeFinanceRepository()),
    ],
    child: MaterialApp(home: child),
  );
}

Widget _wrapBody(Widget child) {
  return _wrap(Scaffold(body: child));
}

void main() {
  testWidgets('SalesPage renders actions and recent sales', (tester) async {
    await tester.pumpWidget(_wrapBody(const SalesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle vente'), findsOneWidget);
    expect(find.text('Paiements'), findsOneWidget);
    expect(find.text('Clients'), findsOneWidget);
    expect(find.text('Ventes récentes'), findsOneWidget);
    expect(find.text('S-00001 · 150000 XOF'), findsOneWidget);
  });

  testWidgets('ClientsPage renders the client form and list', (tester) async {
    await tester.pumpWidget(_wrap(const ClientsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau client'), findsOneWidget);
    expect(find.text('Nom'), findsOneWidget);
    expect(find.text('Téléphone'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Kouassi'), findsOneWidget);
  });

  testWidgets('SaleFormPage renders the sale form', (tester) async {
    await tester.pumpWidget(_wrap(const SaleFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle vente'), findsOneWidget);
    expect(find.text('Type'), findsOneWidget);
    expect(find.text('Prix unitaire'), findsOneWidget);
    expect(find.text('Date de vente'), findsOneWidget);
  });

  testWidgets('PaymentsPage renders the payment form and list', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const PaymentsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau paiement'), findsOneWidget);
    expect(find.text('Montant'), findsOneWidget);
    expect(find.text('Méthode'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Paiements enregistrés'), findsOneWidget);
    expect(find.text('50000 XOF'), findsOneWidget);
  });

  testWidgets('FinancePage renders actions and recent expenses', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapBody(const FinancePage()));
    await tester.pumpAndSettle();

    expect(find.text('Dépenses'), findsOneWidget);
    expect(find.text('Revenus'), findsOneWidget);
    expect(find.text('Coûts & marges'), findsOneWidget);
    expect(find.text('Dépenses récentes'), findsOneWidget);
    expect(find.text('VETERINARY · 25000 XOF'), findsOneWidget);
  });

  testWidgets('ExpensePage renders the expense form', (tester) async {
    await tester.pumpWidget(_wrap(const ExpensePage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle dépense'), findsOneWidget);
    expect(find.text('Catégorie'), findsOneWidget);
    expect(find.text('Montant'), findsOneWidget);
  });

  testWidgets('RevenuePage renders the revenue form', (tester) async {
    await tester.pumpWidget(_wrap(const RevenuePage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouveau revenu'), findsOneWidget);
    expect(find.text('Catégorie'), findsOneWidget);
  });

  testWidgets('CostsPage renders lot cost and margin', (tester) async {
    await tester.pumpWidget(_wrap(const CostsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Coût du lot'), findsOneWidget);
    expect(find.text('Coût total'), findsOneWidget);
    expect(find.text('125000 XOF'), findsWidgets);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Marge du lot'), findsOneWidget);
    expect(find.text('Taux de marge'), findsOneWidget);
  });
}
