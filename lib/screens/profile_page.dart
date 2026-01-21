import 'package:api_integration/Role_pages/login_page.dart';
import 'package:api_integration/serrvices/auth_services.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  String? usertype;
  String? id;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await AuthService.getUserData();
    setState(() {
      username = data['username'];
      email = data['email'];
      usertype = data['usertype'];
      id = data['id'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Text(
                    username![0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  username!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  usertype!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// Profile Details Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              child: Column(
                children: [
                  _profileTile(
                    icon: Icons.person,
                    title: "Username",
                    value: username!,
                  ),
                  _divider(),
                  _profileTile(
                    icon: Icons.email,
                    title: "Email",
                    value: email!,
                  ),
                  _divider(),
                  _profileTile(
                    icon: Icons.badge,
                    title: "Role",
                    value: usertype!,
                  ),
                  _divider(),
                  _profileTile(
                    icon: Icons.fingerprint,
                    title: "User ID",
                    value: id!,
                  ),
                  _profileTile(
                    icon: Icons.location_city,
                    title: "Address",
                    value: '   ',
                  ),
                  _divider(),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      await AuthService.clearUserData();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1),
    );
  }
}
