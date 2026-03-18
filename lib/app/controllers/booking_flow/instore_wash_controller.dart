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
      List data = response.data;

      stores.value = data.map((e) => InstoresModel.fromJson(e)).toList();
      filteredStores.value = stores;
    } catch (e) {
      print("Error fetching stores: $e");
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
      print('Phone call error: $e');
    }
  }
}
