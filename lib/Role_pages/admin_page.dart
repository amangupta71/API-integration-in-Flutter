import 'package:api_integration/crud/Createfood_page.dart';
import 'package:api_integration/screens/analysis/sales_analytic_page.dart';
import 'package:api_integration/screens/analysis/user_analytics%20page';
import 'package:api_integration/screens/coupon_page.dart';
import 'package:api_integration/screens/food_screen_for_admin.dart';
import 'package:api_integration/screens/orders_page_for_admin.dart';
import 'package:api_integration/screens/profile_page.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Welcome Admin'),
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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Page Heading
            const Text(
              "Admin Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Manage food items and orders",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// Dashboard Cards
            _dashboardCard(
              icon: Icons.add_circle_outline,
              title: "Add New Food",
              subtitle: "Create a new food item",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatefoodPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            _dashboardCard(
              icon: Icons.fastfood,
              title: "View All Food",
              subtitle: "Edit or manage food items",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _dashboardCard(
              icon: Icons.receipt_long,
              title: "View Orders",
              subtitle: "Check all customer orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrdersPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            _dashboardCard(
              icon: Icons.delivery_dining_outlined,
              title: "Coupon ",
              subtitle: "manage Coupons here",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateCouponPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            _dashboardCard(
              icon: Icons.analytics,
              title: "Sales Analysis",
              subtitle: "view all sells and orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnalyticsPage()),
                );
              },
            ),

            const SizedBox(height: 12),
            _dashboardCard(
              icon: Icons.analytics,
              title: "User Analysis",
              subtitle: "view all users activity",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersAnalyticsPage()),
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
