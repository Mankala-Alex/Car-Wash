import 'package:get/get_utils/get_utils.dart';

class ValidationUtils {
  static bool isValidEmail(String email) {
    const emailPattern = r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$';
    final regExp = RegExp(emailPattern);

    return regExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    const passwordPattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
    final regExp = RegExp(passwordPattern);

    return regExp.hasMatch(password);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    const phonePattern = r'^\+?1?\d{9,15}$';
    final regExp = RegExp(phonePattern);

    return regExp.hasMatch(phoneNumber);
  }

  static bool isValidName(String name) {
    const namePattern = r'^[a-zA-Z\s]+$';
    final regExp = RegExp(namePattern);

    return regExp.hasMatch(name);
  }

  static bool isValidURL(String url) {
    const urlPattern =
        r'^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([/\w .-]*)*\/?$';
    final regExp = RegExp(urlPattern);

    return regExp.hasMatch(url);
  }

  static bool isNotEmpty(String input) {
    return input.isNotEmpty;
  }

  static bool isNumeric(String input) {
    final regExp = RegExp(r'^\d+$');

    return regExp.hasMatch(input);
  }
}

isItNull(
  variable, [
  dynamic ifVal = true,
  dynamic elseVal = false,
  bool objKey = false,
]) {
  if (variable == null || variable == 'null' || variable == '') {
    return ifVal;
  } else {
    if (objKey) {
      if (variable[elseVal] == null ||
          variable[elseVal] == 'null' ||
          variable[elseVal] == '') {
        return ifVal;
      } else {
        return variable[elseVal];
      }
    } else {
      return elseVal;
    }
  }
}

String? validateEmail(String? value) {
  // Regular expression for email validation
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern);

  if (value == null || value.isEmpty) {
    return null;
  } else if (!regex.hasMatch(value)) {
    return 'cons_enter_crt_emial'.tr;
  } else {
    return null;
  }
}

String? validateMobileNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'cons_enter_mobile_no'.tr;
  } else if (value.length < 10) {
    return 'cons_enter_mobile_no_digits'.tr;
  } else if (value.length > 10) {
    return 'cons_enter_mobile_no_exceed_digits'.tr;
  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return 'cons_enter_mobile_no_valid'.tr;
  }
  return null;
}
