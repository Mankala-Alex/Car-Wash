import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';
import '../theme/app_theme.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = CustomTheme.of(context);

    // Trigger controller initialization
    controller;

    return Scaffold(
      backgroundColor: customTheme.bgColor,
      body: SizedBox.expand(
        child: Image.asset(
          "assets/carwash/splash_2.jpg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
