import 'package:get/get.dart';
import 'package:my_new_app/app/helpers/shared_preferences.dart';
import 'package:my_new_app/app/services/api_service.dart';

class CarListController extends GetxController {
  String customerId = ""; // ← ADD THIS
  RxList customerVehicles = [].obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomerId(); // ← LOAD FIRST
  }

  // Load customerId from SharedPrefs
  Future<void> loadCustomerId() async {
    customerId = await SharedPrefsHelper.getString("customerUuid") ?? "";

    if (customerId.isEmpty) {
      print("❌ No customerId found");
      return;
    }

    fetchVehicles(); // ← Fetch after ID is ready
  }

  Future<void> fetchVehicles() async {
    try {
      isLoading.value = true; // 🔥 START LOADING

      final response = await ApiService.get(
        "customer-vehicles?customer_id=$customerId",
        requireAuthToken: true,
      );

      if (response.statusCode == 200) {
        customerVehicles.value = response.data;
      }
    } catch (e) {
      print("Vehicle fetch failed: $e");
    } finally {
      isLoading.value = false; // 🔥 STOP LOADING (THIS FIXES EVERYTHING)
    }
  }
}
