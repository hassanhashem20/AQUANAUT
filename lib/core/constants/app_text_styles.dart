import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle get heading1 => GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.5,
      );
  
  static TextStyle get heading2 => GoogleFonts.orbitron(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
      );
  
  static TextStyle get heading3 => GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 1.0,
      );
  
  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.9),
        height: 1.5,
      );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.85),
        height: 1.4,
      );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.7),
        height: 1.3,
      );
  
  // Special Styles
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.neonCyan,
        letterSpacing: 0.5,
      );
  
  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 1.0,
      );
  
  static TextStyle get missionTitle => GoogleFonts.orbitron(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.neonBlue,
        letterSpacing: 1.5,
      );
  
  static TextStyle get dataLabel => GoogleFonts.spaceMono(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.starYellow,
        letterSpacing: 1.0,
      );
  
  static TextStyle get countdown => GoogleFonts.spaceMono(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.neonCyan,
        letterSpacing: 2.0,
      );
}
