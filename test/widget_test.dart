import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_1/main.dart';

void main() {
  testWidgets('validates student details and shows calculated results', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alex Student');
    await tester.enterText(fields.at(1), 'STU-001');
    await tester.enterText(fields.at(2), '80');
    await tester.enterText(fields.at(3), '90');
    await tester.enterText(fields.at(4), '100');
    await tester.tap(find.text('View Result >>'));
    await tester.pumpAndSettle();

    expect(find.text('Student Result'), findsOneWidget);
    expect(find.text('Alex Student'), findsOneWidget);
    expect(find.text('STU-001'), findsOneWidget);
    expect(find.text('270.00'), findsOneWidget);
    expect(find.text('90.00'), findsOneWidget);
    expect(find.text('90.00%'), findsOneWidget);
  });
}
