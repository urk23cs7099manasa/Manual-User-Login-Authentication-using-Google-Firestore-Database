import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StudentLoginApp());
}

class StudentLoginApp extends StatelessWidget {
  const StudentLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5146E5),
        ),
        fontFamily: 'Arial',
      ),
      home: const StudentLoginPage(),
    );
  }
}

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
      TextEditingController(text: 'student@example.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'Demo1234');
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentMaterialBanner()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor:
              success ? Colors.green.shade700 : Colors.red.shade700,
          leading: Icon(
            success ? Icons.check_circle : Icons.error_outline,
            color: Colors.white,
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text(
                'DISMISS',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Firebase did not return a signed-in user.');
      }

      final profileReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final profileSnapshot = await profileReference.get();

      if (!profileSnapshot.exists) {
        await profileReference.set({
          'email': user.email ?? _emailController.text.trim(),
          'name': user.displayName ?? 'Student',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        _showMessage(
          'Login successful. A basic profile was created.',
          success: true,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => StudentHomePage(
              name: user.displayName ?? 'Student',
              email: user.email ?? _emailController.text.trim(),
            ),
          ),
        );
        return;
      }

      final profile = profileSnapshot.data()!;
      final name = (profile['name'] as String?) ??
          user.displayName ??
          'Student';
      final email = (profile['email'] as String?) ?? user.email ?? '';

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StudentHomePage(
            name: name,
            email: email,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          message = 'Invalid email or password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;
        default:
          message = e.message ?? 'Authentication failed.';
      }

      _showMessage(message);
    } on FirebaseException catch (e) {
      String message;

      if (e.code == 'permission-denied') {
        message =
            'Firestore access denied. Check your Firestore rules '
            'and ensure the users document ID matches your Firebase '
            'Authentication UID.';
      } else {
        message = 'Database error: ${e.message ?? e.code}';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage('Unable to sign in: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade700),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F7FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF5146E5),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 465),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 84,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF0FF),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.lock_person_rounded,
                          size: 42,
                          color: Color(0xFF5146E5),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Sign in to continue to your account.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF667085),
                        ),
                      ),
                      const SizedBox(height: 34),
                      const Text(
                        'Email address',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: _inputDecoration(
                          hint: 'Enter your email',
                          icon: Icons.mail_outline,
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return 'Please enter your email.';
                          }
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)) {
                            return 'Enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Password',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: _inputDecoration(
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5146E5),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFAAA5F4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          'Student Login Portal',
                          style: TextStyle(
                            color: Color(0xFF98A2B3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentHomePage extends StatelessWidget {
  final String name;
  final String email;

  const StudentHomePage({
    super.key,
    required this.name,
    required this.email,
  });

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const StudentLoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F9),
      appBar: AppBar(
        title: const Text('Student Portal'),
        backgroundColor: const Color(0xFF5146E5),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFEEF0FF),
                      child: Icon(
                        Icons.person,
                        size: 46,
                        color: Color(0xFF5146E5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Login Successful!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Student Name'),
                      subtitle: Text(name),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email Address'),
                      subtitle: Text(email),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _signOut(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
