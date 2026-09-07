// ────────────────────────────────────────────────────────────────────────────
// Utility helpers & AppSnackbar debounced notification system
// ────────────────────────────────────────────────────────────────────────────
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';

class AppUtils {
  /// Format seconds to mm:ss
  static String formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Get a greeting based on current hour
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Strip file extension and sanitize a filename for use as default title
  static String fileNameToTitle(String path) {
    final base = path.split(Platform.pathSeparator).last;
    final dot = base.lastIndexOf('.');
    return dot == -1 ? base : base.substring(0, dot);
  }

  /// Human-readable file size
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Prevents queued / stacked duplicate popup snackbars on rapid taps
class AppSnackbar {
  static String? _lastMessage;
  static DateTime? _lastShown;

  static void show(
    String title,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShown != null &&
        now.difference(_lastShown!).inMilliseconds < 800) {
      return;
    }
    _lastMessage = message;
    _lastShown = now;

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.snackbar(
      title,
      message,
      backgroundColor: neuBase,
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      boxShadows: neuSoftShadow,
    );
  }
}
