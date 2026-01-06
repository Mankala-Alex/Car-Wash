import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';

class AuthRepository {
  //otp up
  Future<Response> postVerifyOtp(requestBody) async {
    return await ApiService.post(EndPoints.apiPostverifyotp, requestBody,
        requireAuthToken: false);
  }

  //login
  Future<Response> postRequestOtp(requestBody) async {
    return await ApiService.post(EndPoints.apiPostrequstotp, requestBody,
        requireAuthToken: false);
  }

  //signup
  Future<Response> postSignup(requestBody) async {
    return await ApiService.post(EndPoints.apiPostsignup, requestBody,
        requireAuthToken: false);
  }

  Future<void> postLogout() async {
    await ApiService.post(
      EndPoints.apiPostLogOut, // ex: partners/logout
      {},
      requireAuthToken: true,
    );
  }
}
