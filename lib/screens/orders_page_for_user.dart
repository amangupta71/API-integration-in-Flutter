import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/orders.dart';
import '../serrvices/auth_services.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<UserOrdersPage> createState() => _UserOrdersPageState();
}

class _UserOrdersPageState extends State<UserOrdersPage> {
  List<Order> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserOrders();
  }

  Future<void> fetchUserOrders() async {
    final token = await AuthService.getToken();

    try {
      final response = await http.get(
        Uri.parse("http://localhost:3000/api/v1/food/myorders"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body['orders'];

        setState(() {
          orders = list.map((e) => Order.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (e) {
      isLoading = false;
      print("Order fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text("No orders yet"))
          : RefreshIndicator(
              onRefresh: fetchUserOrders,
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: ${order.id}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} (${order.createdAt.hour}:${order.createdAt.minute})',
                          ),

                          const SizedBox(height: 6),

                          ...order.items.map(
                            (item) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${item.title}  x${item.quantity}"),
                                Text("₹${item.price}"),
                              ],
                            ),
                          ),

                          const Divider(),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "₹${order.total}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Status: ${order.status}",
                            style: const TextStyle(color: Colors.orange),
                          ),

                          Text(
                            "Placed on: ${order.createdAt.toLocal()}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
