import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

class GooglePlacesRepository {
  Future<Response> autocomplete(String query) async {
    return await ApiService.get(
      "${EndPoints.apiPlaceAutocomplete}?query=$query",
    );
  }

  Future<Response> getPlaceDetails(String placeId) async {
    return await ApiService.get(
      "${EndPoints.apiPlaceDetails}?placeId=$placeId",
    );
  }
}
