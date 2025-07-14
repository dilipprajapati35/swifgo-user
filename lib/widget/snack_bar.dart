import 'package:flutter_arch/helpers/text_style.dart';
import 'package:flutter_arch/theme/colorTheme.dart';

import 'package:flutter/material.dart';

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
            style: whitebold,
          ),
          backgroundColor: AppColor.buttonColor,
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
            style: whitebold,
          ),
          backgroundColor: AppColor.primaryColor,
        ),
      );
    }
  }
}
