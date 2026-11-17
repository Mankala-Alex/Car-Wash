import 'package:car_wash_customer_app/app/custome_widgets/wheel_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../controllers/auth/otp_controller.dart';

class OtpScreenView extends GetView<OtpController> {
  const OtpScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 55,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "verify_otp".tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60), // Move card up
                // --------------------- WHITE CARD ---------------------
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "enter_the_otp_sent_to_your_number".tr,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      // --------------------- OTP BOXES ---------------------
                      Center(
                        child: Pinput(
                          length: 6,
                          controller: controller.otpCtrl,
                          onChanged: controller.setOtp,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              border:
                                  Border.all(color: Colors.orange, width: 2),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // --------------------- OTP VALIDITY / RESEND ---------------------
                      // 5 minutes to use the code, "Resend OTP" locked for 60 s.
                      // Both numbers come from the backend response.
                      Obx(
                        () => controller.isExpired
                            ? Text(
                                "otp_expired_request_new".tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              )
                            : Text(
                                "${"otp_expires_in".tr} ${controller.expiryCountdown}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                      ),

                      const SizedBox(height: 4),

                      Obx(
                        () => controller.canResend
                            ? TextButton(
                                onPressed: controller.isResending.value
                                    ? null
                                    : controller.resend,
                                child: Text(
                                  "resend_otp".tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange,
                                  ),
                                ),
                              )
                            : Text(
                                "${"resend_otp_in".tr} ${controller.resendCountdown}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black45,
                                ),
                              ),
                      ),

                      const SizedBox(height: 18),

                      // --------------------- VERIFY BUTTON ---------------------
                      SizedBox(
                        width: 120,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            await controller.verifyOtp();
                          },
                          child: Text(
                            "verify".tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // FULL SCREEN LOADER - blurs the OTP form behind it
          Obx(() {
            if (!controller.isLoading.value && !controller.isResending.value) {
              return const SizedBox.shrink();
            }

            return const WheelLoaderOverlay();
          }),
        ],
      ),
    );
  }
}
