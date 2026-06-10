import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get poppinsHeading => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle get poppinsBody => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get malayalamText => GoogleFonts.notoSansMalayalam(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}
