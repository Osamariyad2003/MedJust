import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static int getCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    return 32.0;
  }
}
