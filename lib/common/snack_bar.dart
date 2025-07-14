import 'package:flutter/material.dart';
import 'package:flutter_arch/theme/colorTheme.dart';

class MySnackBar {
  // Global key for accessing ScaffoldMessenger
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColor.greyShade2,
        ),
      );
    } catch (e) {
      // Fallback to global key if context is invalid
      showGlobalSnackBar(message);
    }
  }

  static void showGlobalSnackBar(String message) {
    if (rootScaffoldMessengerKey.currentState != null) {
      rootScaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,),
          ),
          backgroundColor: AppColor.grey,
        ),
      );
    }
  }
}
