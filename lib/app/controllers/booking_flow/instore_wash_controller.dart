import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:car_wash_customer_app/app/models/instores_model.dart';
import 'package:car_wash_customer_app/app/repositories/instore_repository.dart';

class InstoreWashController extends GetxController {
  final InstoreRepository repository = InstoreRepository();

  RxBool isLoading = false.obs;
  RxList<InstoresModel> stores = <InstoresModel>[].obs;
  RxList<InstoresModel> filteredStores = <InstoresModel>[].obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    fetchInStoreWashStores();
    super.onInit();
  }

  Future<void> fetchInStoreWashStores() async {
    try {
      isLoading.value = true;

      final response = await repository.getInStoreWashStores();
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : <dynamic>[];

      stores.value = data.map((e) => InstoresModel.fromJson(e)).toList();
      filteredStores.value = List<InstoresModel>.from(stores);
    } catch (e) {
      debugPrint("Error fetching stores: $e");
      stores.clear();
      filteredStores.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ===== SEARCH FUNCTION =====
  void searchStores(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredStores.value = stores;
    } else {
      filteredStores.value = stores
          .where((store) =>
              store.companyName.toLowerCase().contains(query.toLowerCase()) ||
              store.city.toLowerCase().contains(query.toLowerCase()) ||
              store.streetName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // ===== PHONE CALL FUNCTION =====
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Phone call error: $e');
    }
  }

  // ===== OPEN GOOGLE MAPS WITH NAVIGATION =====
  Future<void> openLocationInGoogleMaps(double lat, double lng) async {
    if (lat == 0 && lng == 0) {
      debugPrint('Location coordinates are missing');
      return;
    }

    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Google Maps launch error: $e');
    }
  }
}
