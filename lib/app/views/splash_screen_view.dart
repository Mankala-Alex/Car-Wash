// my_new_app/lib/app/views/splash_screen_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';
import '../theme/app_theme.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    // Start navigation timer in controller
    controller.startTimer(context);

    final customTheme = CustomTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: customTheme.bgColor,
      body: SizedBox.expand(
        child: Image.asset(
          "assets/carwash/lang_car.png",
          fit: BoxFit.cover, // Fills entire screen
        ),
      ),
    );
  }
}
