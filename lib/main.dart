import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  if (firebaseOptions == null) {
    runApp(const FirestoreSearchApp(firebaseConfigured: false));
    return;
  }

  try {
    await Firebase.initializeApp(options: firebaseOptions);
    runApp(const FirestoreSearchApp(firebaseConfigured: true));
  } on FirebaseException catch (error) {
    runApp(FirebaseInitializationErrorApp(message: error.message ?? error.code));
  }
}

class FirestoreSearchApp extends StatelessWidget {
  final bool firebaseConfigured;

  const FirestoreSearchApp({super.key, required this.firebaseConfigured});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firestore Student Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: firebaseConfigured
          ? const StudentSearchPage()
          : const FirebaseConfigurationPage(),
    );
  }
}

class FirebaseConfigurationPage extends StatelessWidget {
  const FirebaseConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _InformationPage(
      title: 'Firestore Student Search',
      icon: Icons.cloud_off,
      message: 'Firebase is not configured for this platform.',
      details:
          'Create firebase_config.json from the example file, add your '
          'Firebase project settings, then run this app with '
          '--dart-define-from-file=firebase_config.json.',
    );
  }
}

class FirebaseInitializationErrorApp extends StatelessWidget {
  final String message;

  const FirebaseInitializationErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firestore Student Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: _InformationPage(
        title: 'Firestore Student Search',
        icon: Icons.error_outline,
        message: 'Firebase could not be initialized.',
        details: message,
      ),
    );
  }
}

class _InformationPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final String details;

  const _InformationPage({
    required this.title,
    required this.icon,
    required this.message,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: Colors.indigo),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(details, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StudentSearchPage extends StatefulWidget {
  final FirebaseFirestore? firestore;

  const StudentSearchPage({super.key, this.firestore});

  @override
  State<StudentSearchPage> createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends State<StudentSearchPage> {
  final _searchController = TextEditingController();
  late final CollectionReference<Map<String, dynamic>> _students =
      (widget.firestore ?? FirebaseFirestore.instance).collection('students');

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _results = [];
  bool _isLoading = false;
  String _message = 'Enter a student name or registration number.';

  Future<void> _searchStudents() async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      setState(() {
        _results = [];
        _message = 'Please enter a search value.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _results = [];
      _message = '';
    });

    try {
      final registrationQuery = await _students
          .where(
            'registrationNumber',
            isEqualTo: searchText.toUpperCase(),
          )
          .get();
      final nameQuery = await _students
          .where('name', isEqualTo: searchText)
          .get();

      final results = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      for (final document in registrationQuery.docs) {
        results[document.id] = document;
      }
      for (final document in nameQuery.docs) {
        results[document.id] = document;
      }

      final sortedResults = results.values.toList()
        ..sort(
          (first, second) => (first.data()['registrationNumber'] ?? '')
              .toString()
              .compareTo(
                (second.data()['registrationNumber'] ?? '').toString(),
              ),
        );

      if (!mounted) return;
      setState(() {
        _results = sortedResults;
        _message = _results.isEmpty
            ? 'No matching student found.'
            : 'Search completed successfully.';
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _message =
            'Search failed: ${error.message ?? error.code}. Check your '
            'internet connection and Firestore permissions.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDetail(String label, Object? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value?.toString() ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final student = doc.data();
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student['name']?.toString() ?? 'N/A',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildDetail('Registration Number', student['registrationNumber']),
            _buildDetail('Department', student['department']),
            _buildDetail('Marks', student['marks']),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Student Search'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.search, size: 65, color: Colors.indigo),
                const SizedBox(height: 12),
                const Text(
                  'Search Student Information',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Name or Registration Number',
                    hintText: 'Enter student details',
                    prefixIcon: Icon(Icons.person_search),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchStudents(),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _searchStudents,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_message.isNotEmpty)
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                const SizedBox(height: 12),
                ..._results.map(_buildStudentCard),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
