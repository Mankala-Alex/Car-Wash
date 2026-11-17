import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// Portion of the shorter screen side used by the loader.
const double _kWheelLoaderScale = 0.40;

/// Strength of the frosted-glass blur applied to the screen behind the loader.
/// Kept low on purpose: the screen stays readable, it just loses focus.
const double _kLoaderBlurSigma = 3.5;

/// Bounds (logical px) so it never gets tiny on small phones and never gets
/// huge on tablets.
const double _kWheelLoaderMinSize = 120;
const double _kWheelLoaderMaxSize = 220;

/// Same visual proportion on small phones, big phones and tablets.
double wheelLoaderSize(BuildContext context) {
  final shortestSide = MediaQuery.sizeOf(context).shortestSide;
  return (shortestSide * _kWheelLoaderScale)
      .clamp(_kWheelLoaderMinSize, _kWheelLoaderMaxSize)
      .toDouble();
}

/// Wheel loader used across the app. Pass [size] to override the auto sizing.
class WheelLoader extends StatelessWidget {
  const WheelLoader({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final side = size ?? wheelLoaderSize(context);
    return Center(
      child: SizedBox(
        width: side,
        height: side,
        child: Lottie.asset(
          "assets/carwash/animations/washgate-loader.json", // your lottie file
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }
}

/// Backwards-compatible helper for the existing `wheelloader()` call sites.
Widget wheelloader({double? size}) => WheelLoader(size: size);

/// Full-screen loading overlay: blurs whatever is behind it (frosted glass) and
/// shows the wheel loader in the middle.
///
/// Drop it as the last child of a `Stack` (usually inside an `Obx` condition),
/// or let [showWheelLoaderDialog] insert it as a dialog. Taps are swallowed, so
/// the screen cannot be used while it is visible.
class WheelLoaderOverlay extends StatelessWidget {
  const WheelLoaderOverlay({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: AbsorbPointer(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _kLoaderBlurSigma,
            sigmaY: _kLoaderBlurSigma,
          ),
          child: Center(child: WheelLoader(size: size)),
        ),
      ),
    );
  }
}

/// Shows a non-dismissible overlay with the wheel loader on top of the current
/// screen.
///
/// The screen behind is slightly blurred (frosted glass) instead of being
/// covered by a white box or a dim layer, so only the loader stands out.
/// Safe to call twice.
void showWheelLoaderDialog({double? size}) {
  // Skip if a dialog is already open (e.g. a double tap on the submit button).
  if (Get.isDialogOpen == true) return;

  Get.dialog(
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    PopScope(
      canPop: false,
      child: WheelLoaderOverlay(size: size),
    ),
  );
}

/// Closes the loader shown by [showWheelLoaderDialog] (no-op when it is not open).
void hideWheelLoaderDialog() {
  if (Get.isDialogOpen == true) {
    Get.back();
  }
}
