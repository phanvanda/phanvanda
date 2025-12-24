import 'package:flutter/material.dart';

class AppColors {
  // Private constructor để chặn việc khởi tạo class này (new AppColors)
  AppColors._();

  // Màu thương hiệu (Shopee Orange)
  static const Color primary = Color(0xFFEE4D2D); 
  static const Color primaryDark = Color(0xFFC93D22);

  // Màu nền
  static const Color background = Color(0xFFF5F5F5); // Xám nhạt
  static const Color white = Colors.white;

  // Màu chữ
  static const Color textPrimary = Color(0xFF222222); // Đen đậm
  static const Color textSecondary = Color(0xFF757575); // Xám chữ phụ
  static const Color textPrice = Color(0xFFEE4D2D); // Màu giá tiền

  // Màu viền / Divider
  static const Color border = Color(0xFFE0E0E0);
}