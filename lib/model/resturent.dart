class Food {
  final String dishname;
  final String dispic;
  final int price;

  Food({required this.dishname, required this.dispic, required this.price});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      dishname: json['dishname'] ?? '',
      dispic: json['dispic'] ?? '',
      price: json['price'] ?? 0,
    );
  }
}

class Resturent {
  final String id;
  final String title;
  final String time;
  final bool isopen;
  final List<Food> foods;

  Resturent({
    required this.id,
    required this.title,
    required this.time,
    required this.isopen,
    required this.foods,
  });

  factory Resturent.fromJson(Map<String, dynamic> json) {
    final foodsJson = json['foods'] as List<dynamic>? ?? [];
    return Resturent(
      id: json['_id'],
      title: json['title'],
      time: json['time'],
      isopen: json['isopen'],
      foods: foodsJson.map((f) => Food.fromJson(f)).toList(),
    );
  }
}
