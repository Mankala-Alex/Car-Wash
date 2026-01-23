import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/constants.dart';
import '../theme/app_theme.dart';

class CustomConfirmationDialog extends StatelessWidget {
  final String header;
  final String body;
  final String yesText;
  final String noText;
  final bool? isCancel;

  final VoidCallback onYes;
  final VoidCallback? onNo;

  const CustomConfirmationDialog({
    super.key,
    this.header = "Confirmation",
    required this.body,
    required this.onYes,
    this.onNo,
    this.noText = "Cancel",
    this.yesText = "Continue",
    this.isCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(
          header,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(body, style: const TextStyle(fontSize: 16)),
        ),
        actions: <Widget>[
          Visibility(
            visible: isCancel ?? true,
            child: CupertinoDialogAction(
              onPressed: onNo ?? Get.back,
              child: Text(
                noText,
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          CupertinoDialogAction(
            onPressed: onYes,
            isDefaultAction: true,
            child: Text(
              yesText,
              style: TextStyle(
                color: Constants.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    // Android Material Dialog
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      backgroundColor: AppColors.bgLight,
      title: Text(
        header,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Text(body, style: const TextStyle(fontSize: 16)),
      actions: <Widget>[
        Visibility(
          visible: isCancel ?? true,
          child: TextButton(
            onPressed: onNo ?? Get.back,
            child: Text(
              noText,
              style: TextStyle(
                color: Constants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: onYes,
          child: Text(
            yesText,
            style: TextStyle(
              color: Constants.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
