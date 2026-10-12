import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

class BookSlotRepository {
  // Future<Response> postGetMobAllCategory(requestBody) async {
  //   return await ApiService.post(EndPoints.apiGetMobAllCategory, requestBody);
  // }
  Future<Response> fetchAllServices() async {
    return await ApiService.get(EndPoints.apiGetAllServices);
  }

  Future<Response> fetchoffers() async {
    return await ApiService.get(EndPoints.apiGetfetchoffers);
  }

  Future<Response> postRequestOtp(requestBody) async {
    return await ApiService.post(EndPoints.apiPostrequstotp, requestBody,
        requireAuthToken: false);
  }

  Future<Response> postAddVehicle(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostAddvehicle,
      requestBody,
      requireAuthToken: true, // ✅ FIX
    );
  }

  Future<Response> apigetvehicles(String customerId) async {
    return await ApiService.get(
      "customer-vehicles/me",
      requireAuthToken: true,
    );
  }

  Future<Response> apiGetslotdates() async {
    return await ApiService.get(EndPoints.apiGetslotdates);
  }

  Future<Response> apiGettimeslots(int dateId) async {
    return await ApiService.get("${EndPoints.apiGettimeslots}?dateId=$dateId");
  }

  Future<Response> postBookingsHistory(requestBody) async {
    return await ApiService.post(EndPoints.apiGetbookinghistory, requestBody,
        requireAuthToken: true);
  }

  Future<Response> postBookSlot(requestBody) async {
    return await ApiService.post(EndPoints.apiPostbookslot, requestBody,
        requireAuthToken: true);
  }

  Future<Response> checkCustomerServiceability(String pincode) async {
    return await ApiService.get(
      EndPoints.apiCheckCustomerServiceability,
      params: {'pincode': pincode},
      requireAuthToken: true,
    );
  }

  Future<Response> cancelBooking(String bookingCode) async {
    return await ApiService.delete(
      "/bookings/$bookingCode",
      requireAuthToken: true,
    );
  }

  Future<Response> updateBooking(
      String bookingCode, Map<String, dynamic> body) async {
    return await ApiService.put(
      "/bookings/$bookingCode",
      body,
      requireAuthToken: true,
    );
  }

  Future<Response> createReview(Map<String, dynamic> requestBody) async {
    return await ApiService.post(
      EndPoints.apiCreateReview,
      requestBody,
      requireAuthToken: true,
    );
  }

  Future<Response> getReviewByBooking(String bookingId) async {
    return await ApiService.get(
      "${EndPoints.apiGetReviewByBooking}/$bookingId",
      requireAuthToken: true,
    );
  }

  Future<Response> getMyReviews() async {
    return await ApiService.get(
      EndPoints.apiGetMyReviews,
      requireAuthToken: true,
    );
  }
}
