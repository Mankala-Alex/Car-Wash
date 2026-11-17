import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:car_wash_customer_app/app/models/offers_model.dart';

class OfferScreenController extends GetxController {
  late Offersmodel offer;

  @override
  void onInit() {
    offer = Get.arguments as Offersmodel;
    super.onInit();
  }

  /// Expiry = the offer's creation date + its validity in days (that is what
  /// the backend uses), shown as `dd-MM-yyyy`.
  String getExpiryDate(Offersmodel offer) {
    final base = DateTime.tryParse(offer.createdAt) ?? DateTime.now();
    final expiryDate = base.add(Duration(days: offer.expiryDays));
    return DateFormat('dd-MM-yyyy').format(expiryDate);
  }
}
