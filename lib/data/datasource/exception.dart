import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HandleException {
  static void handleException(String code, {String? message}) {
    Get.snackbar(
      'Error',
      code,
      titleText: const Text(
        'Error',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message ?? '',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}