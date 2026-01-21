import 'dart:convert';
import 'package:api_integration/crud/Createfood_page.dart';
import 'package:api_integration/serrvices/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:api_integration/model/food.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  List<Food> foods = [];

  @override
  void initState() {
    super.initState();
    fetchFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: const Text("Food Items"), elevation: 0),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.green,
      //   onPressed: () async {
      //     await Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => const CreatefoodPage()),
      //     );
      //     fetchFoods();
      //   },
      //   child: const Icon(Icons.add),
      // ),
      body: RefreshIndicator(
        onRefresh: fetchFoods,
        child: foods.isEmpty
            ? const Center(child: Text("No food items available"))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Title + Menu
                          Row(
                            children: [
                              const Icon(Icons.fastfood, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  food.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    navigateToEditpage(food.toJson());
                                  } else if (value == 'delete') {
                                    deleteById(food.id);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          /// Description
                          Text(
                            food.discription,
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 10),

                          /// Price + Availability
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹${food.price}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Row(
                                children: [
                                  Text(
                                    food.isAvailable
                                        ? "Available"
                                        : "Unavailable",
                                    style: TextStyle(
                                      color: food.isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Switch(
                                    value: food.isAvailable,
                                    activeColor: Colors.green,
                                    onChanged: (value) {
                                      toggleAvailability(food.id, value);
                                    },
                                  ),
                                ],
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

  // ================= LOGIC (UNCHANGED) =================

  Future<void> toggleAvailability(String id, bool newValue) async {
    final url = Uri.parse('http://localhost:3000/api/v1/food/update/$id');

    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'isAvailable': newValue}),
      );

      if (response.statusCode == 200) {
        setState(() {
          foods = foods.map((item) {
            if (item.id == id) {
              return Food(
                id: item.id,
                title: item.title,
                price: item.price,
                discription: item.discription,
                isAvailable: newValue,
              );
            }
            return item;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue ? 'Marked as Available' : 'Marked as Unavailable',
            ),
          ),
        );
      } else {
        print('Failed to update availability: ${response.body}');
      }
    } catch (e) {
      print('Error updating availability: $e');
    }
  }

  Future<void> navigateToEditpage(Map fooditem) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatefoodPage(food: fooditem)),
    );
    fetchFoods();
  }

  Future<void> deleteById(String id) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('http://localhost:3000/api/v1/food/delete/$id');

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        foods.removeWhere((item) => item.id == id);
      });
      showSuccessMessage("Deleted successfully");
    } else {
      showErrorMessage("Deletion failed");
    }
  }

  Future<void> fetchFoods() async {
    final token = await AuthService.getToken();
    const url = 'http://localhost:3000/api/v1/food/getall';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['foods'];
      setState(() {
        foods = data.map((e) => Food.fromJson(e)).toList();
      });
    }
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
