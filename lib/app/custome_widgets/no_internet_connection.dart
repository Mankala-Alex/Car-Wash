import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/constants.dart';
import '../helpers/helper_check_internet.dart';
import '../theme/app_theme.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = CustomTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: customTheme.bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: const Text(
        "",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 25),
            child: Image.asset(
              "assets/nodata/no_internet.png",
              width: 150,
            ),
          ),
          Text("internet_not_available".tr),
          const SizedBox(height: 40),
          // const Text("cons_check_internet", style: TextStyle(fontSize: 18)),
        ],
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () async {
                // final accessToken = await FlutterSecureStore().getSingleValue(
                //   SharedPrefsHelper.accessToken,
                // );

                if (await isInternet()) {
                  Get.back();
                } else {
                  Get.back();
                  Get.dialog(
                    const NoInternetConnection(),
                    barrierColor: const Color(0xFF000000).withOpacity(0.7),
                    barrierDismissible:
                        false, // Prevents closing the dialog by tapping outside
                  );
                }
              },
              child: Text(
                "reload".tr,
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: Text(
                "go_settings".tr,
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
