import 'package:flutter/material.dart';

/// Centralized color palette for the ServiceHub app.
class AppColors {
  AppColors._(); // Prevent instantiation

  // ─── Primary Brand Colors ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF); // Vibrant indigo-purple
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  // ─── Accent / Secondary ────────────────────────────────────────────────────
  static const Color accent = Color(0xFF00D9A6); // Teal-green accent
  static const Color accentLight = Color(0xFF5EFFD4);

  // ─── Background & Surface ──────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F1F8);
  static const Color scaffoldDark = Color(0xFF121218);
  static const Color surfaceDark = Color(0xFF1E1E2A);

  // ─── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B5C3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Borders & Dividers ────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF9D4EDD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient voiceSearchGradient = LinearGradient(
    colors: [primary, Color(0xFF9D4EDD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
