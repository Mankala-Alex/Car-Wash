import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/booking slot/booking_history_model.dart';

class BookingHistoryDetailsController extends GetxController {
  late Datum booking;

  @override
  void onInit() {
    booking = Get.arguments as Datum;
    super.onInit();
  }
}
