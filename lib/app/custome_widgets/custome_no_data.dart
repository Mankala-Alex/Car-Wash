import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

Widget noDataAvailable({imagePath = "assets/nodata/no_data.png", title = "cons_no_data"}) {
  return Container(
    // alignment: Alignment.center,
    // margin: const EdgeInsets.only(top: 50),
    // decoration: BoxDecoration(
    //   color: Colors.white,
    //   borderRadius: BorderRadius.circular(15),
    //   // border: Border.all(color: Constants.secondaryBackgroundColor, width: 1),
    // ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const SizedBox(height: 10),
        Image.asset(
          '$imagePath',
          width: 200,
          height: 200,
        ),
        // const SizedBox(height: 10),
        Text("$title".tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLightGrayLight,
            )),
        const SizedBox(height: 10),
        Text(
          "cons_no_data_body".tr,
          style: const TextStyle(
            color: AppColors.textLightGrayLight,
          ),
        ),
        const SizedBox(height: 85),
      ],
    ),
  );
}
