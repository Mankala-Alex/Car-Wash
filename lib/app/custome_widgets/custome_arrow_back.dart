import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import '../theme/app_theme.dart';

class CustomeArrowBack extends StatelessWidget {
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  const CustomeArrowBack({super.key, this.onPressed, this.padding});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed ?? () => Get.back(),
        icon: const Icon(
          Icons.arrow_back,
          color: AppColors.textLightGrayLight,
          //size: 20,
        )
        // icon: (Platform.isAndroid)
        //     ? const Icon(
        //         Icons.arrow_back,
        //         color: AppColors.textLightGrayLight,
        //         size: 20,
        //       )
        //     : const Icon(
        //         Icons.arrow_back_ios,
        //         color: AppColors.textLightGrayLight,
        //         size: 20,
        //       )
        );
  }
}
