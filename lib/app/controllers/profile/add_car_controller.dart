import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/flutter_toast.dart';
import 'package:my_new_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/services/api_service.dart';

class AddCarController extends GetxController {
  // Repository
  final BookSlotRepository repository = BookSlotRepository();

  // Text fields
  final vehicleNumberController = TextEditingController();
  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final typeController = TextEditingController();

  // Hidden (auto-loaded)
  String customerId = "";

  // Loading state
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomerId();
  }

  // -------------------------------------------------------------
  // LOAD CUSTOMER ID FROM SHARED PREFS (AUTO)
  // -------------------------------------------------------------
  Future<void> loadCustomerId() async {
    customerId = await SharedPrefsHelper.getString("customerId") ?? "";

    if (customerId.isEmpty) {
      Get.snackbar("Error", "Customer ID not found");
    }
  }

  // -------------------------------------------------------------
  // SUBMIT VEHICLE API CALL
  // -------------------------------------------------------------
  Future<void> submitVehicle() async {
    if (customerId.isEmpty) {
      errorToast("Customer ID not found");
      return;
    }

    if (vehicleNumberController.text.trim().isEmpty ||
        makeController.text.trim().isEmpty ||
        modelController.text.trim().isEmpty ||
        typeController.text.trim().isEmpty) {
      errorToast("Please fill all fields");
      return;
    }

    isLoading.value = true;

    // ----- CHECK DUPLICATE VEHICLE NUMBER -----
    try {
      final existing = await ApiService.get("customer-vehicles");

      final alreadyExists = (existing.data as List).any((v) =>
          v["vehicle_number"].toString().toLowerCase().trim() ==
          vehicleNumberController.text.toLowerCase().trim());

      if (alreadyExists) {
        errorToast("This vehicle number already exists");
        isLoading.value = false;
        return;
      }
    } catch (e) {}

    final body = {
      "customer_id": customerId,
      "vehicle_number": vehicleNumberController.text.trim(),
      "make": makeController.text.trim(),
      "model": modelController.text.trim(),
      "type": typeController.text.trim()
    };

    try {
      final response = await repository.postAddVehicle(body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Return immediately to refresh previous screen
        successToast("Vehicle added successfully");
        Get.back(result: true);
        return;
      } else {
        errorToast("Unable to add vehicle");
      }
    } catch (e) {
      errorToast("Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
