import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../serrvices/auth_services.dart';

class CreateCouponPage extends StatefulWidget {
  const CreateCouponPage({super.key});

  @override
  State<CreateCouponPage> createState() => _CreateCouponPageState();
}

class _CreateCouponPageState extends State<CreateCouponPage> {
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _expiryController = TextEditingController();

  String discountType = "flat";
  bool firstOrderOnly = false;
  bool isLoading = false;
Future<void> createCoupon() async {
  setState(() => isLoading = true);

  try {
    final token = await AuthService.getToken();

    final body = {
      "code": _codeController.text
          .trim()
          .replaceAll(" ", "")
          .toUpperCase(),
      "discountType": discountType,
      "discountValue": int.parse(_discountValueController.text),
      "minOrderValue": int.tryParse(_minOrderController.text) ?? 0,
      "firstOrderOnly": firstOrderOnly,
      "expiryDate": _expiryController.text,
    };

    final response = await http.post(
      Uri.parse("http://10.0.2.2:3000/api/v1/coupon/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Coupon created successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Coupon")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: "Coupon Code"),
            ),

            DropdownButton<String>(
              value: discountType,
              items: const [
                DropdownMenuItem(value: "flat", child: Text("Flat Discount")),
                DropdownMenuItem(value: "percent", child: Text("Percent Discount")),
              ],
              onChanged: (v) => setState(() => discountType = v!),
            ),

            TextField(
              controller: _discountValueController,
              decoration: const InputDecoration(labelText: "Discount Value"),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: _minOrderController,
              decoration: const InputDecoration(labelText: "Min Order Value"),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: _expiryController,
              decoration: const InputDecoration(
                labelText: "Expiry Date (YYYY-MM-DD)",
              ),
            ),

            SwitchListTile(
              value: firstOrderOnly,
              onChanged: (v) => setState(() => firstOrderOnly = v),
              title: const Text("First Order Only"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : createCoupon,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create Coupon"),
            ),
          ],
        ),
      ),
    );
  }
}
