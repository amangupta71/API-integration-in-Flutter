
// import 'package:api_integration/model/user.dart';
// import 'package:api_integration/serrvices/user_api.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<User> users = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchUsers();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Restful Api')),
//       body: ListView.builder(
//         itemCount: users.length,
//         itemBuilder: (context, index) {
//           final user = users[index];
//           final color = user.gender == 'male' ? Colors.blue : Colors.green;

//           return Container(
//             color: color.withOpacity(0.5), // light background tint
//             child: DefaultTextStyle(
//               style: TextStyle(color: color),
//               child: ListTile(
//                 title: Text(user.name.first),
//                 subtitle: Text(user.phone),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> fetchUsers() async {
//     final response = await UserApi.featchUsers();
//     setState(() {
//       users = response;
//     });
//   }
// }
