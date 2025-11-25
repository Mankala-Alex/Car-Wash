import 'package:get/get.dart';

class ScratchCardController extends GetxController {
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
