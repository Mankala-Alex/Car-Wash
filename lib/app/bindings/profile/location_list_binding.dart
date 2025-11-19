import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/location_list_controller.dart';

class LocationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationListController>(() => LocationListController());
  }
}
