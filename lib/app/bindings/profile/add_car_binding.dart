import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/add_car_controller.dart';

class AddCarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddCarController>(() => AddCarController());
  }
}
