// Đoạn code này thêm vào trang MainHome.dart trong phần drawer hoặc menu profile

// Import các thư viện cần thiết
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Class để kiểm tra và hiển thị nút Admin
class AdminAccessWidget extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminAccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIsAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasData && snapshot.data == true) {
          return _buildAdminButton();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAdminButton() {
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.deepPurpleAccent,
            ),
          ),
          title: const Text(
            'Quản Trị Viên',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: const Text('Truy cập bảng điều khiển admin'),
          onTap: () {
            Get.toNamed('/admin');
          },
        ),
      ],
    );
  }

  Future<bool> _checkIsAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        return false;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['role'] == 'admin';
    } catch (e) {
      print('Error checking admin role: $e');
      return false;
    }
  }
}

// Thêm đoạn này vào Drawer hoặc menu profile của MainHome.dart
// ...
// Các menu item khác
// ...
// AdminAccessWidget(), // Thêm dòng này
// ...