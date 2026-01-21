import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../serrvices/auth_services.dart';

class CartPage extends StatefulWidget {
  final List<dynamic> initialCart;
  const CartPage({super.key, required this.initialCart});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cart = [];

  final TextEditingController couponController = TextEditingController();

  double couponDiscount = 0;
  String appliedCoupon = "";
  bool isApplyingCoupon = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  /* ---------------- CART STORAGE ---------------- */

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCart = prefs.getString("cart");

    if (!mounted) return;

    if (savedCart != null) {
      cart = jsonDecode(savedCart);
    } else {
      cart = widget.initialCart.map((item) {
        return {
          "foodId": item["foodId"],
          "title": item["title"],
          "price": item["price"],
          "quantity": item["quantity"] ?? 1,
        };
      }).toList();
    }
    setState(() {});
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cart", jsonEncode(cart));
  }

  /* ---------------- PRICE CALC ---------------- */

  double get subtotal =>
      cart.fold(0, (sum, item) => sum + item['price'] * item['quantity']);

  double get gst => subtotal * 0.10;
  double get deliveryFee => 20;

  double get total {
    final t = subtotal + gst + deliveryFee - couponDiscount;
    return t < 0 ? 0 : t; // safety
  }

  /* ---------------- CART ACTIONS ---------------- */

  void updateQuantity(int index, int delta) async {
    cart[index]['quantity'] = (cart[index]['quantity'] + delta).clamp(1, 99);
    await _saveCart();

    // reset coupon if cart changes
    couponDiscount = 0;
    appliedCoupon = "";

    if (mounted) setState(() {});
  }

  Future<void> removeItem(int index) async {
    cart.removeAt(index);
    couponDiscount = 0;
    appliedCoupon = "";
    await _saveCart();
    if (mounted) setState(() {});
  }

  /* ---------------- APPLY COUPON ---------------- */

  Future<void> applyCoupon() async {
    if (couponController.text.trim().isEmpty) return;

    setState(() => isApplyingCoupon = true);

    final user = await AuthService.getUserData();
    final token = user["token"];

    try {
      final response = await http.post(
        Uri.parse("http://localhost/api/v1/coupon/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "code": couponController.text.trim(),
          "cartTotal": subtotal,
          "userId": user["id"],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          couponDiscount = (data["discount"] ?? 0).toDouble();
          appliedCoupon = data["couponCode"];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Coupon Applied 🎉")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Invalid coupon")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coupon apply failed")),
      );
    } finally {
      setState(() => isApplyingCoupon = false);
    }
  }

  /* ---------------- PLACE ORDER ---------------- */

  Future<void> placeOrder() async {
    if (cart.isEmpty) return;

    final token = await AuthService.getToken();

    final formattedCart = cart.map((item) {
      return {
        "foodId": item["foodId"],
        "price": item["price"],
        "quantity": item["quantity"],
      };
    }).toList();

    final body = jsonEncode({
      "cart": formattedCart,
      "couponCode": appliedCoupon,
      "discount": couponDiscount,
    });

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/v1/food/placeorder"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("cart");

        setState(() {
          cart.clear();
          couponDiscount = 0;
          appliedCoupon = "";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🎉 Order placed successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order error")),
      );
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: cart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (_, index) {
                      final item = cart[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(item['title']),
                          subtitle: Text("₹${item['price']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => updateQuantity(index, -1),
                              ),
                              Text("${item['quantity']}"),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => updateQuantity(index, 1),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Coupon
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: couponController,
                              decoration: const InputDecoration(
                                hintText: "Enter coupon code",
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: isApplyingCoupon ? null : applyCoupon,
                            child: isApplyingCoupon
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text("Apply"),
                          ),
                        ],
                      ),

                      if (appliedCoupon.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "Coupon ($appliedCoupon): -₹${couponDiscount.toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),

                      const Divider(),

                      Text("Subtotal: ₹${subtotal.toStringAsFixed(2)}"),
                      Text("GST (10%): ₹${gst.toStringAsFixed(2)}"),
                      const Text("Delivery Fee: ₹20"),
                      const Divider(),
                      Text(
                        "Total: ₹${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                        onPressed: placeOrder,
                        icon: const Icon(Icons.payment),
                        label: const Text("Place Order"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
