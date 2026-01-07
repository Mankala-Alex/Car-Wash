import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/booking_history_details_controller.dart';

class BookingHistoryDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingHistoryDetailsController>(
        () => BookingHistoryDetailsController());
  }
}
