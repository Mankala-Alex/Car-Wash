import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/offer_screen_controller.dart';

class OfferScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OfferScreenController>(() => OfferScreenController());
  }
}
