import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_new_app/app/models/coupons_list_model.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';
import '../../helpers/shared_preferences.dart';

class CouponsListController extends GetxController {
  var isLoading = false.obs;
  var coupons = <CouponsListModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    try {
      isLoading.value = true;

      final customerId = await SharedPrefsHelper.getString("customerUuid");

      final response = await ApiService.get(
        "${EndPoints.apiGetcouponslist}?customer_id=$customerId",
      );

      final List list = response.data['data'];
      coupons.value = list.map((e) => CouponsListModel.fromJson(e)).toList();
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  bool canUse(CouponsListModel coupon) {
    return coupon.status == "ACTIVE" && !coupon.isExpired;
  }
}
