import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class ProfileRepository {
  Future<Response> fetchoffers() async {
    return await ApiService.get(EndPoints.apiGetfetchoffers);
  }

  Future<Response> getCustomerCoupon(String bookingCode) async {
    return await ApiService.get(
      "${EndPoints.apiGetcoupons}?booking_code=$bookingCode",
    );
  }
}
