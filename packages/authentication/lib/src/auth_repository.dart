import 'package:firebase_auth/firebase_auth.dart';

/// Lớp trừu tượng định nghĩa các chức năng xác thực
abstract class AuthRepository {
  /// Luồng dữ liệu lắng nghe trạng thái đăng nhập (Login/Logout)
  Stream<User?> get authStateChanges;

  /// Lấy thông tin user hiện tại (nếu có)
  User? get currentUser;

  /// Hàm đăng nhập ẩn danh (Anonymous)
  Future<User?> signInAnonymously();

  /// Hàm đăng xuất
  Future<void> signOut();
}