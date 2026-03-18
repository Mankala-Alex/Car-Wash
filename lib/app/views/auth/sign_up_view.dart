import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/auth/sign_up_controller.dart';
import '../../theme/app_theme.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _input("First Name", controller.firstNameCtrl),
            const SizedBox(height: 20),
            _input("Last Name", controller.lastNameCtrl),
            const SizedBox(height: 20),
            _input(
              "Email",
              controller.emailCtrl,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _input(
              "Phone Number", // ✅ NEW FIELD
              controller.phoneCtrl,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submitSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    // Determine input formatters based on field type
    List<TextInputFormatter> inputFormatters = [];

    if (label == "First Name" || label == "Last Name") {
      // Allow only letters and spaces
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ];
    } else if (label == "Phone Number") {
      // Allow only digits
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
