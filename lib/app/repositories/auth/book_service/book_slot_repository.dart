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
    return await ApiService.post(
      EndPoints.apiPostrequstotp,
      requestBody,
      requireAuthToken: false,
    );
  }

  Future<Response> postAddVehicle(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostAddvehicle,
      requestBody,
      requireAuthToken: true, // ✅ FIX
    );
  }

  Future<Response> apigetvehicles(String customerId) async {
    return await ApiService.get("customer-vehicles/me", requireAuthToken: true);
  }

  /// Loads the bookable dates.
  ///
  /// `availableOnly=true` makes the backend drop dates that no longer have a
  /// slot a customer can book (full, already started, or starting within the
  /// 60 minute lead time) — so a finished day disappears from the picker.
  Future<Response> apiGetslotdates({bool availableOnly = false}) async {
    final url = availableOnly
        ? "${EndPoints.apiGetslotdates}?availableOnly=true"
        : EndPoints.apiGetslotdates;

    return await ApiService.get(url);
  }

  /// Loads the time slots of a date.
  ///
  /// [availableOnly] asks the backend to drop the slots whose seats are already
  /// taken (booked + temporarily reserved by an in-flight payment), so the
  /// customer can only pick a time that still has capacity.
  Future<Response> apiGettimeslots(
    int dateId, {
    bool availableOnly = false,
  }) async {
    final url = availableOnly
        ? "${EndPoints.apiGettimeslots}?dateId=$dateId&availableOnly=true"
        : "${EndPoints.apiGettimeslots}?dateId=$dateId";

    return await ApiService.get(url);
  }

  Future<Response> postBookingsHistory(requestBody) async {
    return await ApiService.post(
      EndPoints.apiGetbookinghistory,
      requestBody,
      requireAuthToken: true,
    );
  }

  Future<Response> postBookSlot(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostbookslot,
      requestBody,
      requireAuthToken: true,
    );
  }

  /// Verifies whether a location is covered by an active service area.
  ///
  /// The map pin is authoritative: the device geocoder regularly returns a
  /// missing or incorrect Saudi postal code (e.g. Plus Codes such as
  /// "8P2J+H2V, Khamis Mushait"), so coordinates are always forwarded and the
  /// backend reverse-geocodes them into a pincode + city.
  ///
  /// The raw [pincode] is only sent when no coordinates are available.
  /// The endpoint also accepts `city` / `formatted_address`, but sending those
  /// alongside the pin would take priority over the coordinates on the server.
  Future<Response> checkCustomerServiceability(
    String? pincode, {
    double? latitude,
    double? longitude,
  }) async {
    final params = <String, dynamic>{};

    if (latitude != null && longitude != null) {
      params['latitude'] = latitude;
      params['longitude'] = longitude;
    } else {
      final normalized = (pincode ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      if (normalized.isNotEmpty) {
        params['pincode'] = normalized;
      }
    }

    return await ApiService.get(
      EndPoints.apiCheckCustomerServiceability,
      params: params,
      requireAuthToken: true,
    );
  }

  Future<Response> cancelBooking(String bookingCode) async {
    return await ApiService.delete(
      "/bookings/$bookingCode",
      requireAuthToken: true,
    );
  }

  /// Returns the cancellation policy, the reason list and whether this booking
  /// may still be cancelled (GET /api/bookings/:id/cancellation-policy).
  Future<Response> getCancellationPolicy(String bookingId) async {
    return await ApiService.get(
      "/bookings/$bookingId/cancellation-policy",
      requireAuthToken: true,
    );
  }

  /// Creates a cancellation request that an admin approves in the portal.
  /// No refund happens here — the money moves only after approval.
  Future<Response> requestCancellation(
    String bookingId, {
    required String reasonCode,
    String? notes,
  }) async {
    return await ApiService.post("/bookings/$bookingId/cancellation-request", {
      "reason_code": reasonCode,
      if (notes != null && notes.trim().isNotEmpty)
        "reason_notes": notes.trim(),
    }, requireAuthToken: true);
  }

  Future<Response> updateBooking(
    String bookingCode,
    Map<String, dynamic> body,
  ) async {
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
