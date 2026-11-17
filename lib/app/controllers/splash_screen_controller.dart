import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../helpers/secure_store.dart';
import '../helpers/shared_preferences.dart';

class SplashScreenController extends GetxController {
  /// Hard safety net so the app can never stay stuck on the splash screen,
  /// e.g. if the Lottie bundle fails to load on a very slow device.
  static const Duration _animationTimeout = Duration(seconds: 8);

  /// Completed once the intro animation reached its last frame (or failed).
  final Completer<void> _animationGate = Completer<void>();
  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    _startFlow();
  }

  /// Called by [SplashScreenView] when the intro animation has finished.
  void onSplashAnimationComplete() {
    if (!_animationGate.isCompleted) {
      _animationGate.complete();
    }
  }

  Future<void> _startFlow() async {
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

    final String targetRoute = (token != null && token.isNotEmpty)
        ? Routes.dashboard
        : Routes.langeSelection;

    // Never navigate before the splash animation has played to the end.
    await _waitForAnimation();

    _navigateTo(targetRoute);
  }

  Future<void> _waitForAnimation() async {
    try {
      await _animationGate.future.timeout(_animationTimeout);
    } on TimeoutException {
      if (kDebugMode) {
        print('Splash animation timed out — continuing to the app.');
      }
    }
  }

  void _navigateTo(String route) {
    if (_navigated) return;
    _navigated = true;
    Get.offAllNamed(route);
  }
}
