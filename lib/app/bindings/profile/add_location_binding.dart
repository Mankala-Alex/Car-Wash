import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/add_location_controller.dart';

class AddLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddLocationController>(() => AddLocationController());
  }
}
