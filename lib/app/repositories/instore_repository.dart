import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

class InstoreRepository {
  Future<Response> getInStoreWashStores() async {
    return await ApiService.get(EndPoints.apiGetinstoreservices);
  }
}
