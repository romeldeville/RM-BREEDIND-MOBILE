import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rm_breeding_mobile/core/referential/referential_repository.dart';
import 'package:rm_breeding_mobile/features/sites/farm_plan_page.dart';
import 'package:rm_breeding_mobile/features/sites/sites_page.dart';
import 'package:rm_breeding_mobile/features/species/breeds_page.dart';
import 'package:rm_breeding_mobile/features/species/species_form_page.dart';
import 'package:rm_breeding_mobile/features/species/species_list_page.dart';
import 'package:rm_breeding_mobile/features/species/species_plans_page.dart';

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
  Future<Species> speciesById(String speciesId) async {
    return const Species(
      id: 'species-1',
      name: 'Bovin',
      code: 'bovin',
      productionType: 'MILK',
      trackingMode: 'INDIVIDUAL',
      settings: {'lactationDays': 305},
    );
  }

  @override
  Future<List<SpeciesTemplate>> templates(String speciesId) async {
    return const [
      SpeciesTemplate(id: 'template-1', speciesId: 'species-1', name: 'Standard'),
    ];
  }

  @override
  Future<List<VaccinationPlan>> vaccinationPlans(String speciesId) async {
    return const [
      VaccinationPlan(id: 'vac-1', speciesId: 'species-1', name: 'Rage', ageDays: 90),
    ];
  }

  @override
  Future<List<FeedingPlan>> feedingPlans(String speciesId) async {
    return const [
      FeedingPlan(id: 'feed-1', speciesId: 'species-1', name: 'Croissance', stageCount: 2),
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

  @override
  Future<List<Building>> buildings(String farmId) async {
    return const [
      Building(id: 'building-1', farmId: 'farm-1', name: 'Étable'),
    ];
  }

  @override
  Future<List<Pen>> pens(String buildingId) async {
    return const [
      Pen(
        id: 'pen-1',
        farmId: 'farm-1',
        buildingId: 'building-1',
        name: 'Loge A',
        capacity: 10,
      ),
    ];
  }

  @override
  Future<PenOccupancy> occupancy(String penId) async {
    return const PenOccupancy(penId: 'pen-1', capacity: 10, occupied: 7);
  }
}

Widget _wrap(Widget child, {FakeReferentialRepository? repository}) {
  return ProviderScope(
    overrides: [
      referentialRepositoryProvider
          .overrideWithValue(repository ?? FakeReferentialRepository()),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

Widget _wrapPage(Widget child) {
  return ProviderScope(
    overrides: [
      referentialRepositoryProvider.overrideWithValue(FakeReferentialRepository()),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('SpeciesListPage renders species', (tester) async {
    await tester.pumpWidget(_wrap(const SpeciesListPage()));
    await tester.pumpAndSettle();

    expect(find.text('Bovin'), findsOneWidget);
    expect(find.textContaining('bovin'), findsOneWidget);
    expect(find.text('Nouvelle espèce'), findsOneWidget);
  });

  testWidgets('SpeciesFormPage renders the creation form', (tester) async {
    await tester.pumpWidget(_wrapPage(const SpeciesFormPage()));
    await tester.pumpAndSettle();

    expect(find.text('Nouvelle espèce'), findsOneWidget);
    expect(find.text('Identité'), findsOneWidget);
    expect(find.text('Reproduction'), findsOneWidget);
    expect(find.text('Gabarits'), findsNothing);
  });

  testWidgets('SpeciesFormPage shows templates in edit mode', (tester) async {
    await tester.pumpWidget(_wrapPage(const SpeciesFormPage(speciesId: 'species-1')));
    await tester.pumpAndSettle();

    expect(find.text('Modifier l’espèce'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Nom du gabarit'), findsOneWidget);
  });

  testWidgets('SpeciesPlansPage renders vaccination and feeding plans', (tester) async {
    await tester.pumpWidget(_wrapPage(const SpeciesPlansPage(speciesId: 'species-1')));
    await tester.pumpAndSettle();

    expect(find.text('Plans sanitaires et alimentaires'), findsOneWidget);
    expect(find.text('Rage'), findsOneWidget);
    expect(find.text('Croissance'), findsOneWidget);
    expect(find.text('2 étape(s)'), findsOneWidget);
  });

  testWidgets('BreedsPage renders breeds', (tester) async {
    await tester.pumpWidget(_wrap(const BreedsPage(speciesId: 'species-1')));
    await tester.pumpAndSettle();

    expect(find.text('Holstein'), findsOneWidget);
    expect(find.text('Ajouter une race'), findsOneWidget);
  });

  testWidgets('SitesPage renders buildings and pens', (tester) async {
    await tester.pumpWidget(_wrap(const SitesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Étable'), findsOneWidget);
    expect(find.text('Loge A'), findsOneWidget);
    expect(find.text('7 / 10 occupés'), findsOneWidget);
    expect(find.text('Voir le plan de ferme'), findsOneWidget);
  });

  testWidgets('FarmPlanPage shows pen occupancy', (tester) async {
    await tester.pumpWidget(_wrap(const FarmPlanPage()));
    await tester.pumpAndSettle();

    expect(find.text('Étable'), findsOneWidget);
    expect(find.text('Loge A'), findsOneWidget);
    expect(find.text('7 / 10 occupés'), findsOneWidget);
  });
}
