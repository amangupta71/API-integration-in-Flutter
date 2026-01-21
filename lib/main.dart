import 'package:api_integration/screens/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:api_integration/Role_pages/login_page.dart';
import 'package:api_integration/serrvices/auth_services.dart';
import 'package:api_integration/Role_pages/admin_page.dart';
import 'package:api_integration/Role_pages/user_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Food App",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashDecider(),
    );
  }
}

/// 🔹 This widget decides where to go on app start
class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
      );
    } else {
      final user = await AuthService.getUserData();
      final role = user['usertype'];

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
