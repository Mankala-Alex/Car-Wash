import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/add_car_controller.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Add Vehicle",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      // ---------------- BOTTOM BUTTON ----------------
      bottomNavigationBar: Obx(
        () => Container(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    controller.submitVehicle(); // CALLS API
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isLoading.value
                  ? Colors.grey
                  : AppColors.secondaryLight,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Save Vehicle",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),

      // ---------------- FORM BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField("Customer ID", controller.customerIdController,
                TextInputType.text),
            const SizedBox(height: 16),
            _inputField("Vehicle Number", controller.vehicleNumberController,
                TextInputType.text),
            const SizedBox(height: 16),
            _inputField(
                "Make (Brand)", controller.makeController, TextInputType.text),
            const SizedBox(height: 16),
            _inputField(
                "Model", controller.modelController, TextInputType.text),
            const SizedBox(height: 16),
            _inputField("Type (Sedan, SUV, etc.)", controller.typeController,
                TextInputType.text),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---- INPUT FIELD WIDGET ----
  Widget _inputField(
      String label, TextEditingController ctrl, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            )),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
