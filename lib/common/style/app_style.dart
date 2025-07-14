import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppStyle {
  static TextStyle title = GoogleFonts.nunito(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.greyShade1,
      height: 34 / 28);

  static TextStyle title3 = GoogleFonts.nunito(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.greyShade1,
      letterSpacing: 0,
      height: 25 / 20);

  static TextStyle largeTitle = GoogleFonts.nunito(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: AppColors.greyShade1,
      letterSpacing: -0.4,
      height: 41 / 34);

  static TextStyle subheading = GoogleFonts.nunito(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.greyShade2,
      height: 20 / 15);

  static TextStyle caption1w400 = GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.greyShade3,
      height: 16 / 12);

  static TextStyle caption1w600 = GoogleFonts.nunito(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.greyShade3,
      height: 16 / 12);

  static TextStyle greyTextField = GoogleFonts.nunito(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.greyTextField,
      height: 22 / 16);

  static TextStyle body = GoogleFonts.nunito(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.greyWhite,
      letterSpacing: 0,
      height: 22 / 17);

  static TextStyle otptxt = GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xff3E57B4),
      letterSpacing: 0,
      height: 18 / 14);
}
