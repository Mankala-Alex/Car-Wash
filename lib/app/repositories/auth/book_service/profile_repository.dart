import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

class ProfileRepository {
  Future<Response> fetchoffers() async {
    return await ApiService.get(EndPoints.apiGetfetchoffers);
  }

  /// The new-customer login popup offer (null in the payload when there is
  /// nothing to show).
  Future<Response> fetchPopupOffer() async {
    return await ApiService.get(
      EndPoints.apiOfferPopup,
      requireAuthToken: true,
    );
  }

  /// Tells the backend the popup was displayed, so it never pops again.
  Future<Response> markPopupSeen(String offerId) async {
    return await ApiService.post(EndPoints.apiOfferPopupSeen, {
      "offer_id": offerId,
    }, requireAuthToken: true);
  }

  Future<Response> getTermsAndConditions() async {
    return await ApiService.get(EndPoints.apiGetTermsAndConditions);
  }

  Future<Response> getPrivacyPolicy() async {
    return await ApiService.get(EndPoints.apiGetPrivacyPolicy);
  }
}
