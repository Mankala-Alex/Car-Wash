import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ServerException implements Exception {
  final ErrorModel errModel;

  ServerException({required this.errModel});
}

class ErrorModel {
  final int status;
  final String errorMessage;

  ErrorModel({required this.status, required this.errorMessage});
  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    return ErrorModel(
      status: jsonData[ExceptionMessages.status],
      errorMessage: jsonData[ExceptionMessages.errorMessage],
    );
  }
}

class ExceptionMessages {
  static const connectionTimeout = "Connection timeout";
  static const sendTimeout = "Send timeout";
  static const receiveTimeout = "Receive timeout";
  static const badCertificate = "Bad Certificate";
  static const requestCanceled = "Request Canceled";
  static const connectionError = "Connection Error";
  static const responseUnKnow = "Response UnKnow";
  static const statusCode400 = "Bad Response : StatusCode 400";
  static const statusCode401 = "Bad Response : StatusCode 401";
  static const statusCode403 = "Bad Response : StatusCode 403";
  static const statusCode404 = "Bad Response : StatusCode 404";
  static const statusCode409 = "Bad Response : StatusCode 409";
  static const statusCode422 = "Bad Response : StatusCode 422";
  static const statusCode504 = "Bad Response : StatusCode 504";

  static String status = "status";
  static String errorMessage = "ErrorMessage";
}

String handleDioExceptions(DioException e) {
  // String errorMessage = 'An error occurred';
  String errorMessage = e.message.toString();

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      errorMessage = ExceptionMessages.connectionTimeout;
    case DioExceptionType.sendTimeout:
      errorMessage = ExceptionMessages.sendTimeout;
    case DioExceptionType.receiveTimeout:
      errorMessage = ExceptionMessages.receiveTimeout;
    case DioExceptionType.badCertificate:
      errorMessage = ExceptionMessages.badCertificate;
    case DioExceptionType.cancel:
      errorMessage = ExceptionMessages.requestCanceled;
    case DioExceptionType.connectionError:
      errorMessage = ExceptionMessages.connectionError;
    case DioExceptionType.unknown:
      errorMessage = ExceptionMessages.responseUnKnow;
    case DioExceptionType.badResponse:
      switch (e.response?.statusCode) {
        case 400: // Bad request
          errorMessage = ExceptionMessages.statusCode400;
        case 401: //unauthorized
          errorMessage = ExceptionMessages.statusCode401;
        case 403: //forbidden
          errorMessage = ExceptionMessages.statusCode403;
        case 404: //not found
          errorMessage = ExceptionMessages.statusCode404;
        case 409: //cofficient
          errorMessage = ExceptionMessages.statusCode409;
        case 422: //  Unprocessable Entity
          errorMessage = ExceptionMessages.statusCode422;
        case 504: // Server exception
          errorMessage = ExceptionMessages.statusCode504;
      }
  }
  debugPrint(errorMessage);
  return errorMessage;
}

// String errorMessage = "";
// bool isFromAPI = false;

// void fnHandleControllerException(error, stackTrace, module, methodName) async {
//   if (error is DioException) {
//     isFromAPI = true;
//     errorMessage = handleDioExceptions(error).toString();
//     debugPrint(errorMessage);
//     debugPrint(stackTrace.toString());
//   } else {
//     isFromAPI = false;
//     errorMessage = error;
//     print("Other Errors: ${error.toString()}");
//     // const errorMessage = "Some error has occurred";
//     // errorToast(errorMessage);
//   }
//   Map<String, dynamic> requestBody = {
//     'AppName': "CRM flutter app",
//     'ModuleName': module,
//     'MethodName': methodName,
//     'Message': errorMessage,
//     "StackTrace": stackTrace.toString(),
//     "IsFromAPI": isFromAPI,
//   };

//   debugPrint(requestBody.toString());

//   var response = await AuthRepository.postLogException(requestBody);
//   debugPrint(response.data.toString());
// }
