import 'package:flutter/material.dart';
import 'package:foodtrack/theme/app_colors.dart';

/// Menampilkan snackbar dengan style konsisten.
///
/// [context] - BuildContext tempat menampilkan snackbar.
/// [msg] - Pesan yang akan ditampilkan.
/// [error] - Jika true, snackbar berwarna merah (error),
///          jika false, berwarna hijau (sukses).
void showAppSnack(BuildContext context, String msg, {bool error = true}) {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            error ? Icons.error_rounded : Icons.check_circle_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ],
      ),
      backgroundColor: error ? AppColors.danger : AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ),
  );
}
