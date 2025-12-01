import 'package:dio/dio.dart';
import 'package:my_new_app/app/services/api_service.dart';
import 'package:my_new_app/app/services/endpoints.dart';

class ProfileRepository {
  Future<Response> fetchoffers() async {
    return await ApiService.get(EndPoints.apiGetfetchoffers);
  }
}
