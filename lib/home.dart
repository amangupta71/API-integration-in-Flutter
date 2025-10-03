import 'dart:convert';

import 'package:api_integration/model/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> users = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restful Api')),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final color = user.gender == 'male' ? Colors.blue : Colors.green;

          return Container(
            color: color.withOpacity(0.5), // light background tint
            child: DefaultTextStyle(
              style: TextStyle(color: color),
              child: ListTile(
                title: Text(user.name.first),
                subtitle: Text(user.phone),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: featchUsers),
    );
  }

  void featchUsers() async {
    print('fetch user called');
    const url = 'https://randomuser.me/api/?results=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    final results = json['results'] as List<dynamic>;
    final transformed = results.map((e) {
      final name = UserName(
        title: e['name']['title'],
        first: e['name']['first'],
        last: e['name']['last'],
      );
      return User(
        cell: e['cell'],
        email: e['email'],
        gender: e['gender'],
        nat: e['nat'],
        phone: e['phone'],
        name: name,
      );
    }).toList();
    setState(() {
      users = transformed;
    });

    print('fetchUsers completed');
  }
}
