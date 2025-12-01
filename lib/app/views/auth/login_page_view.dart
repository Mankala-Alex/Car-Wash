import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/auth/login_controller.dart';
import 'package:my_new_app/app/custome_widgets/wheel_loader.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

import '../../custome_widgets/custom_tab_bar.dart';
import '../../routes/app_routes.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomTabBar(
      //title: "MAIPROSOFT".tr,
      tabs: ["Login".tr, "Signup".tr],
      tabViews: const [Login(), Signup()],
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Welcome Back
            Text(
              "Welcome Back",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),

            const SizedBox(height: 25),

            // Email Label
            const Text(
              "Email or Mobile",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            // Email Field
            TextField(
              decoration: InputDecoration(
                hintText: "Enter your email or mobile",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primaryLight, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Password label
            const Text(
              "Password",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            // Password Field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter your password",
                filled: true,
                fillColor: Colors.white,
                suffixIcon:
                    const Icon(Icons.visibility_outlined, color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primaryLight, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  // show loader
                  Get.dialog(
                    Center(child: wheelloader()),
                    barrierDismissible: false,
                  );

                  await Future.delayed(const Duration(seconds: 2));

                  Get.back();

                  Get.toNamed(Routes.dashboard);
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhiteLight,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // OR Divider
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("OR"),
                ),
                Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 25),

            // Google Button
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons
                      .account_balance), //Image.asset("assets/icons/google.png", height: 22),
                  SizedBox(width: 12),
                  Text(
                    "Continue with Google",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Apple Button
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 26, color: Colors.black),
                  SizedBox(width: 12),
                  Text(
                    "Continue with Apple",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class Signup extends GetView<LoginController> {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    //final controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Text(
              "Create Account",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),

            const SizedBox(height: 25),

            // FIRST NAME
            SignupInputField(
              label: "First Name",
              hint: "Enter your first name",
              controller: controller.firstCtrl,
            ),
            const SizedBox(height: 20),

            // LAST NAME
            SignupInputField(
              label: "Last Name",
              hint: "Enter your last name",
              controller: controller.lastCtrl,
            ),
            const SizedBox(height: 20),

            // EMAIL
            SignupInputField(
              label: "Email",
              hint: "Enter your email",
              controller: controller.emailCtrl,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // MOBILE
            SignupInputField(
              label: "Mobile Number",
              hint: "Enter your mobile number",
              controller: controller.mobileCtrl,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // PASSWORD
            Obx(() => SignupInputField(
                  label: "Password",
                  hint: "Enter password",
                  controller: controller.passCtrl,
                  obscure: controller.hidePass.value,
                  onToggle: () {
                    controller.hidePass.value = !controller.hidePass.value;
                  },
                )),
            const SizedBox(height: 20),

            // CONFIRM PASSWORD
            Obx(() => SignupInputField(
                  label: "Confirm Password",
                  hint: "Re-enter password",
                  controller: controller.confirmCtrl,
                  obscure: controller.hideConfirm.value,
                  onToggle: () {
                    controller.hideConfirm.value =
                        !controller.hideConfirm.value;
                  },
                )),
            const SizedBox(height: 25),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Get.toNamed(Routes.otpPage);
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhiteLight,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?",
                    style: TextStyle(color: Colors.black54)),
                TextButton(
                  onPressed: () {
                    DefaultTabController.of(context).animateTo(0);
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////
// REUSABLE INPUT FIELD WIDGET — INSIDE SAME FILE (NOT SEPARATE)
/////////////////////////////////////////////////////////////////

class SignupInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboard;
  final bool obscure;
  final VoidCallback? onToggle;

  const SignupInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,

            // Eye icon for password
            suffixIcon: onToggle != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: onToggle,
                  )
                : null,

            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
