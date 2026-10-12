import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';

class CustomerRepository {
  Future<Response> getCustomer(String id) async {
    // Uses absolute path under the API base or full URL if needed
    return await ApiService.get("customers/$id", requireAuthToken: true);
  }
}
