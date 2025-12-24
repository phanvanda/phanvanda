import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:main_app/src/cart_screen.dart';
import 'package:main_app/src/product_detail_screen.dart';
import 'package:product/product.dart';
import 'package:shopee_core/shopee_core.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<StatefulWidget> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final ProductRepository _productRepo = ProductRepository();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  List<Product> _allProducts = [];
  List<Product> _displayedProducts = [];
  List<String> _categories = [];
  int _selectedCategoryIndex = 0;
  String _searchKeyword = "";
  bool _isFirstLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose(); // Nhớ giải phóng bộ nhớ
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _categories = _productRepo.getCategories();
    try {
      final products = await _productRepo.getProducts();
      if (mounted) {
        setState(() {
          _allProducts = products;
          _displayedProducts = products;
          _isFirstLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isFirstLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      List<Product> result = _allProducts;

      // Lấy danh sách category từ Repo luôn cho đồng bộ
      if (_selectedCategoryIndex != 0) {
        String selectedCat =
            ProductRepository.categories[_selectedCategoryIndex];
        result = result.where((p) => p.category == selectedCat).toList();
      }

      if (_searchKeyword.isNotEmpty) {
        result = result
            .where(
              (p) =>
                  p.name.toLowerCase().contains(_searchKeyword.toLowerCase()),
            )
            .toList();
      }

      _displayedProducts = result;
    });
  }

  void _onCategoryTap(int index) {
    setState(() => _selectedCategoryIndex = index);
    _applyFilters();
  }

  void _onSearchChanged(String value) {
    _searchKeyword = value;
    _applyFilters();
  }

  void refresh() {
    // 2. Kích hoạt hiệu ứng xoay của RefreshIndicator bằng code
    _refreshIndicatorKey.currentState?.show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _loadData,
          color: Colors.orange,
          child: CustomScrollView(
            slivers: [
              // --- SECTION 1: SEARCH BAR & CART (Inside first SliverToBoxAdapter) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppDimens.r8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: AppTextStyles.body,

                            decoration: InputDecoration(
                              hintText: "Tìm sản phẩm...",
                              hintStyle: AppTextStyles.caption.copyWith(
                                fontSize: 14,
                              ),

                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),

                              suffixIcon: _searchKeyword.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                      onPressed: () {
                                        _searchController
                                            .clear(); // Xóa trên UI
                                        _onSearchChanged(""); // Reset dữ liệu
                                      },
                                    )
                                  : null,

                              // QUAN TRỌNG: Tắt hết viền mặc định của Theme
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,

                              // Tắt màu nền mặc định (vì Container đã có màu rồi)
                              filled: false,

                              // Căn chỉnh chữ cho đẹp
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                        ValueListenableBuilder(
                      // Lắng nghe sự thay đổi từ CartRepository
                      valueListenable: CartRepository().listenable ?? ValueNotifier(Hive.box<CartItem>('shopping_cart')),
                      builder: (context, box, child) {
                        // Tính toán số lượng thực tế ngay khi data thay đổi
                        // Bạn có thể dùng hàm totalItemCount vừa viết, hoặc tính trực tiếp ở đây
                        final int itemCount = CartRepository().totalItemCount;

                        return Stack(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Chuyển sang màn hình Giỏ hàng
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CartScreen()),
                                );
                              },
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: AppColors.primary,
                                size: AppDimens.iconMedium,
                              ),
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
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
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
                          ],
                        );
                      },
                    ),
                     ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // --- SECTION 2: CATEGORIES LIST (New SliverToBoxAdapter) ---
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: .horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = index == _selectedCategoryIndex;
                      return GestureDetector(
                        onTap: () => _onCategoryTap(index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.orange : Colors.white,
                            borderRadius: .circular(20),
                            border: .all(color: Colors.grey.shade300),
                          ),
                          alignment: .center,
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: .bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              _isFirstLoading
                  ? const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _displayedProducts.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(child: Text("Không tìm thấy sản phẩm")),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _buildProductItem(_displayedProducts[index]);
                        }, childCount: _displayedProducts.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return GestureDetector(
      // <--- THÊM CÁI NÀY
      onTap: () {
        // Chuyển sang màn hình chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.r8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.r8),
                ),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
            ),

            // Thông tin
            Padding(
              padding: const EdgeInsets.all(AppDimens.p8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Giá
                  Text(
                    '₫${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),
                  // Địa điểm & Thời gian
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          product.location,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.deliveryTime,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
