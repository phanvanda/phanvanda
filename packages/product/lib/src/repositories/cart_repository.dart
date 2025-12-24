import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:product/product.dart';

class CartRepository {
  static final CartRepository _instance = CartRepository._internal();
  factory CartRepository() => _instance;
  CartRepository._internal();

  static const String _boxName = 'shopping_cart';
  Box<CartItem>? _cartBox;

  // Hàm khởi tạo (Cần gọi 1 lần lúc mở App)
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(CartItemAdapter());

    // Mở hộp dữ liệu (Giống mở connection Database)
    _cartBox = await Hive.openBox<CartItem>(_boxName);
  }

  int get totalItemCount {
    final box = _cartBox; // Gán ra biến local
    if (box == null) {
      return 0; // Xử lý trường hợp null
    }
    return box.values.fold(0, (sum, item) => sum + item.quantity);
  }

  ValueListenable<Box<CartItem>>? get listenable => _cartBox?.listenable();

  // Lấy danh sách (Lấy trực tiếp từ Box)
  List<CartItem> get items => _cartBox?.values.toList() ?? [];

  // Thêm vào giỏ
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_cartBox == null) await init();

    // Tìm xem đã có chưa
    final existingItem = items.firstWhere(
      (item) => item.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      // Đã có -> Tăng số lượng và update lại vào Box
      existingItem.quantity += quantity;
      // Trong Hive, key của object thường là index hoặc do mình tự đặt.
      // Để đơn giản, ta lưu lại object mới đè lên key cũ.
      // Tuy nhiên, cách dễ nhất với List là xóa cũ thêm mới hoặc dùng key.
      // Cách tối ưu với Hive: Dùng key là product.id
      await _cartBox?.put(product.id, existingItem);
    } else {
      // Chưa có -> Thêm mới
      final newItem = CartItem(product: product, quantity: quantity);
      await _cartBox?.put(product.id, newItem);
    }
  }

  // Cập nhật số lượng (Tăng/Giảm)
  Future<void> updateQuantity(String productId, int quantity) async {
    final item = _cartBox!.get(productId);
    if (item != null) {
      item.quantity = quantity;
      await _cartBox?.put(productId, item);
    }
  }

  // Cập nhật trạng thái chọn (Checkbox)
  Future<void> updateSelection(String productId, bool isSelected) async {
    final item = _cartBox!.get(productId);
    if (item != null) {
      item.isSelected = isSelected;
      await _cartBox?.put(productId, item);
    }
  }

  // Chọn tất cả
  Future<void> selectAll(bool isSelected) async {
    for (var item in items) {
      item.isSelected = isSelected;
      await _cartBox?.put(item.id, item);
    }
  }

  // Xóa sản phẩm
  Future<void> removeProduct(String productId) async {
    await _cartBox?.delete(productId);
  }

  // Xóa các sản phẩm đã chọn (Sau khi mua xong)
  Future<void> removeSelectedItems() async {
    final keysToDelete = items
        .where((i) => i.isSelected)
        .map((i) => i.id)
        .toList();
    await _cartBox?.deleteAll(keysToDelete);
  }

  // Xóa sạch giỏ hàng
  Future<void> clear() async {
    await _cartBox?.clear();
  }
}
