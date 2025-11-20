import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/auth/otp_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class OtpScreenView extends GetView<OtpController> {
  const OtpScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OtpController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          "Verify OTP",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // ======= CENTER EVERYTHING =======
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade400, width: 1.4),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, 5),
                color: Colors.grey,
              ),
            ],
          ),

          // Everything inside the border
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter the OTP sent to your number",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),

              const SizedBox(height: 30),

              // ===================== OVAL OTP INPUTS =====================
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return _otpOval(
                        index: index,
                        controller: controller,
                      );
                    }),
                  )),

              const SizedBox(height: 35),

              // ===================== VERIFY BUTTON =====================
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.dashboard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Verify",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  //   OVAL SHAPED OTP FIELD (EXPANDS WHEN FOCUSED)
  // =========================================================
  Widget _otpOval({required int index, required OtpController controller}) {
    bool hasValue = controller.otp[index].value.isNotEmpty;
    bool isFocused = controller.currentIndex.value == index;

    double size = (isFocused || hasValue) ? 60 : 50;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.12),
        border: Border.all(
          color: isFocused ? AppColors.secondaryLight : Colors.grey.shade400,
          width: isFocused ? 2.4 : 1.4,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller.textControllers[index],
        focusNode: controller.focusNodes[index],
        cursorColor: AppColors.secondaryLight,
        onChanged: (value) => controller.onOtpChange(index, value),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
      ),
    );
  }
}
