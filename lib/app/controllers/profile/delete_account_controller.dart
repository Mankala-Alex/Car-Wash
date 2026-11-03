import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/helpers/api_error_helper.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/helpers/secure_store.dart';
import 'package:car_wash_customer_app/app/helpers/shared_preferences.dart';
import 'package:car_wash_customer_app/app/repositories/auth/auth_repository.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/services/socket_service.dart';

/// Controller for the "Delete Account" screen.
///
/// The backend (`DELETE /api/customers/me`) takes the customer from the JWT, so
/// nothing but the typed confirmation is sent from the app.
class DeleteAccountController extends GetxController {
  final AuthRepository repository = AuthRepository();

  /// The user has to type this exact word before the button unlocks.
  static const String confirmationWord = 'DELETE';

  final TextEditingController confirmController = TextEditingController();

  final isLoading = false.obs;

  /// True only when the typed text matches [confirmationWord].
  final canDelete = false.obs;

  @override
  void onInit() {
    super.onInit();
    confirmController.addListener(_syncCanDelete);
  }

  @override
  void onClose() {
    confirmController.removeListener(_syncCanDelete);
    confirmController.dispose();
    super.onClose();
  }

  void _syncCanDelete() {
    canDelete.value =
        !isLoading.value && confirmController.text.trim() == confirmationWord;
  }

  /// Calls the backend and, on success, clears every trace of the session.
  Future<void> deleteAccount() async {
    if (isLoading.value) return;

    final typed = confirmController.text.trim();

    if (typed != confirmationWord) {
      errorToast('delete_account_confirm_mismatch'.tr);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;
    _syncCanDelete();

    try {
      await repository.deleteAccount(confirmation: typed);

      await _clearLocalData();

      successToast('account_deleted_successfully'.tr);

      Get.deleteAll(force: true);
      Get.offAllNamed(Routes.login);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final code = data is Map ? data['code'] : null;

      if (status == 409 || code == 'ACTIVE_BOOKINGS') {
        // Requirement: show the message the backend returned.
        _showBlockedDialog(apiErrorMessage(e, 'active_booking_exists'.tr));
      } else {
        errorToast(apiErrorMessage(e, 'unable_to_delete_account'.tr));
      }
    } catch (e) {
      errorToast(apiErrorMessage(e, 'unable_to_delete_account'.tr));
    } finally {
      isLoading.value = false;
      _syncCanDelete();
    }
  }

  /// Show the "you still have an active booking" explanation coming from the API.
  void _showBlockedDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: Text('active_booking_exists'.tr),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Clear the token, the cached profile and any in-memory account state.
  Future<void> _clearLocalData() async {
    try {
      await Get.find<SocketService>().disconnect();
    } catch (e) {
      print('⚠️ Socket disconnect error during account deletion: $e');
    }

    try {
      await SharedPrefsHelper.clearAll();
    } catch (e) {
      print('⚠️ SharedPreferences clear error during account deletion: $e');
    }

    try {
      await FlutterSecureStore().deleteAllData();
    } catch (e) {
      print('⚠️ Secure storage clear error during account deletion: $e');
    }
  }
}
