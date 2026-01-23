import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/booking%20slot/services_model.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/book_slot_repository.dart';

class FeaturesListController extends GetxController {
  final BookSlotRepository repository = BookSlotRepository();

  var services = <Servicesmodel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    getAllServices();
    super.onInit();
  }

  Future<void> getAllServices() async {
    try {
      isLoading.value = true;

      final response = await repository.fetchAllServices();

      List data = response.data;
      services.value = data.map((e) => Servicesmodel.fromJson(e)).toList();
    } catch (e) {
      print("Error loading services: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
