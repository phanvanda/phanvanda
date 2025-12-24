import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'auth_repository.dart'; // Import file interface bên trên

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // Constructor cho phép truyền instance vào (hữu ích khi viết Test)
  // Nếu không truyền gì, mặc định dùng FirebaseAuth.instance
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      // In lỗi ra console để debug (hoặc dùng log service nếu có)
      if (kDebugMode) {
        print("Authentication Error: $e");
      }
      // Ném lỗi ra ngoài để UI bắt được và hiển thị thông báo
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}