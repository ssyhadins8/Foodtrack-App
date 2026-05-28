import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  // Primary palette (dark theme)
  static const primary = Color(0xFF1E293B); // dark blue-gray
  static const secondary = Color(0xFF0F172A); // deeper navy
  static const tertiary = Color(0xFF111827); // near black
  // Accent colors
  static const accentOrange = Color(0xFFF97316); // vibrant orange
  static const cyan = Color(0xFF00D4FF);
  static const cyanLight = Color(0xFFE0F9FF);
  static const cyanMid = Color(0xFF80EAFF);

  // Background
  static const bg = Color(0xFFF0F4F8);
  static const bgAlt = Color(0xFFE8F0F7);
  static const surface = Colors.white;

  // Text
  static const textPrimary = Color(0xFF0D1B2A);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  // Status
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);

  // Gradients
  static const headerGradient = LinearGradient(
    colors: [primary, secondary, tertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const headerGradientV = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF0E3460), Color(0xFF1B3A5C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFF1B3A5C), Color(0xFF0E3460)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cyan accent gradient
  static const cyanGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background gradient untuk pages
  static const bgGradient = LinearGradient(
    colors: [Color(0xFFF0F4F8), Color(0xFFE4EDF5), Color(0xFFEFF7FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Premium design extras
  static const Color orbCyan = Color(0x0D00D4FF); // 5% opacity cyan
  static const Color orbIndigo = Color(0x0D4F46E5); // 5% opacity indigo
  static const Color orbAmber = Color(0x08F59E0B); // 3% opacity amber
  static const Color gridColor = Color(0x080D1B2A); // ~3% opacity dot grid

  // Standard premium glassmorphism card decoration
  static BoxDecoration premiumCardDeco({
    Color? color,
    double borderRadius = 16,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      // Use semi‑transparent white for glass effect in dark mode
      color: color ?? Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder
          ? Border.all(color: Colors.white.withOpacity(0.6), width: 1.0)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
