// lib/services/auth_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Keys for stored values
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _usertypeKey = 'usertype';
  static const String _emailKey = 'email';
  static const String _idKey = 'user_id';

  // Save user data
  static Future<void> saveUserData({
    required String token,
    required String username,
    required String usertype,
    required String email,
    required String id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_usertypeKey, usertype);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_idKey, id);
  }

  // Retrieve saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Retrieve full user info
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'username': prefs.getString(_usernameKey),
      'usertype': prefs.getString(_usertypeKey),
      'email': prefs.getString(_emailKey),
      'id': prefs.getString(_idKey),
    };
  }

  //Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Clear data on logout
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class CartService {
  static const String _cartKey = 'user_cart';

  // Save cart list to SharedPreferences
  static Future<void> saveCart(List<Map<String, dynamic>> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(cart);
    await prefs.setString(_cartKey, cartJson);
  }

  // Load cart list from SharedPreferences
  static Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);

    if (cartString == null) return [];
    final decoded = jsonDecode(cartString) as List;
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Clear cart
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}



