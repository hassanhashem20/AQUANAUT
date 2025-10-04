import 'package:flutter/material.dart';

class AppColors {
  // Primary Space Theme Colors
  static const Color deepSpace = Color(0xFF0B0C1E);
  static const Color darkSpace = Color(0xFF151729);
  static const Color midSpace = Color(0xFF1E2139);
  static const Color spaceBlue = Color(0xFF2E53E1);
  static const Color cosmicPurple = Color(0xFF6B4FBB);
  
  // Accent Colors
  static const Color neonBlue = Color(0xFF00D9FF);
  static const Color neonCyan = Color(0xFF00FFF5);
  static const Color neonPurple = Color(0xFFB794F6);
  static const Color starYellow = Color(0xFFF9DC6B);
  static const Color sunsetOrange = Color(0xFFFFAE5D);
  static const Color rocketRed = Color(0xFFFF6B6B);
  
  // ISS Theme
  static const Color issBlue = Color(0xFF1E88E5);
  static const Color issGreen = Color(0xFF4CAF50);
  static const Color issOrange = Color(0xFFFF9800);
  
  // Status Colors
  static const Color successGreen = Color(0xFF21C37B);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color errorRed = Color(0xFFDC143C);
  
  // Gradients
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepSpace, darkSpace, midSpace],
  );
  
  static const LinearGradient nebulaPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
  
  static const LinearGradient cosmicBlue = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4158D0), Color(0xFFC850C0), Color(0xFFFFCC70)],
  );
  
  static const LinearGradient issGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF01579B)],
  );
  
  // Semi-transparent overlays
  static Color overlay(double opacity) => Colors.black.withOpacity(opacity);
  static Color glassOverlay(double opacity) => Colors.white.withOpacity(opacity);
}
