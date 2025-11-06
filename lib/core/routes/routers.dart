import 'package:flutter/material.dart';

class Routers {
  static const String initialRoute = '/';
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String yearsRoute = '/years';
  static const String subjectsRoute = '/subjects';
  static const String lecturesRoute = '/lectures';
  static const String videosRoute = '/videos';
  static const String filesRoute = '/files';
  static const String quizzesRoute = '/quizzes';
  static const String professorsRoute = '/professors';
  static const String newsRoute = '/news';
  static const String storeRoute = '/store';
  static const String gpaCalculatorRoute = '/gpa-calculator';
  static const String universityMapRoute = '/university-map';
  static const String sidebarRoute = '/sidebar';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/guidelines';
  static const String webviewRoute = '/webview';
  static const String azkarRoute = '/azkar';
  static const String guide = "/guide";
  static const String pomodoro = "/pomodoro";

  // Navigation methods
  static void navigateToHome(BuildContext context, {bool clearStack = true}) {
    if (clearStack) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        homeRoute,
        (route) => false, // This clears the entire navigation stack
      );
    } else {
      Navigator.of(context).pushNamed(homeRoute);
    }
  }

  static void navigateAfterLogin(BuildContext context) {
    // Clear the navigation stack and navigate to home
    // This prevents going back to login screen with back button
    Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
  }

  static void navigateToSubjects(BuildContext context, String yearId) {
    Navigator.of(
      context,
    ).pushNamed(subjectsRoute, arguments: {'yearId': yearId});
  }

  static void navigateToLectures(BuildContext context, String subjectId) {
    Navigator.of(
      context,
    ).pushNamed(lecturesRoute, arguments: {'subjectId': subjectId});
  }

  static void navigateToFiles(BuildContext context, String lectureId) {
    Navigator.of(
      context,
    ).pushNamed(filesRoute, arguments: {'lectureId': lectureId});
  }

  static void navigateToVideos(BuildContext context, String lectureId) {
    Navigator.of(
      context,
    ).pushNamed(videosRoute, arguments: {'lectureId': lectureId});
  }
}
