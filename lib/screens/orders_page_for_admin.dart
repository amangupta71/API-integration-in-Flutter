import 'dart:convert';
import 'dart:async';

import 'package:api_integration/model/orders.dart';
import 'package:api_integration/serrvices/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List<Order> orders = [];
  Timer? _refreshTimer;
  @override
  void initState() {
    super.initState();
    fetchorder();

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) fetchorder();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order List')),
      body: orders.isEmpty
          ? const Center(
              child: Text('No orders found', style: TextStyle(fontSize: 16)),
            )
          : RefreshIndicator(
              onRefresh: fetchorder,
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];

                  return Card(
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Order ID
                          Text(
                            'Order ID: ${order.id} ',

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} (${order.createdAt.hour}:${order.createdAt.minute})',
                          ),

                          const SizedBox(height: 8),

                          /// Items
                          ...order.items.map((item) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.title} x${item.quantity}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '₹${item.price}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            );
                          }).toList(),

                          const Divider(),

                          /// Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${order.total}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          /// Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status: ${order.status}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: order.status == 'preparing'
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),

                              /// Admin Toggle
                              Switch(
                                value: order.status == 'on the way',
                                activeColor: Colors.green,

                                /// Only allow toggle if preparing
                                onChanged: order.status == 'preparing'
                                    ? (value) {
                                        updateOrderStatus(
                                          order.id,
                                          'on the way',
                                        );
                                      }
                                    : null, // disable switch
                              ),
                            ],
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

  Future<void> fetchorder() async {
    final token = await AuthService.getToken();

    const url = 'http://localhost:3000/api/v1/food/getallorders';
    final uri = Uri.parse(url);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('STATUS CODE: ${response.statusCode} -> fetchorder by admin ');
      //print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final List<dynamic> data = body['orders'];

        final loadedOrders = data.map((e) => Order.fromJson(e)).toList();
        loadedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          orders = loadedOrders;
        });
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final token = await AuthService.getToken();

    final url = Uri.parse(
      'http://localhost:3000/api/v1/food/orderstatus/$orderId',
    );

    try {
      final response = await http.post(
        // 🔥 POST, not PUT
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );

      print('UPDATE STATUS CODE: ${response.statusCode}');
      print('UPDATE BODY: ${response.body}');

      if (response.statusCode == 200) {
        showSuccessMessage("Order marked as On the Way");
        fetchorder();
      } else {
        showerrormessage("Failed to update order");
      }
    } catch (e) {
      showerrormessage("Error updating order");
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.green)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showerrormessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.red)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
