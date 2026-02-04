import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:car_wash_customer_app/app/models/instores_model.dart';
import 'package:car_wash_customer_app/app/repositories/instore_repository.dart';

class InstoreWashController extends GetxController {
  final InstoreRepository repository = InstoreRepository();

  RxBool isLoading = false.obs;
  RxList<InstoresModel> stores = <InstoresModel>[].obs;

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
    } catch (e) {
      print("Error fetching stores: $e");
    } finally {
      isLoading.value = false;
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
