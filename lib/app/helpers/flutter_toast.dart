import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../config/constants.dart';

successToast(msg) {
  return Fluttertoast.showToast(
    msg: msg,
    backgroundColor: Colors.grey[300]!.withOpacity(0.8),
    textColor: Colors.grey[800],
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
  );
}

errorToast(msg) {
  return Fluttertoast.showToast(
    msg: msg,
    backgroundColor: Colors.grey[300]!.withOpacity(0.8),
    textColor: Colors.red[800],
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
  );
}

loadingPopUp(show) {
  if (show) {
    return showDialog(
      barrierDismissible: false,
      context: Get.context!,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          alignment: FractionalOffset.center,
          height: 60,
          padding: const EdgeInsets.all(8),
          child: CircularProgressIndicator
          (color: Constants.primaryColor),
        ),
      ),
    );
  } else {
    Get.back();
  }
}
