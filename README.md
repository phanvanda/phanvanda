## Dự án mô phỏng ứng dụng Shopee cơ bản được xây dựng bằng Flutter, sử dụng kiến trúc Monorepo để quản lý module và tách biệt các tầng dữ liệu (Data Layer) và giao diện (UI Layer).

# Cấu trúc dự án (Architecture)
# Dự án sử dụng công cụ Melos để quản lý Monorepo. Cấu trúc chia làm 2 phần chính: apps và packages.

<code>
shopee_monorepo/
├── apps/
│   └── main_app/          # Ứng dụng chính (Mobile App)
│       ├── lib/
│       │   ├── src/
│       │   │   ├── home_tab.dart      # Màn hình trang chủ
|       |   |   ├── user_tab.dart      # Màn hình thông tin user
│       │   │   ├── product_detail.dart # Màn hình chi tiết
│       │   │   └── cart_screen.dart   # Màn hình giỏ hàng
│       │   └── main.dart
│       └── pubspec.yaml
│
└── packages/
    ├── shopee_core/        # UI Kit & Design System
    │   ├── lib/
    │   │   └── theme/      # Màu sắc, Font chữ, Kích thước chuẩn
    │   └── pubspec.yaml
    │
    └── product/            # Data Layer (Logic & Database)
    │    ├── lib/
    │    │   ├── models/    # Product & CartItem Model (Hive Types)
    │    │   └── repository/# Xử lý dữ liệu (Mock API, Hive Storage)
    │    └── pubspec.yaml
    │   
    └── authentication/     # Authen Layer (Logic & Database)
        ├── lib/
        │   └── repository/ # Login Firebase
        └── pubspec.yaml
</code>

# Tính năng chính (Features)
  1. Authentication (Xác thực)
     - Đăng nhập bằng Email/Password (Firebase Auth).
     - Đăng nhập bằng Google (Google Sign-In).
     - Tự động chuyển màn hình khi đã đăng nhập (StreamBuilder).
  3. Home Screen (Trang chủ)
     - Search: Tìm kiếm sản phẩm realtime, có nút xóa text.
     - Filter: Lọc sản phẩm theo danh mục (Category).
     - Pull-to-refresh: Kéo xuống để tải lại dữ liệu.
     - Badge: Icon giỏ hàng hiển thị số lượng thực tế theo thời gian thực.
  5. Product Detail (Chi tiết sản phẩm)
     - Hiệu ứng SliverAppBar (ảnh trượt, header ghim lại).
     - Thêm sản phẩm vào giỏ hàng.
     - Giao diện BottomNavigationBar tùy chỉnh (không bị che bởi Safe Area).
  6. Cart (Giỏ hàng - Local Storage)
     - Lưu trữ giỏ hàng offline bằng Hive (Tắt app mở lại vẫn còn).
     - Chọn từng sản phẩm hoặc chọn tất cả.
     - Tăng/giảm số lượng.
     - Xóa sản phẩm đã chọn.
     - Tính tổng tiền tự động.

# Kỹ thuật & Thư viện sử dụng (Tech Stack)
  - Ngôn ngữ: Dart, Flutter.
  - Quản lý Monorepo: Melos.
  - Local Database: Hive (NoSQL, tốc độ cao).
  - Backend: Firebase (Auth).
  - State Management: ValueListenableBuilder (Hive): Lắng nghe thay đổi DB realtime.
  - setState: Quản lý trạng thái UI cục bộ.
  - GlobalKey: Điều khiển widget con từ widget cha (RefreshIndicator).

# Yêu cầu tiên quyết
  - Flutter SDK (>= 3.0.0).
  - Melos (dart pub global activate melos).
