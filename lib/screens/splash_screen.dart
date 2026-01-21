import 'dart:async';

import 'package:api_integration/screens/landing_page.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}


class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LandingPage(),
        ),
      );
    });
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Text("welcome to swiggy"),
      ),
    );
  }
}
