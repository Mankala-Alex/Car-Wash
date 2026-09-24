import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';

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
    customerId = await SharedPrefsHelper.getString("customerUuid");

    if (customerId.isEmpty) {
      print("❌ No customerId found");
      return;
    }

    fetchVehicles(); // ← Fetch after ID is ready
  }

  List<dynamic> _normalizeVehicleList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final list = data['data'];
      if (list is List) return list;
      if (data['vehicles'] is List) return data['vehicles'];
      if (data['customerVehicles'] is List) return data['customerVehicles'];
    }
    return [];
  }

  Future<void> fetchVehicles() async {
    try {
      isLoading.value = true;

      final response = await ApiService.get(
        "customer-vehicles/me",
        requireAuthToken: true,
      );

      if (response.statusCode == 200) {
        customerVehicles.value = _normalizeVehicleList(response.data);
      }
    } catch (e) {
      print("Vehicle fetch failed: $e");
      customerVehicles.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
