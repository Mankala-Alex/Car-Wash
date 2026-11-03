import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/support/booking_help_controller.dart';

class BookingHelpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingHelpController>(() => BookingHelpController());
  }
}
