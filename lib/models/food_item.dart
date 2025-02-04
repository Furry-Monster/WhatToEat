class FoodItem {
  final String name;
  final DateTime timestamp;
  final double? price;

  const FoodItem({
    required this.name,
    required this.timestamp,
    this.price,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'timestamp': timestamp.toIso8601String(),
        'price': price,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        name: json['name'],
        timestamp: DateTime.parse(json['timestamp']),
        price: json['price']?.toDouble(),
      );

  String get formattedDate {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
