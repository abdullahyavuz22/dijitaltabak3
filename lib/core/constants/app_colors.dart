import 'package:flutter/material.dart';

/// Marka ve anlamsal renk paleti.
///
/// Ekranlarda mümkün olduğunca `Theme.of(context).colorScheme` kullanın;
/// buradaki sabitler tema kurulumunda ve tema dışı anlamsal renklerde
/// (VKİ durumları, puan yıldızı vb.) kullanılır.
class AppColors {
  AppColors._();

  // ── Marka ──────────────────────────────────────────────
  /// Ana marka yeşili (beyaz metinle WCAG AA kontrast sağlar).
  static const Color primary = Color(0xFF1F8A4C);

  /// Uygulamanın eski/açık yeşili — vurgu ve gradyanlarda.
  static const Color primaryLight = Color(0xFF68BE6D);

  /// Koyu temada ana renk.
  static const Color primaryDarkMode = Color(0xFF7BD497);

  /// Sıcak vurgu (kalori, öne çıkan öğeler).
  static const Color accent = Color(0xFFF59E0B);

  // ── Nötrler (açık tema) ────────────────────────────────
  static const Color background = Color(0xFFF5F7F4);
  static const Color surface = Colors.white;
  static const Color ink = Color(0xFF16261C);
  static const Color inkMuted = Color(0xFF5A6B60);
  static const Color border = Color(0xFFE2E8E3);

  // ── Nötrler (koyu tema) ────────────────────────────────
  static const Color darkBackground = Color(0xFF0E1511);
  static const Color darkSurface = Color(0xFF17211B);
  static const Color darkInk = Color(0xFFE4ECE6);
  static const Color darkInkMuted = Color(0xFF9DB0A3);
  static const Color darkBorder = Color(0xFF2A3830);

  // ── Anlamsal ───────────────────────────────────────────
  static const Color success = Color(0xFF2E9E5B);
  static const Color warning = Color(0xFFE08A00);
  static const Color danger = Color(0xFFD64545);
  static const Color info = Color(0xFF2F7FD1);
  static const Color star = Color(0xFFF5B301);
  static const Color favorite = Color(0xFFE5484D);

  /// Marka gradyanı (başlık alanları).
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF17703D), primary, Color(0xFF4FB06A)],
  );

  // Geriye dönük uyumluluk
  static const Color white = Colors.white;
  static const Color cardShadow = Color(0x1A000000);
}
