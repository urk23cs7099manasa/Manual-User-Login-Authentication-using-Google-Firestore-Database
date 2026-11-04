import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_1/main.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  testWidgets('shows setup guidance if Firebase is not configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const FirestoreSearchApp(firebaseConfigured: false),
    );

    expect(
      find.text('Firebase is not configured for this platform.'),
      findsOneWidget,
    );
  });

  testWidgets('asks for a search value when the field is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: StudentSearchPage(firestore: firestore)),
    );

    await tester.tap(find.text('Search Student'));
    await tester.pump();

    expect(find.text('Please enter a search value.'), findsOneWidget);
  });

  testWidgets('searches by registration number without case sensitivity', (
    WidgetTester tester,
  ) async {
    await firestore.collection('students').doc('STU-001').set({
      'name': 'Alex Student',
      'registrationNumber': 'STU-001',
      'department': 'Computer Science',
      'marks': 92.5,
    });

    await tester.pumpWidget(
      MaterialApp(home: StudentSearchPage(firestore: firestore)),
    );
    await tester.enterText(find.byType(TextField), ' stu-001 ');
    await tester.tap(find.text('Search Student'));
    await tester.pumpAndSettle();

    expect(find.text('Alex Student'), findsOneWidget);
    expect(find.text('Registration Number:'), findsOneWidget);
    expect(find.text('STU-001'), findsOneWidget);
    expect(find.text('Computer Science'), findsOneWidget);
    expect(find.text('92.5'), findsOneWidget);
  });

  testWidgets('searches by an exact student name', (WidgetTester tester) async {
    await firestore.collection('students').doc('STU-001').set({
      'name': 'Alex Student',
      'registrationNumber': 'STU-001',
      'department': 'Computer Science',
      'marks': 92.5,
    });

    await tester.pumpWidget(
      MaterialApp(home: StudentSearchPage(firestore: firestore)),
    );
    await tester.enterText(find.byType(TextField), 'Alex Student');
    await tester.tap(find.text('Search Student'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Card),
        matching: find.text('Alex Student'),
      ),
      findsOneWidget,
    );
    expect(find.text('STU-001'), findsOneWidget);
  });

  testWidgets('searches exact names and combines results without duplicates', (
    WidgetTester tester,
  ) async {
    await firestore.collection('students').doc('STU-001').set({
      'name': 'STU-001',
      'registrationNumber': 'STU-001',
      'department': 'Computer Science',
      'marks': 92.5,
    });
    await firestore.collection('students').doc('OTHER').set({
      'name': 'STU-001',
      'registrationNumber': 'OTHER',
      'department': 'Mathematics',
      'marks': 85,
    });

    await tester.pumpWidget(
      MaterialApp(home: StudentSearchPage(firestore: firestore)),
    );
    await tester.enterText(find.byType(TextField), 'STU-001');
    await tester.tap(find.text('Search Student'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('Search completed successfully.'), findsOneWidget);
    expect(find.text('Computer Science'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
  });

  testWidgets('shows a message when there is no matching record', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: StudentSearchPage(firestore: firestore)),
    );
    await tester.enterText(find.byType(TextField), 'missing student');
    await tester.tap(find.text('Search Student'));
    await tester.pumpAndSettle();

    expect(find.text('No matching student found.'), findsOneWidget);
  });
}
