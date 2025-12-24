import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String imageUrl;
  @HiveField(3)
  final String location;
  @HiveField(4)
  final String deliveryTime;
  @HiveField(5)
  final double price;
  @HiveField(6)
  final int sold;
  @HiveField(7)
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.deliveryTime,
    required this.price,
    required this.sold,
    required this.category
  });

  // Hàm chuyển từ JSON sang Object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String,
      deliveryTime: json['deliveryTime'] as String,
      price: (json['price'] as num).toDouble(),
      sold: json['sold'] as int,
      category: json['category'] as String
    );
  }
}
