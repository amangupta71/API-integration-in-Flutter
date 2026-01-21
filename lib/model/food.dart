class Food {
  final String id;
  final String title;
  final int price;
  final String discription;
  final bool isAvailable;

  Food({
    required this.id,
    required this.title,
    required this.price,
    required this.discription,
    required this.isAvailable,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id'],
      title: json['title'],
      price: json['price'],
      discription: json['discription'],
      isAvailable: json['isAvailable'],
    );
  }
  // ✅ Add this method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'price': price,
      'discription': discription,
      'isAvailable': isAvailable,
    };
  }
}
