// my_new_app/lib/app/controllers/splash_screen_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class SplashScreenController extends GetxController {
  Future<void> startTimer(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2)); // Reduced for demo

    // API-related checks (commented out until needed)
    /*
    bool isViewed = await SharedPrefsHelper.getBool(
      SharedPrefsHelper.isLanguageSet,
    );
    String? accessToken = await FlutterSecureStore().getSingleValue(
      SharedPrefsHelper.accessToken,
    );
    if (accessToken != null && accessToken != "") {
      Get.offNamed(Routes.dashboard);
    } else if (isViewed) {
      Get.offNamed(Routes.login);
    } else {
      Get.offNamed(Routes.langeSelection);
    }
    */

    // Navigate to language selection for template
    Get.offNamed(Routes.langeSelection);
  }
}
