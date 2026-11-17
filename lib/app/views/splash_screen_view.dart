import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/splash_screen_controller.dart';
import '../theme/app_theme.dart';

/// Splash / intro screen.
///
/// The Lottie intro is played **once, to the very end**. Navigation is only
/// triggered by `SplashScreenController.onSplashAnimationComplete()`, so the
/// token lookup (which finishes in a few milliseconds) can no longer cut the
/// animation short.
class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView>
    with SingleTickerProviderStateMixin {
  static const String _introAnimation =
      //'assets/carwash/animations/spalsh_animation.json';
      //'assets/carwash/animations/splash_animation_2.json';
      'assets/carwash/animations/washgate-splash.json';
  late final SplashScreenController _splashController;
  late final AnimationController _animationController;

  bool _playRequested = false;
  bool _completionReported = false;

  @override
  void initState() {
    super.initState();
    _splashController = Get.find<SplashScreenController>();
    _animationController = AnimationController(vsync: this)
      ..addStatusListener(_onAnimationStatus);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _reportAnimationComplete();
    }
  }

  void _reportAnimationComplete() {
    if (_completionReported) return;
    _completionReported = true;
    _splashController.onSplashAnimationComplete();
  }

  void _playIntro(LottieComposition composition) {
    if (_playRequested) return;
    _playRequested = true;
    _animationController
      ..duration = composition.duration
      ..reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = CustomTheme.of(context);

    return Scaffold(
      backgroundColor: customTheme.bgColor,
      body: SizedBox.expand(
        child: Lottie.asset(
          _introAnimation,
          fit: BoxFit.contain,
          // A dedicated controller => no auto-play and no looping, we decide
          // exactly when the intro starts and when it is finished.
          controller: _animationController,
          animate: false,
          repeat: false,
          onLoaded: _playIntro,
          // If the JSON can't be decoded we must still leave the splash screen.
          errorBuilder: (context, error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _reportAnimationComplete(),
            );
            return Image.asset(
              'assets/carwash/splash_2.jpg',
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}
