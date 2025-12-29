import 'package:get/get.dart';

class ScratchCardController extends GetxController {
  String? bookingCode;

  @override
  void onInit() {
    super.onInit();
    bookingCode = Get.arguments as String?;
    print("🎟 ScratchCard bookingCode = $bookingCode");
  }

  var revealed = false.obs;
  var showAnimation = false.obs;

  void onScratchComplete() {
    revealed.value = true;
    showAnimation.value = true;
  }

  void animationFinished() {
    showAnimation.value = false;
  }
}
