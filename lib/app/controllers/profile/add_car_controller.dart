import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/custome_widgets/wheel_loader.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/book_slot_repository.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';

class AddCarController extends GetxController {
  final BookSlotRepository repository = BookSlotRepository();

  final vehicleNumberController = TextEditingController();
  final makeController = TextEditingController();

  String customerId = "";
  var isLoading = false.obs;

  /// How long the wheel loader is kept visible at least, so a very fast save
  /// does not make the screen flash.
  static const Duration _minimumLoaderTime = Duration(seconds: 1);

  @override
  void onInit() {
    super.onInit();
    loadCustomerId();
  }

  Future<void> loadCustomerId() async {
    customerId = await SharedPrefsHelper.getString("customerUuid") ?? "";
    print("LOADED customerUuid = $customerId");

    if (customerId.isEmpty) {
      errorToast("customer_uuid_not_found".tr);
    }
  }

  Future<void> submitVehicle() async {
    // Guards against a double tap while the loader is showing.
    if (isLoading.value) return;

    if (customerId.isEmpty) {
      errorToast("customer_uuid_not_found".tr);
      return;
    }

    if (vehicleNumberController.text.trim().isEmpty ||
        makeController.text.trim().isEmpty) {
      errorToast("please_fill_all_fields".tr);
      return;
    }

    isLoading.value = true;
    showWheelLoaderDialog(size: 120);

    // Started now and awaited at the end: guarantees the wheel loader is shown
    // for at least one second even when the vehicle is saved instantly.
    final minimumLoaderTime = Future<void>.delayed(_minimumLoaderTime);

    var saved = false;

    try {
      // Duplicate Check
      try {
        final existing = await ApiService.get(
          "customer-vehicles?customer_id=$customerId",
          requireAuthToken: true,
        );

        final alreadyExists = (existing.data as List).any(
          (v) =>
              v["vehicle_number"].toString().toLowerCase().trim() ==
              vehicleNumberController.text.toLowerCase().trim(),
        );

        if (alreadyExists) {
          errorToast("this_vehicle_number_already_exists".tr);
          return;
        }
      } catch (e) {
        print("❌ Duplicate check error: $e");
      }

      final body = {
        "customer_id": customerId,
        "vehicle_number": vehicleNumberController.text.trim(),
        "make": makeController.text.trim(),
      };

      print("📤 ADD VEHICLE BODY → $body");

      final response = await repository.postAddVehicle(body);
      print("📥 RESPONSE → ${response.data}");

      if (response.data["success"] == true) {
        saved = true;
      } else {
        errorToast(response.data["error"] ?? "unable_to_add_vehicle".tr);
      }
    } catch (e) {
      print("Add vehicle error: $e");
      errorToast("something_went_wrong".tr);
    } finally {
      // Never dismiss the loader before the minimum time has elapsed.
      await minimumLoaderTime;

      hideWheelLoaderDialog();
      isLoading.value = false;
    }

    // Failed / duplicate - keep the customer on this screen.
    if (!saved) return;

    successToast("vehicle_added_successfully".tr);
    Get.back(result: true);
  }
}
