import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConfirmationPageController extends GetxController {
  late String serviceName;
  late String scheduledAt;
  late dynamic amount;
  late String image;
  late String bookingCode;

  String get formattedDate {
    final dt = DateTime.tryParse(scheduledAt);
    if (dt == null) return "";
    // `scheduled_at` is already the wall-clock slot time (built with
    // DateTime.utc in buildScheduledAt and stored the same way by the backend),
    // so do NOT call toLocal() — that would apply the device timezone offset a
    // second time and shift the displayed time.
    return DateFormat('EEE, dd MMM • hh:mm a').format(dt);
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    serviceName = args["service_name"] ?? "";
    scheduledAt = args["scheduled_at"] ?? "";

    /// ⭐ FIX HERE
    amount = args["amount"]?.toString() ?? "";

    image = args["image"] ?? "";
    //bookingCode = args["booking_code"] ?? "";
    bookingCode = (args["booking_code"] ??
            args["booking_reference"] ??
            args["bookingId"] ??
            "")
        .toString();
  }
}
