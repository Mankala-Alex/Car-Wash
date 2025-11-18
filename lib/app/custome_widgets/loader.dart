
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/constants.dart';

Widget loader() {
  return Container(
      height: Get.height / 2,
      padding: const EdgeInsets.all(10),
      child: Center(
        child: CircularProgressIndicator(color: Constants.primaryColor),
      ));
}
