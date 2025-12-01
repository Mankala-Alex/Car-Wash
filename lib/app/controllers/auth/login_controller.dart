import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
// Sign Up Screen  //
  // Text Controllers
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  // Password visibility
  var hidePass = true.obs;
  var hideConfirm = true.obs;
}
