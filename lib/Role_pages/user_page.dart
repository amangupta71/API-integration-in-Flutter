import 'package:api_integration/screens/food_screen_for_user.dart';
import 'package:api_integration/screens/orders_page_for_user.dart';
import 'package:api_integration/screens/profile_page.dart';
import 'package:api_integration/serrvices/auth_services.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text('Welcome ${username ?? ''}'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: 'Profile',
              waitDuration: const Duration(milliseconds: 300),
              child: IconButton(
                icon: const Icon(Icons.person, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      body: username == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Heading
                  const Text(
                    "User Dashboard",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Browse food and track your orders",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  /// View Food Card
                  _dashboardCard(
                    icon: Icons.fastfood,
                    title: "Browse Food",
                    subtitle: "View all available food items",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoodScreenForUser(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  /// View Orders Card
                  _dashboardCard(
                    icon: Icons.receipt_long,
                    title: "My Orders",
                    subtitle: "Track your previous orders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserOrdersPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  /// Dashboard Card Widget (UI ONLY)
  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.green.shade100,
                child: Icon(icon, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
