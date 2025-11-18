import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isInternet() async {
  try {
    final List<ConnectivityResult> resultList = await Connectivity().checkConnectivity();
    final ConnectivityResult result = resultList.first;

    if (result == ConnectivityResult.none) {
      print("No internet connection. Please check your connection.");
      return false;
    } else {
      print("Internet connection is available.");
      return true;
    }
  } catch (e) {
    print("Error checking internet connectivity: ${e.toString()}");
    return false;
  }
}
