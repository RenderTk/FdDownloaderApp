import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Gets a valid storage path for downloaded videos
  /// Handles permissions automatically based on platform
  Future<String?> getVideoStoragePath({String? customFolder}) async {
    try {
      if (kIsWeb) {
        return await _getWebStoragePath();
      } else if (Platform.isAndroid) {
        return await _getAndroidStoragePath(customFolder);
      } else if (Platform.isIOS) {
        return await _getIOSStoragePath(customFolder);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting storage path: $e');
      return null;
    }
  }

  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    if (kIsWeb || Platform.isIOS) {
      return true; // Web and iOS don't need explicit storage permissions
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      // Android 13+ (API 33+) uses different permissions
      if (androidInfo.version.sdkInt >= 33) {
        // For Android 13+, we need WRITE_EXTERNAL_STORAGE for accessing shared storage
        // or we can use app-specific directories without permissions
        return await Permission.manageExternalStorage.isGranted ||
            await Permission.storage.isGranted;
      } else {
        // For Android 12 and below
        return await Permission.storage.isGranted;
      }
    }

    return false;
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    if (kIsWeb || Platform.isIOS) {
      return true; // No permissions needed
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        // For Android 13+, try to request manage external storage first
        // This is for accessing shared Downloads folder
        var status = await Permission.manageExternalStorage.request();

        if (status.isGranted) {
          return true;
        }

        // Fallback to regular storage permission
        status = await Permission.storage.request();
        return status.isGranted;
      } else {
        // For Android 12 and below
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }

    return false;
  }

  /// Get storage path for Android
  Future<String?> _getAndroidStoragePath(String? customFolder) async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    // Check if we have permission for external storage
    bool hasPermission = await hasStoragePermission();

    if (!hasPermission) {
      hasPermission = await requestStoragePermission();
    }

    if (hasPermission && androidInfo.version.sdkInt >= 30) {
      // Android 11+ with permission - use Downloads folder
      try {
        final directory = Directory('/storage/emulated/0/DCIM');
        if (await directory.exists()) {
          final targetDir = customFolder != null
              ? Directory('${directory.path}/$customFolder')
              : directory;

          if (customFolder != null && !await targetDir.exists()) {
            await targetDir.create(recursive: true);
          }

          return targetDir.path;
        }
      } catch (e) {
        debugPrint('Error accessing Downloads folder: $e');
      }
    }

    // Fallback to app-specific external storage (no permissions required)
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final targetDir = customFolder != null
          ? Directory('${directory.path}/$customFolder')
          : Directory('${directory.path}/Videos');

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      return targetDir.path;
    }

    // Last resort - app documents directory
    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = customFolder != null
        ? Directory('${appDir.path}/$customFolder')
        : Directory('${appDir.path}/Videos');

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    return targetDir.path;
  }

  /// Get storage path for iOS
  Future<String?> _getIOSStoragePath(String? customFolder) async {
    // iOS apps are sandboxed, use app documents directory
    final directory = await getApplicationDocumentsDirectory();
    final targetDir = customFolder != null
        ? Directory('${directory.path}/$customFolder')
        : Directory('${directory.path}/Videos');

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    return targetDir.path;
  }

  /// Get storage path for Web
  Future<String?> _getWebStoragePath() async {
    // Web doesn't have a file system path, return a placeholder
    // Files will be downloaded to browser's default download location
    return 'downloads';
  }

  /// Get a complete file path for a video
  Future<String?> getVideoFilePath(
    String filename, {
    String? customFolder,
  }) async {
    final storagePath = await getVideoStoragePath(customFolder: customFolder);
    if (storagePath == null) return null;

    // Ensure filename has proper extension
    if (!filename.toLowerCase().endsWith('.mp4') &&
        !filename.toLowerCase().endsWith('.mov') &&
        !filename.toLowerCase().endsWith('.avi') &&
        !filename.toLowerCase().endsWith('.mkv')) {
      filename += '.mp4';
    }

    // Sanitize filename
    final sanitizedFilename = _sanitizeFilename(filename);

    if (kIsWeb) {
      return sanitizedFilename;
    }

    return '$storagePath/$sanitizedFilename';
  }

  /// Check if file exists at given path
  Future<bool> fileExists(String filePath) async {
    if (kIsWeb) {
      // Web storage check would require different approach
      return false;
    }

    final file = File(filePath);
    return await file.exists();
  }

  /// Get file size in bytes
  Future<int?> getFileSize(String filePath) async {
    if (kIsWeb) {
      return null;
    }

    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return null;
  }

  /// Delete file at given path
  Future<bool> deleteFile(String filePath) async {
    if (kIsWeb) {
      return false;
    }

    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Get available storage space in bytes
  Future<int?> getAvailableSpace() async {
    if (kIsWeb) {
      return null; // Web storage quota is handled by browser
    }

    try {
      final directory = await getTemporaryDirectory();
      final stat = await directory.stat();
      // This is a simplified approach - actual implementation may vary
      return stat.size;
    } catch (e) {
      debugPrint('Error getting available space: $e');
      return null;
    }
  }

  /// Sanitize filename for cross-platform compatibility
  String _sanitizeFilename(String filename) {
    // Remove invalid characters
    String sanitized = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    // Limit length
    if (sanitized.length > 255) {
      final extension = sanitized.split('.').last;
      final nameWithoutExt = sanitized.substring(0, sanitized.lastIndexOf('.'));
      sanitized =
          '${nameWithoutExt.substring(0, 255 - extension.length - 1)}.$extension';
    }

    return sanitized;
  }

  /// Get storage information
  Future<Map<String, dynamic>> getStorageInfo() async {
    final storagePath = await getVideoStoragePath();
    final hasPermission = await hasStoragePermission();

    return {
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
      'storagePath': storagePath,
      'hasPermission': hasPermission,
      'isWeb': kIsWeb,
    };
  }
}
