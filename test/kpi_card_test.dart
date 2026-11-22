import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rm_breeding_mobile/shared/widgets/kpi_card.dart';

void main() {
  testWidgets('KpiCard renders label, value and unit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KpiCard(label: 'Animaux', value: '128', unit: 'têtes', trend: 4),
        ),
      ),
    );

    expect(find.text('Animaux'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('têtes'), findsOneWidget);
    expect(find.text('+4%'), findsOneWidget);
  });
}
