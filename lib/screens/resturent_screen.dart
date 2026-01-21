import 'dart:convert';
import 'package:api_integration/model/resturent.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResturentScreen extends StatefulWidget {
  const ResturentScreen({super.key});

  @override
  State<ResturentScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<ResturentScreen> {
  List<Resturent> resturents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food List')),
      body: ListView.builder(
        itemCount: resturents.length,
        itemBuilder: (context, index) {
          final rest = resturents[index];
          // final color = food.isAvailable == true ? Colors.green : Colors.red;
          return Card(
            elevation: 4, // shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                leading: const Icon(Icons.restaurant),
                title: Text(rest.title),
                subtitle: Text('Time: ${rest.time}  |  Open: ${rest.isopen}'),
                children: [
                  ...rest.foods.map(
                    (food) => ListTile(
                      leading: const Icon(Icons.fastfood),
                      title: Text(food.dishname),
                      subtitle: Text('₹${food.price}'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchResturents,
        child: const Icon(Icons.download),
      ),
    );
  }

  Future<void> fetchResturents() async {
    print('fetchResturents called');
    // for Android emulator use 10.0.2.2
    const url = 'http://localhost:3000/api/v1/resturent/getAll';

    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['resturent'];

        final loaded = data.map((e) => Resturent.fromJson(e)).toList();

        setState(() {
          resturents = loaded;
        });
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetch Resturents : $e');
    }
  }
}
