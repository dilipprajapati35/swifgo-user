import 'package:flutter/material.dart';
import 'package:flutter_arch/common/color/commoncolor.dart';
import 'package:flutter_arch/screens/main_navigation/main_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';


Widget CommonButton(BuildContext context, String text) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(CommonColor.blue),
      shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      padding: WidgetStatePropertyAll(
        EdgeInsets.only(
          top: context.height() * 0.015,
          bottom: context.height() * 0.015,
          left: context.width() * 0.25,
          right: context.width() * 0.25,
        ),
      ),
    ),
    onPressed: () {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
    },
    child: Text(
      text,
      style: GoogleFonts.nunito(
          fontWeight: FontWeight.w700, color: Colors.white, fontSize: 17),
    ),
  );
}
