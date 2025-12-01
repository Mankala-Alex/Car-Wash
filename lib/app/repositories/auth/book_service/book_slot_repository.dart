import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

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
}
