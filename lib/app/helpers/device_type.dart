import 'package:get/get.dart';

class DeviceType {
  static String getDeviceType() {
    if (GetPlatform.isAndroid) {
      return 'Android';
    } else if (GetPlatform.isIOS) {
      return 'iOS';
    } else {
      return 'Others';
    }
  }
}
