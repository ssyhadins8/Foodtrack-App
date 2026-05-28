import 'package:flutter/material.dart';

class AppWidget {
  static const Color primary = Color(0xFF2E7D52);

  static TextStyle headlineTextFieldStyle() {
    return const TextStyle(
      color: primary,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle labelTextFieldStyle() {
    return const TextStyle(
      color: Colors.black87,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle hintTextFieldStyle() {
    return const TextStyle(color: Colors.grey, fontSize: 14);
  }

  static TextStyle simpleTextFieldStyle() {
    return const TextStyle(color: Colors.black87, fontSize: 14);
  }

  /// DIGANTI JADI HIJAU (biar konsisten)
  static TextStyle boldTextFieldStyle() {
    return const TextStyle(
      color: primary,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle buttonTextStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }
}
