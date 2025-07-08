import 'package:flutter/material.dart';

enum SnackbarType { error, warning, success, info }

class SnackbarHelper {
  static void showCustomSnackbar({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
  }) {
    final icon = _getIcon(type);
    final color = _getColor(type);
    final title = _getTitle(type);

    final snackBar = SnackBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(
      context,
    ).clearSnackBars(); // Optional: Clear existing snackbars
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return Colors.redAccent;
      case SnackbarType.warning:
        return Colors.orange;
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.info:
        return Colors.blue;
    }
  }

  static String _getTitle(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return "Error";
      case SnackbarType.warning:
        return "Warning";
      case SnackbarType.success:
        return "Success";
      case SnackbarType.info:
        return "Info";
    }
  }
}
