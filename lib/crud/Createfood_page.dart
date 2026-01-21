import 'dart:convert';
import 'package:api_integration/serrvices/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreatefoodPage extends StatefulWidget {
  final Map? food;

  const CreatefoodPage({super.key, this.food});

  @override
  State<CreatefoodPage> createState() => _CreatefoodPageState();
}

class _CreatefoodPageState extends State<CreatefoodPage> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController discriptioncontroller = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final food = widget.food;
    if (food != null && food.isNotEmpty) {
      isEdit = true;
      titlecontroller.text = food['title'];
      pricecontroller.text = food['price'].toString();
      discriptioncontroller.text = food['discription'];
    }
  }

  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
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
        title: Text(isEdit ? 'Edit Food' : 'Add Food'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 400,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    /// Page Heading
                    Text(
                      isEdit ? "Update Food Item" : "Create New Food",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Enter food details below",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 24),

                    /// Title
                    TextField(
                      controller: titlecontroller,
                      decoration: _inputStyle("Food title", Icons.fastfood),
                    ),

                    const SizedBox(height: 15),

                    /// Price
                    TextField(
                      controller: pricecontroller,
                      keyboardType: TextInputType.number,
                      decoration: _inputStyle("Price", Icons.currency_rupee),
                    ),

                    const SizedBox(height: 15),

                    /// Description
                    TextField(
                      controller: discriptioncontroller,
                      minLines: 2,
                      maxLines: 6,
                      decoration: _inputStyle("Description", Icons.description),
                    ),

                    const SizedBox(height: 25),

                    /// Submit Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          isEdit ? updateData() : submitData();
                        },
                        child: Text(
                          isEdit ? "Update Food" : "Submit",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // 🔒 LOGIC BELOW (UNCHANGED)
  // =========================

  Future<void> updateData() async {
    final food = widget.food;
    if (food == null) {
      print('you can not call update without food data');
      return;
    }

    final id = food['_id'];
    final title = titlecontroller.text;
    final discription = discriptioncontroller.text;
    final price = pricecontroller.text;

    final body = {"title": title, "discription": discription, "price": price};

    final url = 'http://localhost:3000/api/v1/food/update/$id';
    final uri = Uri.parse(url);
    final token = await AuthService.getToken();

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final responseData = jsonDecode(response.body);
    final message = responseData['message'] ?? 'Something went wrong';

    if (response.statusCode == 200) {
      titlecontroller.clear();
      pricecontroller.clear();
      discriptioncontroller.clear();
      showSuccessMessage(message);
      Navigator.pop(context);
    } else {
      showerrormessage(message);
    }
  }

  Future<void> submitData() async {
    final title = titlecontroller.text;
    final discription = discriptioncontroller.text;
    final price = pricecontroller.text;

    final body = {"title": title, "discription": discription, "price": price};

    final url = 'http://localhost:3000/api/v1/food/create';
    final uri = Uri.parse(url);
    final token = await AuthService.getToken();

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final responseData = jsonDecode(response.body);
    final message = responseData['message'] ?? 'Something went wrong';

    if (response.statusCode == 201) {
      titlecontroller.clear();
      pricecontroller.clear();
      discriptioncontroller.clear();
      showSuccessMessage(message);
    } else {
      showerrormessage(message);
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
