import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/add_location_controller.dart';

class AddLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddLocationController>(() => AddLocationController());
  }
}
