import 'package:dio/dio.dart';

import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

/// Coupons the customer can apply while booking.
///
/// Both calls are read-only; the coupon is consumed by `payment/create` on the
/// backend, which re-validates every rule (service, day, slot, usage limit).
class OfferCouponRepository {
  /// Coupons usable for this service + slot (already filtered by the backend).
  Future<Response> getAvailableCoupons({
    required String serviceId,
    required int slotId,
  }) async {
    return await ApiService.get(
      EndPoints.apiOfferCoupons,
      params: {"service_id": serviceId, if (slotId > 0) "slot_id": slotId},
      requireAuthToken: true,
    );
  }

  /// Validates one code and returns the price breakdown with the discount.
  Future<Response> validateCoupon({
    required String code,
    required String serviceId,
    int slotId = 0,
  }) async {
    return await ApiService.post(EndPoints.apiValidateOfferCoupon, {
      "coupon_code": code,
      "service_id": serviceId,
      if (slotId > 0) "slot_id": slotId,
    }, requireAuthToken: true);
  }
}
