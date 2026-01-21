class User {
  final String username;
  final String email;
  final String usertype;
  final String token;
  final String? phone; // optional
  final String? address; // optional

  User({
    required this.username,
    required this.email,
    required this.usertype,
    required this.token,
    this.phone,
    this.address,
  });

  // Factory to create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      usertype: json['usertype'] ?? 'client',
      token: json['token'] ?? '',
      phone: json['phone'],
      address: json['address'],
    );
  }

  // Convert User object back to JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'usertype': usertype,
      'token': token,
      'phone': phone,
      'address': address,
    };
  }
}
