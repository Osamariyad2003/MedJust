import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark, // Use your main brand color for headings
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primary, // Slightly lighter for subheadings
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text, // Default text color for smaller headings
  );

  static const bodyText1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text, // Main text color
  );

  static const bodyText2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight, // Lighter for secondary text
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.secondary, // Use accent/secondary color for captions
  );
}
