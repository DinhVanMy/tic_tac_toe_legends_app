import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showExitConfirmationDialog() async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Thoát Game'),
      content: const Text('Bạn có chắc muốn thoát game đang chơi không?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Tiếp tục chơi'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Thoát'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
  return result ?? false;
}