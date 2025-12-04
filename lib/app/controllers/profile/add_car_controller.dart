import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';

class AddCarController extends GetxController {
  /// -------------------------------
  /// FORM FIELDS
  /// -------------------------------
  final customerIdController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final typeController = TextEditingController();

  /// -------------------------------
  /// LOADING
  /// -------------------------------
  final isLoading = false.obs;

  /// -------------------------------
  /// USE YOUR REPOSITORY
  /// -------------------------------
  final BookSlotRepository repository = BookSlotRepository();

  /// -------------------------------
  /// SUBMIT FORM → CALL API
  /// -------------------------------
  Future<void> submitVehicle() async {
    if (!_validateForm()) return;

    isLoading.value = true;

    final body = {
      "customer_id": customerIdController.text.trim(),
      "vehicle_number": vehicleNumberController.text.trim(),
      "make": makeController.text.trim(),
      "model": modelController.text.trim(),
      "type": typeController.text.trim(),
    };

    try {
      final response = await repository.postAddVehicle(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Vehicle added successfully!",
          backgroundColor: Colors.green.withOpacity(0.2),
          colorText: Colors.black,
        );

        clearForm();
        Get.back();
      } else {
        Get.snackbar(
          "Failed",
          "Unable to save vehicle",
          backgroundColor: Colors.red.withOpacity(0.2),
          colorText: Colors.black,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong",
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.black,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// -------------------------------
  /// FORM VALIDATION
  /// -------------------------------
  bool _validateForm() {
    if (customerIdController.text.isEmpty ||
        vehicleNumberController.text.isEmpty ||
        makeController.text.isEmpty ||
        modelController.text.isEmpty ||
        typeController.text.isEmpty) {
      Get.snackbar(
        "Missing Info",
        "Please fill all fields",
        backgroundColor: Colors.amber.withOpacity(0.2),
        colorText: Colors.black,
      );
      return false;
    }
    return true;
  }

  /// -------------------------------
  /// CLEAR FORM
  /// -------------------------------
  void clearForm() {
    customerIdController.clear();
    vehicleNumberController.clear();
    makeController.clear();
    modelController.clear();
    typeController.clear();
  }

  /// -------------------------------
  /// DISPOSE
  /// -------------------------------
  @override
  void onClose() {
    customerIdController.dispose();
    vehicleNumberController.dispose();
    makeController.dispose();
    modelController.dispose();
    typeController.dispose();
    super.onClose();
  }
}
