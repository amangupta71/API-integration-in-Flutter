import 'dart:convert';
import 'package:api_integration/Role_pages/login_page.dart';
import 'package:api_integration/serrvices/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phraseController = TextEditingController();

  bool isLoading = false;

  Future<void> registerUser() async {
    setState(() => isLoading = true);
    final url = Uri.parse('http://localhost:3000/api/v1/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'phone': phoneController.text.trim(),
          'address': addressController.text.trim(),
          'phrase': phraseController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await AuthService.saveUserData(
          token: data['token'],
          username: data['username'],
          usertype: data['usertype'],
          email: data['email'],
          id: data['id'],
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Welcome ${data['username']}!')));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Create Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              "Join FoodieHub and start ordering delicious food",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: usernameController,
              decoration: _inputStyle("Username", Icons.person),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputStyle("Email", Icons.email),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _inputStyle("Password", Icons.lock),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputStyle("Phone", Icons.phone),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: addressController,
              decoration: _inputStyle("Address", Icons.location_on),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: phraseController,
              decoration: _inputStyle("Phrase", Icons.security),
            ),

            const SizedBox(height: 25),

            /// Register Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isLoading ? null : registerUser,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Create Account",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 15),

            /// Login Link
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
