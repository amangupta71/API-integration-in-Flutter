class OrderItem {
  final String title;
  final int price;
  final int quantity;

  OrderItem({
    required this.title,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final food = json['foodId'];

    return OrderItem(
      title: food != null ? food['title'] : 'Deleted Food',
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}


class Order {
  final String id;
  final List<OrderItem> items;
  final int total;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
     required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      items: (json['food'] as List)
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      total: json['payment'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
