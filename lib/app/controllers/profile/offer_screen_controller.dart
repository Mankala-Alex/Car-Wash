import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/offers_model.dart';

class OfferScreenController extends GetxController {
  late Offersmodel offer;

  @override
  void onInit() {
    offer = Get.arguments as Offersmodel;
    super.onInit();
  }

  /// Converts expiry days → actual expiry date
  String getExpiryDate(int expiryDays) {
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: expiryDays));
    return "${expiryDate.day}-${expiryDate.month}-${expiryDate.year}";
  }
}
