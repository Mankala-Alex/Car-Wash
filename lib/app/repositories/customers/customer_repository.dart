import 'package:dio/dio.dart';
import 'package:car_wash_customer_app/app/services/api_service.dart';
import 'package:car_wash_customer_app/app/services/endpoints.dart';

class CustomerRepository {
  Future<Response> getCustomer(String id) async {
    // Uses absolute path under the API base or full URL if needed
    return await ApiService.get("customers/$id", requireAuthToken: true);
  }

  /// Saves the customer's display name.
  ///
  /// The customer app registers with the mobile number only, so the name is
  /// captured later (address screen / profile) and stored as ONE value in
  /// `customers.first_name` by the backend.
  Future<Response> updateMyName(String name) async {
    return await ApiService.put(EndPoints.apiUpdateMyName, {
      "name": name,
    }, requireAuthToken: true);
  }
}
