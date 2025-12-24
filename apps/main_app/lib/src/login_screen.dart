import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Quản lý input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Trạng thái loading & ẩn hiện mật khẩu
  bool _isLoading = false;
  bool _isObscure = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // 1. Xử lý Đăng nhập Email/Password
  Future<void> _handleEmailLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showError("Vui lòng nhập Email và Mật khẩu");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Thành công -> StreamBuilder ở main.dart tự chuyển màn hình
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _showError("Lỗi không xác định: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Xử lý Đăng nhập Google (Gmail)
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      // Kích hoạt luồng đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      // Nếu người dùng hủy chọn tài khoản
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Lấy thông tin xác thực từ request trên
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Tạo credential mới cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase bằng credential đó
      await FirebaseAuth.instance.signInWithCredential(credential);
      // Thành công -> StreamBuilder tự chuyển màn hình

    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _showError("Lỗi đăng nhập Google: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Tiện ích hiển thị lỗi
  void _handleFirebaseError(FirebaseAuthException e) {
    String message = "Đăng nhập thất bại";
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
        message = "Tài khoản hoặc mật khẩu không đúng.";
        break;
      case 'wrong-password':
        message = "Sai mật khẩu.";
        break;
      case 'invalid-email':
        message = "Email không hợp lệ.";
        break;
      case 'user-disabled':
        message = "Tài khoản này đã bị vô hiệu hóa.";
        break;
      default:
        message = "Lỗi: ${e.message}";
    }
    _showError(message);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Logo ---
              const Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                "Đăng Nhập",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // --- Input Email ---
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // --- Input Password ---
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- Nút Đăng nhập Email ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),
              
              // --- Hoặc đăng nhập bằng Google ---
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Hoặc"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.red), // Icon Google tạm
                  label: const Text("Tiếp tục với Google", style: TextStyle(fontSize: 16)),
                ),
              ),
              
              const SizedBox(height: 24),
              // Nút Đăng ký (Optional)
              TextButton(
                onPressed: () {
                   // Navigate qua màn hình đăng ký nếu có
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text("Chức năng Đăng ký chưa cài đặt")),
                   );
                },
                child: const Text("Chưa có tài khoản? Đăng ký ngay"),
              )
            ],
          ),
        ),
      ),
    );
  }
}