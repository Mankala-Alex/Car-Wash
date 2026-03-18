import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/location_list_controller.dart';

class LocationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookSlotController>(() => BookSlotController());
    Get.lazyPut<LocationListController>(() => LocationListController());
  }
}
