


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+)
      if (await _isAndroid13OrAbove()) {
        final status = await Permission.videos.request();
        if (status.isGranted) {
          return true;
        } else if (status.isDenied) {
          _showPermissionDialog(context, "Need permission to save videos to gallery");
          return false;
        } else if (status.isPermanentlyDenied) {
          _showSettingsDialog(context, "Video permission is permanently denied");
          return false;
        }
        return status.isGranted;
      } 
      // For Android 12 and below
      else {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          return true;
        } else if (status.isDenied) {
          _showPermissionDialog(context, "Need permission to save videos to gallery");
          return false;
        } else if (status.isPermanentlyDenied) {
          _showSettingsDialog(context, "Storage permission is permanently denied");
          return false;
        }
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need explicit permission
  }

  static Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfo().androidInfo;
      return androidInfo.sdkInt >= 33;
    }
    return false;
  }

  static void _showPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await requestStoragePermission(context);
            },
            child: const Text("Grant Permission"),
          ),
        ],
      ),
    );
  }

  static void _showSettingsDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: Text("$message. Please enable it in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}

// Helper class to get device info
class DeviceInfo {
  Future<AndroidDeviceInfo> get androidInfo async {
    final androidInfo = await _getAndroidInfo();
    return androidInfo;
  }

  static Future<AndroidDeviceInfo> _getAndroidInfo() async {
    // This is a placeholder - you need to use device_info_plus package
    // For now, return a default
    return AndroidDeviceInfo(sdkInt: 33);
  }
}

class AndroidDeviceInfo {
  final int sdkInt;
  AndroidDeviceInfo({required this.sdkInt});
}