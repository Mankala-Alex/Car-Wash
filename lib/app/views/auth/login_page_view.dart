import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import '../../controllers/auth/login_controller.dart';
import '../../custome_widgets/wheel_loader.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ================= MAIN CONTENT =================
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ---------------- DIVIDER WITH TEXT ----------------
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Login or Sign up",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),

                const SizedBox(height: 35),

                // ---------------- LABEL ----------------
                Text(
                  "mobile_number".tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                // ---------------- INPUT FIELD ----------------
                // ---------------- INPUT FIELD ---------------- (Exact from your working app)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 12, right: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.grey,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "+966",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      hintText: "Enter your Mobile number",
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ---------------- CONTINUE BUTTON ----------------
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              await controller.requestOtp();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "continue".tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),

          // ================= FULL SCREEN LOADER =================
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox();

            return Center(
              child: wheelloader(), // 🔥 CENTERED LOADER
            );
          }),
        ],
      ),
    );
  }
}
