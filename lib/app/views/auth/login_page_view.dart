import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/theme/app_theme.dart';
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
                const Text(
                  "Email or Phone Number",
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
                    controller: controller.phoneController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.email_outlined,
                          color: Colors.grey), // Optional
                      hintText: "Enter your email or mobile number",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      child: const Text(
                        "Continue",
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
