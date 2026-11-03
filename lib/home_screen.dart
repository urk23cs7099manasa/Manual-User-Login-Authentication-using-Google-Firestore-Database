import 'package:flutter/material.dart';
import 'user_data_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController mark1Controller = TextEditingController();
  final TextEditingController mark2Controller = TextEditingController();
  final TextEditingController mark3Controller = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    regNoController.dispose();
    mark1Controller.dispose();
    mark2Controller.dispose();
    mark3Controller.dispose();
    super.dispose();
  }

  void navigateToResult() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        name: nameController.text.trim(),
        registrationNumber: regNoController.text.trim(),
        mark1: double.parse(mark1Controller.text.trim()),
        mark2: double.parse(mark2Controller.text.trim()),
        mark3: double.parse(mark3Controller.text.trim()),
      );
      Navigator.pushNamed(
        context,
        '/second',
        arguments: user,
      );
    }
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget buildMarkField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          final mark = double.tryParse(value.trim());
          if (mark == null || mark < 0 || mark > 100) {
            return 'Enter a mark between 0 and 100';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter Student Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              buildTextField(nameController, 'Student Name'),
              buildTextField(regNoController, 'Registration Number'),
              buildMarkField(mark1Controller, 'Subject 1 Mark'),
              buildMarkField(mark2Controller, 'Subject 2 Mark'),
              buildMarkField(mark3Controller, 'Subject 3 Mark'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: navigateToResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'View Result >>',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}