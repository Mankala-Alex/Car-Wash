import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

class ProfileRepository {
  Future<Response> fetchoffers() async {
    return await ApiService.get(EndPoints.apiGetfetchoffers);
  }

  Future<Response> getCustomerCoupon(String bookingCode) async {
    return await ApiService.get(
      "${EndPoints.apiGetcoupons}?booking_code=$bookingCode",
    );
  }

  Future<Response> apiGetcouponslist() async {
    return await ApiService.get(EndPoints.apiGetcouponslist);
  }

  Future<Response> apiGetCouponDetails() async {
    return await ApiService.get(EndPoints.apigetcoupondetails);
  }
}
