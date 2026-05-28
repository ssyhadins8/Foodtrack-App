import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodtrack/theme/app_colors.dart';

class AppTypography {
  // Define text styles using Google Fonts Inter
  static TextStyle headline1 = GoogleFonts.inter(
    fontSize: 96,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
    color: AppColors.primary,
  );
  static TextStyle headline2 = GoogleFonts.inter(
    fontSize: 60,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );
  static TextStyle headline3 = GoogleFonts.inter(
    fontSize: 48,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  static TextStyle headline4 = GoogleFonts.inter(
    fontSize: 34,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );
  static TextStyle headline5 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  static TextStyle headline6 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );
  static TextStyle subtitle1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    color: AppColors.textSecondary,
  );
  static TextStyle subtitle2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );
  static TextStyle bodyText1 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );
  static TextStyle bodyText2 = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
  );
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
    color: AppColors.textPrimary,
  );
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );
  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );
}
