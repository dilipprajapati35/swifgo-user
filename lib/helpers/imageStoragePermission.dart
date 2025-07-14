import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_arch/widget/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageStoragePermission {
  static Future<PermissionStatus> requestGalleryPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        int sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 33) {
          // Android 13+ requires granular media permissions
          return await Permission.photos.request();
        } else {
          // Android 12 and below use storage permission
          return await Permission.storage.request();
        }
      } catch (e) {
        // Fallback to storage permission if device info fails
        return await Permission.storage.request();
      }
    } else if (Platform.isIOS) {
      // iOS uses photos permission
      return await Permission.photos.request();
    }
    
    MySnackBar.showSnackBar(
      context,
      'Unsupported platform for requesting gallery permission',
    );
    return PermissionStatus.denied;
  }

  /// Check if the app has gallery permission
  static Future<bool> hasGalleryPermission() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        int sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 33) {
          return await Permission.photos.isGranted;
        } else {
          return await Permission.storage.isGranted;
        }
      } catch (e) {
        // Fallback to storage permission if device info fails
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }
    
    return false;
  }

  /// Shows a permission denied message
  static void showPermissionDeniedMessage(BuildContext context) {
    MySnackBar.showSnackBar(
      context,
      'Permission denied. Please enable it in settings.',
    );
  }
}