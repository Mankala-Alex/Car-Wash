import 'package:get/get.dart';

import '../helpers/secure_store.dart';
import '../routes/app_routes.dart';

Future<void> logout({bool forceLogout = true}) async {
  // You can add confirmation dialog here if needed
  // if (SharedPrefsHelper.readBoolean("checkIn") && !forceLogout) {
  //   Get.dialog(
  //     CustomConfirmationDialog(
  //       header: "cons_confirmation".tr,
  //       body: 'cons_aut_clcok_out'.tr,
  //       onYes: () async {
  //         deleteDataAndRedirectLoginPage();
  //       },
  //       noText: 'cons_cancel'.tr,
  //       yesText: "cons_continue".tr,
  //     ),
  //     barrierColor: Constants.bgBackDropColor,
  //     barrierDismissible:
  //         false, // Prevents closing the dialog by tapping outside
  //   );
  // }

  await deleteDataAndRedirectLoginPage();
}

Future<void> deleteDataAndRedirectLoginPage() async {
  await FlutterSecureStore().deleteAllData();

  // Remove other stored data if required:
  // Storage.remove(Storage.loginResponse);
  // Storage.remove(Storage.username);
  // Storage.remove(Storage.emailId);
  // Storage.remove(Storage.mobileNo);
  // Storage.remove(Storage.accountID);

  // Navigate to login page after data deletion
  Get.offAllNamed(Routes.login);
}
