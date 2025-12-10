import 'package:get/get.dart';
import 'package:my_new_app/app/models/auth/otp_model.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../helpers/flutter_toast.dart';
import '../../helpers/shared_preferences.dart'; // ⬅️ IMPORTANT

class OtpController extends GetxController {
  final AuthRepository repository = AuthRepository();

  RxString otp = "".obs;

  late String customerId; // this is UUID (from login/signup)
  late String phone;

  @override
  void onInit() {
    customerId = Get.arguments["customerId"];
    phone = Get.arguments["phone"];
    super.onInit();
  }

  void setOtp(String value) {
    otp.value = value;
  }

  /// Extract numeric ID from formats like "CUST-933904"
  int _extractNumericCustomerId(String? customerCode) {
    if (customerCode == null) return 0;
    final match = RegExp(r'(\d+)$').firstMatch(customerCode);
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  Future<Otpmodel?> verifyOtp() async {
    if (otp.value.length != 4) {
      errorToast("Enter valid OTP");
      return null;
    }

    loadingPopUp(true);

    try {
      final resp = await repository.postVerifyOtp({
        "customerId": customerId,
        "otp": otp.value,
      });

      loadingPopUp(false);

      final data = Otpmodel.fromJson(resp.data);

      if (!data.success) {
        errorToast(data.message);
        return null;
      }

      // --------------------------------------------------------
      // SAVE CUSTOMER DETAILS AFTER OTP SUCCESS
      // --------------------------------------------------------
      // --------------------------------------------------------
// SAVE CUSTOMER DETAILS AFTER OTP SUCCESS
// --------------------------------------------------------
      final customer = resp.data["customer"];
      if (customer != null) {
        final String? uuid = customer["id"];
        final String? code = customer["customerId"];
        final int numericId = _extractNumericCustomerId(code);

        // SAVE UUID & NUMERIC ID
        await SharedPrefsHelper.setString("customerUuid", uuid ?? "");
        await SharedPrefsHelper.setInt("customerNumericId", numericId);

        // SAVE CUSTOMER NAME
        final String? first = customer["firstName"];
        final String? last = customer["lastName"];
        final String fullName = "${first ?? ""} ${last ?? ""}".trim();
        await SharedPrefsHelper.setString("customerName", fullName);

        // SAVE PHONE
        await SharedPrefsHelper.setString("customerPhone", phone);

        print("🔵 OTP Verified & Stored:");
        print("UUID: $uuid");
        print("Numeric ID: $numericId");
        print("Name: $fullName");
        print("Phone: $phone");
      } else {
        print("⚠️ OTP response did not contain 'customer' object.");
      }

      // --------------------------------------------------------
      // OTP SUCCESS HANDLING
      // --------------------------------------------------------
      successToast("OTP Verified!");
      return data;
    } catch (e) {
      loadingPopUp(false);
      errorToast("OTP verification failed");
      return null;
    }
  }
}

//for booking history//
// import 'package:get/get.dart';
// import 'package:my_new_app/app/models/auth/otp_model.dart';
// import '../../repositories/auth/auth_repository.dart';
// import '../../helpers/flutter_toast.dart';

// class OtpController extends GetxController {
//   final AuthRepository repository = AuthRepository();

//   RxString otp = "".obs;

//   late String customerId;
//   late String phone;

//   @override
//   void onInit() {
//     customerId = Get.arguments["customerId"];
//     phone = Get.arguments["phone"];
//     super.onInit();
//   }

//   void setOtp(String value) {
//     otp.value = value;
//   }

//   Future<Otpmodel?> verifyOtp() async {
//     if (otp.value.length != 4) {
//       errorToast("Enter valid OTP");
//       return null;
//     }

//     loadingPopUp(true);

//     try {
//       final resp = await repository.postVerifyOtp({
//         "customerId": customerId,
//         "otp": otp.value,
//       });

//       loadingPopUp(false);

//       // Convert API response to model
//       final data = Otpmodel.fromJson(resp.data);

//       // Backend sends: { success: false, message: "Invalid OTP" }
//       if (!data.success) {
//         errorToast(data.message);
//         return null;
//       }

//       return data;
//     } catch (e) {
//       loadingPopUp(false);
//       errorToast("OTP verification failed");
//       return null;
//     }
//   }
// }
