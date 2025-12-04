import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';

class AuthRepository {
  //sign up
  Future<Response> postVerifyOtp(requestBody) async {
    return await ApiService.post(EndPoints.apiPostverifyotp, requestBody,
        requireAuthToken: false);
  }

  //login
  Future<Response> postRequestOtp(requestBody) async {
    return await ApiService.post(EndPoints.apiPostrequstotp, requestBody,
        requireAuthToken: false);
  }
}
