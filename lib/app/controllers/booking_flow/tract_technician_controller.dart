import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/booking slot/booking_history_model.dart';

class TrackTechnicianController extends GetxController {
  late Rx<Datum> booking;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;

    if (arg != null && arg is Datum) {
      booking = arg.obs;
    } else {
      // safety fallback
      booking = Datum(
        id: "",
        bookingCode: "",
        customerName: "",
        vehicle: "",
        serviceId: "",
        serviceName: "",
        scheduledAt: null,
        washerId: null,
        washerName: null,
        status: "",
        amount: "",
        slotId: 0,
        customerId: "",
        images: [],
        videos: [],
      ).obs;
    }
  }
}
