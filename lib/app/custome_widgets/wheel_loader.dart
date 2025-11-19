import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Widget wheelloader() {
  return Center(
    child: SizedBox(
      width: 500,
      height: 500,
      child: Lottie.asset(
        "assets/carwash/wheel_loader.json", // your lottie file
        fit: BoxFit.contain,
      ),
    ),
  );
}
