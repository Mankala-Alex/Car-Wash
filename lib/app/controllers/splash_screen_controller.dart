import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../helpers/secure_store.dart';
import '../helpers/shared_preferences.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startFlow();
  }

  Future<void> _startFlow() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // Check token in secure storage (where OtpController saves it)
      String? token;
      try {
        token = await FlutterSecureStore().getSingleValue(
          SharedPrefsHelper.accessToken,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error reading from secure storage: $e');
        }
        token = null;
      }

      // Navigate based on token availability
      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.offAllNamed(Routes.langeSelection);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Splash screen error: $e');
      }
      // Default navigation on any error
      Get.offAllNamed(Routes.langeSelection);
    }
  }
}
