import 'package:flutter/material.dart';
import 'user_data_model.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Result'),
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Academic Performance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Student Name'),
                      subtitle: Text(user.name),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge),
                      title: const Text('Registration Number'),
                      subtitle: Text(user.registrationNumber),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Subject 1'),
                      trailing: Text('${user.mark1}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Subject 2'),
                      trailing: Text('${user.mark2}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Subject 3'),
                      trailing: Text('${user.mark3}'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.calculate),
                      title: const Text('Total Marks'),
                      trailing: Text(user.total.toStringAsFixed(2)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.analytics),
                      title: const Text('Average'),
                      trailing: Text(user.average.toStringAsFixed(2)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.percent),
                      title: const Text('Percentage'),
                      trailing: Text('${user.percentage.toStringAsFixed(2)}%'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}