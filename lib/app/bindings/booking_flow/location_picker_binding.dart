import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/location_picker_controller.dart';

class LocationPickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationPickerController>(
      () => LocationPickerController(),
    );
  }
}
