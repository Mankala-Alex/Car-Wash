import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../services/endpoints.dart';

class AuthRepository {
  //otp up
  Future<Response> postVerifyOtp(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostverifyotp,
      requestBody,
      requireAuthToken: false,
    );
  }

  //login
  Future<Response> postRequestOtp(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostrequstotp,
      requestBody,
      requireAuthToken: false,
    );
  }

  //signup
  Future<Response> postSignup(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostsignup,
      requestBody,
      requireAuthToken: false,
    );
  }

  // PHONE OTP SEND
  Future<Response> postRequestOtpPhone(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostRequestOtpPhone,
      requestBody,
      requireAuthToken: false,
    );
  }

  // PHONE VERIFY
  Future<Response> postVerifyOtpPhone(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostVerifyOtpPhone,
      requestBody,
      requireAuthToken: false,
    );
  }

  // PHONE SIGNUP
  Future<Response> postSignupPhone(requestBody) async {
    return await ApiService.post(
      EndPoints.apiPostSignupPhone,
      requestBody,
      requireAuthToken: false,
    );
  }

  Future<void> postLogout() async {
    await ApiService.post(
      EndPoints.apiPostLogOut, // ex: partners/logout
      {},
      requireAuthToken: true,
    );
  }

  /// Permanently deletes the signed-in customer's account.
  ///
  /// The backend identifies the customer from the JWT and requires the
  /// confirmation word, so only that word is sent.
  Future<Response> deleteAccount({
    String confirmation = 'DELETE',
    String? reason,
  }) async {
    return await ApiService.delete(
      EndPoints.apiDeleteMyAccount,
      requireAuthToken: true,
      data: {
        'confirmation': confirmation,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }
}
