import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/booking_qr_coupon_controller.dart';

class BookingQrCouponBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingQrCouponController>(() => BookingQrCouponController());
  }
}
