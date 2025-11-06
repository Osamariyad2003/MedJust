import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:med_just/core/routes/routers.dart';
import 'package:med_just/core/shared/themes/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Don't use multiple navigations - just check status after delay
    Future.delayed(Duration(seconds: 2), () {
      _checkUserStatus();
    });
  }

  void _checkUserStatus() async {
    // Fix: Use 'userBox' to match what's opened in di.dart
    final box = Hive.box('userBox');
    bool onboardingShown = box.get('onboardingShown', defaultValue: false);
    bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);
    String yearId = box.get('yearId', defaultValue: '');

    print('Retrieved onboardingShown: $onboardingShown');
    print('Retrieved isLoggedIn: $isLoggedIn');

    // Fix navigation logic
    if (isLoggedIn) {
      print('User is logged in. Navigating to home screen.');
      Navigator.pushReplacementNamed(context, Routers.homeRoute);
    } else {
      print('User not logged in. Navigating to login screen.');
      Navigator.pushReplacementNamed(context, Routers.loginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double imageSize = screenWidth * 0.25;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Image.asset(
          'assets/images/spalsh-logo.png',
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
