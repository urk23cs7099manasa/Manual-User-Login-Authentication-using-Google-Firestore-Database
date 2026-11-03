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
      const StudentFirestoreApp(firebaseConfigured: false),
    );

    expect(
      find.text('Firebase is not configured for this platform.'),
      findsOneWidget,
    );
  });

  testWidgets('validates required student fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: StudentHomePage(firestore: firestore)),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Save Student to Firestore'));
    await tester.tap(find.text('Save Student to Firestore'));
    await tester.pump();

    expect(find.text('Please enter student name'), findsOneWidget);
    expect(find.text('Please enter registration number'), findsOneWidget);
    expect(find.text('Please enter department'), findsOneWidget);
    expect(find.text('Please enter marks'), findsOneWidget);
  });

  testWidgets('saves a student and displays the Firestore record', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: StudentHomePage(firestore: firestore)),
    );
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Alex Student');
    await tester.enterText(fields.at(1), 'stu-001');
    await tester.enterText(fields.at(2), 'Computer Science');
    await tester.enterText(fields.at(3), '92.5');
    await tester.tap(find.text('Save Student to Firestore'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final record = await firestore.collection('students').doc('STU-001').get();
    expect(record.exists, isTrue);
    expect(record.data()?['name'], 'Alex Student');
    expect(record.data()?['registrationNumber'], 'STU-001');
    expect(record.data()?['department'], 'Computer Science');
    expect(record.data()?['marks'], 92.5);

    await tester.pump();
    expect(find.text('Alex Student'), findsOneWidget);
    expect(
      find.text(
        'Registration No: STU-001\nDepartment: Computer Science\nMarks: 92.5',
      ),
      findsOneWidget,
    );
  });
}
