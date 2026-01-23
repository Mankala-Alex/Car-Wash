import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';

class AddCarController extends GetxController {
  final BookSlotRepository repository = BookSlotRepository();

  final vehicleNumberController = TextEditingController();
  final makeController = TextEditingController();
  final modelController = TextEditingController();
  final typeController = TextEditingController();

  String customerId = "";
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomerId();
  }

  Future<void> loadCustomerId() async {
    customerId = await SharedPrefsHelper.getString("customerUuid") ?? "";
    print("LOADED customerUuid = $customerId");

    if (customerId.isEmpty) {
      errorToast("Customer UUID not found");
    }
  }

  Future<void> submitVehicle() async {
    if (customerId.isEmpty) {
      errorToast("Customer UUID not found");
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

    // Duplicate Check
    try {
      final existing = await ApiService.get(
        "customer-vehicles?customer_id=$customerId",
        requireAuthToken: true,
      );

      final alreadyExists = (existing.data as List).any((v) =>
          v["vehicle_number"].toString().toLowerCase().trim() ==
          vehicleNumberController.text.toLowerCase().trim());

      if (alreadyExists) {
        errorToast("This vehicle number already exists");
        isLoading.value = false;
        return;
      }
    } catch (e) {
      print("❌ Duplicate check error: $e");
    }

    final body = {
      "customer_id": customerId,
      "vehicle_number": vehicleNumberController.text.trim(),
      "make": makeController.text.trim(),
      "model": modelController.text.trim(),
      "type": typeController.text.trim()
    };

    print("📤 ADD VEHICLE BODY → $body");

    try {
      final response = await repository.postAddVehicle(body);
      print("📥 RESPONSE → ${response.data}");

      if (response.data["success"] == true) {
        successToast("Vehicle added successfully");
        Get.back(result: true);
      } else {
        errorToast(response.data["error"] ?? "Unable to add vehicle");
      }
    } catch (e) {
      errorToast("Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
