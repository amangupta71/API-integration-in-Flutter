import 'dart:convert';
import 'package:api_integration/crud/Createfood_page.dart';
import 'package:api_integration/screens/cart_page.dart';
import 'package:api_integration/serrvices/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:api_integration/model/food.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodScreenForUser extends StatefulWidget {
  const FoodScreenForUser({super.key});

  @override
  State<FoodScreenForUser> createState() => _FoodScreenForUserState();
}

class _FoodScreenForUserState extends State<FoodScreenForUser> {
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
      appBar: AppBar(
        title: const Text('Food Menu'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartPage(initialCart: []),
                ),
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: fetchFoods,
        child: foods.isEmpty
            ? const Center(child: Text("No food available"))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final fooditem = foods[index];

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
                          /// Title + Availability
                          Row(
                            children: [
                              const Icon(Icons.fastfood, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fooditem.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: fooditem.isAvailable
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  fooditem.isAvailable
                                      ? "Available"
                                      : "Unavailable",
                                  style: TextStyle(
                                    color: fooditem.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          /// Description
                          Text(
                            fooditem.discription,
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 12),

                          /// Price + Action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹${fooditem.price}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              fooditem.isAvailable
                                  ? ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        size: 18,
                                      ),
                                      label: const Text("Add"),
                                      onPressed: () {
                                        addToCart(fooditem);
                                      },
                                    )
                                  : const SizedBox(),
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

  Future<void> addToCart(Food food) async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingCart = prefs.getString('cart');
    List<dynamic> cart = existingCart != null ? jsonDecode(existingCart) : [];

    // check if already exists
    int index = cart.indexWhere((item) => item['id'] == food.id);
    if (index >= 0) {
      cart[index]['quantity'] += 1;
    } else {
      cart.add({
        'foodId': food.id,
        'title': food.title,
        'price': food.price,
        'quantity': 1,
      });
    }

    await prefs.setString('cart', jsonEncode(cart));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.title} added to cart'),
        duration: Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> fetchFoods() async {
    final user = await AuthService.getUserData();
    print('fetchFoods called by ${user['username']}');
    // for Android emulator use 10.0.2.2
    const url = 'http://localhost:3000/api/v1/food/getall';

    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['foods'];

        final loadedFoods = data.map((e) => Food.fromJson(e)).toList();

        if (!mounted) return;
        setState(() {
          foods = loadedFoods;
        });
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching foods: $e');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.green)),
    );
    Duration(milliseconds: 10);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showerrormessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.red)),
    );
    Duration(milliseconds: 100);

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
