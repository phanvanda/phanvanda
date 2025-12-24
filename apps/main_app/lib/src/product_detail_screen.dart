import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:main_app/src/cart_screen.dart';
import 'package:shopee_core/shopee_core.dart'; // Import giao diện chuẩn
import 'package:product/product.dart'; // Import model Product

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Giả lập trạng thái yêu thích
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Nền xám nhạt
      // Dùng Stack để đặt thanh BottomBar đè lên nội dung
      body: Column(
        children: [
          // --- PHẦN 1: HEADER & NỘI DUNG (Cuộn được) ---
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(child: _buildProductInfo()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimens.p12),
                ),
                SliverToBoxAdapter(child: _buildDescription()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ), // Khoảng trống cho BottomBar
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar()
    );
  }

  // 1. Ảnh sản phẩm & Header trong suốt
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.black26,
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Bắt đầu lắng nghe thay đổi giỏ hàng
        ValueListenableBuilder(
          // Kiểm tra null an toàn: Nếu chưa init thì trả về notifier rỗng để không crash
          valueListenable:
              CartRepository().listenable ??
              ValueNotifier(Hive.box<CartItem>('shopping_cart')),
          builder: (context, box, child) {
            // Tính toán số lượng
            final int itemCount = CartRepository().totalItemCount;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),

                // Badge số lượng (Chỉ hiện khi > 0)
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: AppColors.white, width: 1.5),
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth:
                            20, // Tăng nhẹ kích thước để số hiển thị rõ hơn
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          itemCount > 99 ? '99+' : '$itemCount',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),

        // Khoảng cách lề phải
        const SizedBox(width: AppDimens.p8),
      ],

      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Center(
                child: Icon(Icons.image, size: 100, color: Colors.grey),
              ),
              // Image.network(widget.product.imageUrl, fit: BoxFit.cover),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Thông tin cơ bản (Giá, Tên, Rating)
  Widget _buildProductInfo() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Giá tiền
          Text(
            "₫${widget.product.price.toStringAsFixed(0)}",
            style: AppTextStyles.price.copyWith(fontSize: 24),
          ),
          const SizedBox(height: AppDimens.p8),

          // Tên sản phẩm
          Text(
            widget.product.name,
            style: AppTextStyles.h2.copyWith(fontSize: 18),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimens.p12),

          // Rating & Đã bán
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              const Text("4.9", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(width: 1, height: 12, color: Colors.grey),
              const SizedBox(width: 8),
              Text("Đã bán 1.2k", style: AppTextStyles.caption),
              const Spacer(),
              // Nút tim
              GestureDetector(
                onTap: () => setState(() => _isLiked = !_isLiked),
                child: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? AppColors.primary : Colors.grey,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Mô tả sản phẩm
  Widget _buildDescription() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mô tả sản phẩm", style: AppTextStyles.h2),
          const SizedBox(height: AppDimens.p12),
          Text(
            "Đây là sản phẩm chính hãng ${widget.product.name}.\n"
            "• Chất lượng đảm bảo 100%\n"
            "• Bảo hành 12 tháng\n"
            "• Giao hàng toàn quốc\n\n"
            "Mua ngay hôm nay để nhận ưu đãi giảm giá đặc biệt từ Shopee!",
            style: AppTextStyles.body.copyWith(
              height: 1.5,
            ), // Giãn dòng cho dễ đọc
          ),
        ],
      ),
    );
  }

  // 4. Thanh Bottom Bar (Thêm giỏ hàng / Mua ngay)
  Widget _buildBottomBar() {
    return Container(
      // 1. Màu nền và bóng đổ nằm ở Container ngoài cùng
      // Nó sẽ phủ kín cả vùng Safe Area dưới đáy
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      // 2. SafeArea nằm BÊN TRONG Container
      // Để đẩy các nút bấm lên trên vạch Home Indicator, nhưng nền vẫn trắng
      child: SafeArea(
        child: SizedBox(
          height: 60, // Chiều cao cố định cho phần nội dung nút bấm
          child: Row(
            children: [
              // Nút Chat
              _buildIconBtn(Icons.chat_bubble_outline, "Chat", Colors.teal),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              
              // Nút Thêm giỏ hàng
              _buildIconBtn(
                Icons.add_shopping_cart, 
                "Thêm giỏ", 
                AppColors.textPrimary, 
                onTap: () {
                  CartRepository().addToCart(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đã thêm vào giỏ hàng!"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              ),
              
              // Nút Mua ngay
              Expanded(
                child: Container(
                  color: AppColors.primary,
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: const Text(
                    "Mua ngay",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget con dùng cho BottomBar
  Widget _buildIconBtn(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        width: 80,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
