import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

/// Customer coupon endpoints.
///
/// Coupons are view-only for the customer: the backend awards them when a
/// booking is marked `COMPLETED` and the partner app validates/redeems them.
/// The customer app never sends a `coupon_code` to booking or payment.
class CouponRepository {
  /// `GET /api/coupons/my` — authenticated, no query parameters, no body.
  Future<Response> fetchMyCoupons() async {
    return await ApiService.get(
      EndPoints.apiGetMyCoupons,
      requireAuthToken: true,
    );
  }

  /// `GET /api/coupons/details?coupon_code=...`
  Future<Response> fetchCouponDetails(String couponCode) async {
    return await ApiService.get(
      EndPoints.apigetcoupondetails,
      params: {'coupon_code': couponCode},
    );
  }
}

/// Maps a coupon request failure to the localization key the UI should show.
String couponErrorKey(Object error) {
  if (error is DioException) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) return 'session_expired';
    if (statusCode == 404) return 'coupon_not_found';
  }
  return 'failed_to_load_coupons';
}
