import 'dart:math';
import 'package:product/product.dart'; 

class ProductRepository {
  static const List<String> categories = [
    "Tất cả",
    "Điện thoại",
    "Laptop",
    "Thời trang",
    "Giày dép",
    "Đồng hồ",
    "Sách",
  ];

  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    List<Product> products = [];
    final random = Random();

    // Logic sinh data cũ của bạn
    for (int i = 1; i < categories.length; i++) {
      String catName = categories[i];
      int productCount = 5 + random.nextInt(11);

      for (int j = 0; j < productCount; j++) {
        products.add(
          Product(
            id: "${catName}_$j",
            name: "$catName Chính Hãng Mẫu $j",
            price: (100 + random.nextInt(900)) * 1000,
            category: catName,
            imageUrl: "https://via.placeholder.com/150",
            location: "Hải Phòng",
            deliveryTime: "2-3 ngày",
            sold: (10 + random.nextInt(200)) * 1000,
          ),
        );
      }
    }

    // Xáo trộn
    products.shuffle();
    return products;
  }

  List<String> getCategories() {
    return categories;
  }
}
