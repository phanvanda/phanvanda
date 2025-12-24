import 'package:hive/hive.dart';
import 'product_model.dart';

part 'cart_model.g.dart'; // File này sẽ được sinh tự động

@HiveType(typeId: 1) // ID duy nhất cho CartItem
class CartItem {
  @HiveField(0)
  final Product product;
  
  @HiveField(1)
  int quantity;
  
  @HiveField(2)
  bool isSelected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = false,
  });

  String get id => product.id;
  double get totalPrice => product.price * quantity;
}