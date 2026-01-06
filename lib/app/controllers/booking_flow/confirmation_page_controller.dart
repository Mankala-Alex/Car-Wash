import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ConfirmationPageController extends GetxController {
  late String serviceName;
  late String scheduledAt;
  late String amount;
  late String image;
  late String bookingCode;

  String get formattedDate {
    final dt = DateTime.tryParse(scheduledAt);
    if (dt == null) return "";
    return DateFormat('EEE, dd MMM • hh:mm a').format(dt.toLocal());
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    serviceName = args["service_name"] ?? "";
    scheduledAt = args["scheduled_at"] ?? "";
    amount = args["amount"] ?? "";
    image = args["image"] ?? "";
    bookingCode = args["booking_code"] ?? "";
  }
}
