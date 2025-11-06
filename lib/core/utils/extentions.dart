import 'package:flutter/material.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';

/// Show loading dialog without dismiss on tap
extension ShowLoadingDialog on BuildContext {
  Future<void> showLoadingDialog() async {
    await showDialog<void>(
      context: this,
      barrierDismissible: false,
      builder: (_) => const LoadingIndicator(),
    );
  }
}

/// Navigation helper extensions
extension AppNavigator on BuildContext {
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String newRoute, {
        TO? result,
        Object? arguments,
      }) {
    return Navigator.pushReplacementNamed<T, TO>(
      this,
      newRoute,
      arguments: arguments,
      result: result,
    );
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
      String newRoute, {
        Object? arguments,
      }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      this,
      newRoute,
          (_) => false,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.pop<T>(this, result);
  }
}

/// MediaQuery helpers for easy access to screen dimensions
extension MediaQueryExtension on BuildContext {
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;
}

/// Custom Snackbar with optional spinner and action
extension SnackBarExtension on BuildContext {
  void showCustomSnackBar({
    required String message,
    bool showSpinner = false,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    Color spinnerColor = Colors.white,
    Color actionColor = Colors.amber,
  }) {
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      duration: duration,
      content: Row(
        children: [
          if (showSpinner)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: spinnerColor,
              ),
            ),
          if (showSpinner) const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
        label: actionLabel,
        textColor: actionColor,
        onPressed: onAction,
      )
          : null,
    );

    ScaffoldMessenger.of(this).clearSnackBars(); // avoid stacking
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
