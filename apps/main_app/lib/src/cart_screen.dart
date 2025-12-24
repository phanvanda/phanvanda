import 'package:flutter/material.dart';
import 'package:shopee_core/shopee_core.dart';
import 'package:product/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Lấy dữ liệu từ Singleton
  final CartRepository _cartRepo = CartRepository();
  late List<CartItem> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = _cartRepo.items; // Lấy reference
  }

  // --- LOGIC TÍNH TOÁN ---

  // Tổng tiền các món đang chọn
  double get _totalPrice {
    return _cartItems
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Kiểm tra xem có đang chọn tất cả không
  bool get _isAllSelected {
    if (_cartItems.isEmpty) return false;
    return _cartItems.every((item) => item.isSelected);
  }

  // Chọn tất cả / Bỏ chọn tất cả
  void _toggleSelectAll(bool? value) {
    setState(() {
      for (var item in _cartItems) {
        item.isSelected = value ?? false;
      }
    });
  }

  // Xóa các sản phẩm đã chọn
  void _deleteSelected() {
    if (_totalPrice == 0) return; // Chưa chọn gì thì không làm gì

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa các sản phẩm đã chọn?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _cartRepo.removeSelectedItems();
                // Cập nhật lại list sau khi xóa
                _cartItems = _cartRepo.items;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Nền xám nhạt
      // Dùng Stack để đặt thanh BottomBar đè lên nội dung
      body: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              "Giỏ hàng",
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.white,
            elevation: 1,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            actions: [
              // Nút xóa ở góc trên (chỉ hiện khi có chọn sản phẩm)
              if (_cartItems.any((i) => i.isSelected))
                TextButton(
                  onPressed: _deleteSelected,
                  child: const Text(
                    "Xóa",
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
            ],
          ),
          body: _cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(child: _buildCartList()),
                    _buildBottomCheckout(),
                  ],
                ),
        ),
      ),
    );
  }

  // Widget khi giỏ hàng trống
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text("Giỏ hàng trống", style: AppTextStyles.h2),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text("Mua sắm ngay"),
          ),
        ],
      ),
    );
  }

  // Danh sách sản phẩm
  Widget _buildCartList() {
    return ListView.builder(
      itemCount: _cartItems.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: AppColors.white,
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: item.isSelected,
                activeColor: AppColors.primary,
                onChanged: (val) async {
                  await _cartRepo.updateSelection(item.id, val ?? false);

                  // Refresh lại UI
                  setState(() {
                    _cartItems = _cartRepo.items;
                  });
                },
              ),

              // Ảnh
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
                // Image.network(item.product.imageUrl...)
              ),
              const SizedBox(width: 10),

              // Thông tin & Số lượng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₫${item.product.price.toStringAsFixed(0)}",
                      style: AppTextStyles.price,
                    ),
                    const SizedBox(height: 8),

                    // Bộ tăng giảm số lượng
                    Row(
                      children: [
                        _buildQtyBtn("-", () async {
                          await _cartRepo.updateQuantity(
                            item.id,
                            item.quantity - 1,
                          );
                          setState(() => _cartItems = _cartRepo.items);
                        }),
                        Container(
                          width: 40,
                          height: 28,
                          alignment: Alignment.center,
                          color: Colors.grey[300],
                          child: Text("${item.quantity}"),
                        ),
                        _buildQtyBtn("+", () async {
                          await _cartRepo.updateQuantity(
                            item.id,
                            item.quantity + 1,
                          );
                          setState(() => _cartItems = _cartRepo.items);
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQtyBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
        child: Text(label),
      ),
    );
  }

  // Thanh thanh toán dưới cùng
  Widget _buildBottomCheckout() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _isAllSelected,
            activeColor: AppColors.primary,
            onChanged: _toggleSelectAll,
          ),
          const Text("Tất cả"),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("Tổng thanh toán", style: TextStyle(fontSize: 12)),
              Text(
                "₫${_totalPrice.toStringAsFixed(0)}",
                style: AppTextStyles.price.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Nút Mua hàng
          InkWell(
            onTap: _totalPrice > 0
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Chức năng thanh toán đang phát triển"),
                      ),
                    );
                  }
                : null,
            child: Container(
              color: _totalPrice > 0 ? AppColors.primary : Colors.grey,
              width: 120,
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                "Mua hàng (${_cartItems.where((i) => i.isSelected).length})",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
