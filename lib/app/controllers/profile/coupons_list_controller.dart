import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/models/coupons_list_model.dart';
import 'package:car_wash_customer_app/app/repositories/coupon/coupon_repository.dart';
import 'package:car_wash_customer_app/app/services/socket_service.dart';

/// Drives the My Coupons screen.
///
/// Coupons are awarded by the backend only when a booking becomes `COMPLETED`,
/// so the list is refreshed:
/// * when the screen opens,
/// * when the `booking_completed` socket event arrives,
/// * when the app returns to the foreground.
class CouponsListController extends GetxController with WidgetsBindingObserver {
  final CouponRepository _repository = CouponRepository();

  final isLoading = false.obs;
  final coupons = <CouponsListModel>[].obs;

  /// Localization key of the last load error (`''` when there is none).
  final errorKey = ''.obs;

  Worker? _bookingCompletedWorker;

  /// Active coupons, i.e. `status == ACTIVE` and not expired.
  List<CouponsListModel> get availableCoupons =>
      coupons.where((coupon) => coupon.isActive).toList();

  /// Used / expired coupons.
  List<CouponsListModel> get historyCoupons =>
      coupons.where((coupon) => coupon.isHistory).toList();

  bool get hasCoupons => coupons.isNotEmpty;

  @override
  void onInit() {
    super.onInit();

    // Refresh when the app resumes. Registered once per screen instance and
    // removed in [onClose], so observers are never duplicated.
    WidgetsBinding.instance.addObserver(this);

    _listenToBookingCompleted();
    fetchCoupons();
  }

  /// A coupon is issued when the service is completed, not when payment
  /// succeeds — refresh on that socket event.
  void _listenToBookingCompleted() {
    if (!Get.isRegistered<SocketService>()) return;

    final socketService = Get.find<SocketService>();
    _bookingCompletedWorker = ever(socketService.bookingCompletedEvent, (data) {
      if (data != null) {
        fetchCoupons();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchCoupons();
    }
  }

  Future<void> fetchCoupons() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorKey.value = '';

      final response = await _repository.fetchMyCoupons();
      final body = response.data;

      if (body is! Map || body['success'] != true) {
        throw Exception('Unexpected coupons payload: $body');
      }

      final rawList = body['data'];
      final list = rawList is List
          ? rawList
              .whereType<Map>()
              .map((item) =>
                  CouponsListModel.fromJson(Map<String, dynamic>.from(item)))
              .toList()
          : <CouponsListModel>[];

      coupons.assignAll(list);
    } catch (e) {
      print('❌ Error fetching coupons: $e');

      final key = couponErrorKey(e);

      if (coupons.isEmpty) {
        errorKey.value = key;
      } else {
        // Keep the coupons already on screen, just inform the user.
        errorToast(key.tr);
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _bookingCompletedWorker?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
