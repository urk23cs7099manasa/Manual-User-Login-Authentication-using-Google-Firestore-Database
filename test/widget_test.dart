import 'package:flutter_test/flutter_test.dart';

import 'package:project_1/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('shows the student form and validates required fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StudentApp());
    await tester.pump();

    expect(find.text('Student Record Management'), findsOneWidget);
    expect(find.text('Add Student Details'), findsOneWidget);
    expect(find.text('Saved Student Records'), findsOneWidget);

    await tester.tap(find.text('Save Student'));
    await tester.pump();

    expect(find.text('Please enter the student name'), findsOneWidget);
    expect(find.text('Please enter the registration number'), findsOneWidget);
    expect(find.text('Please enter the department'), findsOneWidget);
    expect(find.text('Please enter the marks'), findsOneWidget);
  });

  test('persists student records in SQLite', () async {
    final database = await DatabaseHelper.instance.database;
    await database.delete('students');

    await DatabaseHelper.instance.insertStudent({
      'name': 'Alex Student',
      'regNo': 'STU-001',
      'department': 'Computer Science',
      'marks': 92.5,
    });

    final students = await DatabaseHelper.instance.getStudents();
    expect(students, hasLength(1));
    expect(students.single['name'], 'Alex Student');
    expect(students.single['regNo'], 'STU-001');
    expect(students.single['marks'], 92.5);
  });
}
