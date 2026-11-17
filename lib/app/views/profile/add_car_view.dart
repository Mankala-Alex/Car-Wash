import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/add_car_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class AddCarView extends GetView<AddCarController> {
  const AddCarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "add_vehicle".tr,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      // ---------------- BOTTOM BUTTON ----------------
      //
      // Disabled while saving - the controller shows a non-dismissible wheel
      // loader overlay (transparent background) until the vehicle is saved
      // (min 1s), so tapping again could add the vehicle twice.
      bottomNavigationBar: Obx(() {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      controller.submitVehicle(); // API CALL
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                disabledBackgroundColor: AppColors.secondaryLight.withValues(
                  alpha: 0.6,
                ),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "save_vehicle".tr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),

      // -------------------- FORM --------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(
              "vehicle_number".tr,
              controller.vehicleNumberController,
              TextInputType.text,
            ),
            const SizedBox(height: 16),
            _inputField(
              "brand".tr,
              controller.makeController,
              TextInputType.text,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ---- INPUT FIELD WIDGET ----
  Widget _inputField(
    String label,
    TextEditingController ctrl,
    TextInputType type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
