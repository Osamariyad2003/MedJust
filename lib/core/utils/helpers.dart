import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Helpers {
  // Date formatting
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Time ago formatting
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // File size formatting
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Duration formatting
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Show dialog
  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Confirm'),
              ),
            ],
          ),
    );
  }

  // Generate random string
  static String generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // Debounce function
  static Timer? _debounceTimer;
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // Calculate GPA
  static double calculateGPA(List<Map<String, dynamic>> grades) {
    if (grades.isEmpty) return 0.0;

    double totalPoints = 0;
    int totalCredits = 0;

    for (final grade in grades) {
      final points = grade['points'] as double;
      final credits = grade['credits'] as int;
      totalPoints += points * credits;
      totalCredits += credits;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }
}
