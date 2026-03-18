import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/book_slot_controller.dart';
import 'package:car_wash_customer_app/app/controllers/profile/location_details_controller.dart';

class LocationDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookSlotController>(() => BookSlotController());
    Get.lazyPut<LocationDetailsController>(() => LocationDetailsController());
  }
}
