import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserTab extends StatelessWidget {
  const UserTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Thông tin cá nhân")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                "Email: ${user?.email ?? 'Chưa cập nhật'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Nút Đăng xuất nằm ở đây
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Đăng xuất"),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // Sau khi sign out, StreamBuilder ở main.dart sẽ tự chuyển về trang Login
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
