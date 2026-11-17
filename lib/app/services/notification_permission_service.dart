import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custome_widgets/notification_permission_dialog.dart';

/// Owns the push-notification permission flow.
///
/// Product rules implemented here:
///  * never asked on the splash / language screen (the OS alert used to appear
///    there because `main.dart` requested it in `initState`),
///  * asked once the customer is signed in and looking at the dashboard,
///  * asked again whenever the customer lands back on the home page (e.g. after
///    finishing a booking) while the permission is still missing,
///  * asked again on **every app launch** until it is accepted,
///  * always asks from inside the app (`Allow notifications`), never by sending
///    the customer to the device Settings.
///
/// Nothing is persisted: [_promptedThisRun] lives in memory, so the next cold
/// start asks again and an accepted permission is simply never asked about
/// (the OS status is `authorized`).
class NotificationPermissionService {
  NotificationPermissionService._();

  static final NotificationPermissionService instance =
      NotificationPermissionService._();

  /// One prompt per app run — reopening the dashboard inside the same session
  /// must not nag the customer again.
  bool _promptedThisRun = false;

  /// Guards against the dashboard being rebuilt while the dialog is open.
  bool _dialogVisible = false;

  /// Set from `main.dart`: called right after the permission is granted so the
  /// FCM token (which on iOS only exists once APNs registered the device) is
  /// pushed to the backend immediately.
  Future<void> Function()? onPermissionGranted;

  /// Reads the current OS status **without** showing any alert.
  Future<AuthorizationStatus> currentStatus() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus;
    } catch (e) {
      debugPrint('[Notifications] could not read the permission status: $e');
      return AuthorizationStatus.notDetermined;
    }
  }

  bool isGranted(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;

  /// Lets the next home page visit ask again.
  ///
  /// Called when the dashboard controller is disposed, which is exactly what
  /// `Get.offAllNamed(Routes.dashboard)` does after a booking is paid for — so
  /// coming back home re-asks until the customer allows notifications.
  void resetPromptFlag() {
    if (_dialogVisible) return;
    _promptedThisRun = false;
  }

  /// Shows the system alert when the OS still allows it.
  /// On iOS this only prompts while the status is `notDetermined`.
  Future<AuthorizationStatus> requestFromSystem() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus;
    } catch (e) {
      debugPrint('[Notifications] permission request failed: $e');
      return AuthorizationStatus.denied;
    }
  }

  /// Entry point used by the dashboard. Safe to call on every build.
  Future<void> promptAfterLoginIfNeeded() async {
    if (_promptedThisRun || _dialogVisible) return;
    _promptedThisRun = true;

    final status = await currentStatus();
    if (isGranted(status)) return;

    // Let the home screen (and the new-customer offer popup) settle first.
    await Future.delayed(const Duration(milliseconds: 900));
    await _waitForFreeDialogSlot();

    if (_dialogVisible) return;
    if (Get.key.currentState == null) return;
    if (Get.currentRoute.isEmpty) return;

    _dialogVisible = true;
    try {
      final choice = await Get.dialog<bool>(
        const NotificationPermissionDialog(),
        barrierDismissible: true,
      );

      if (choice != true) return;

      // Always asked from inside the app: the OS alert is the only place the
      // customer can actually switch notifications on, so no Settings redirect.
      // NOTE: iOS shows its alert only while the status is `notDetermined`; once
      // it was declined `requestPermission()` returns `denied` without a UI.
      final result = await requestFromSystem();
      debugPrint('[Notifications] permission after prompt: $result');

      if (isGranted(result)) {
        await onPermissionGranted?.call();
      }
    } catch (e, stackTrace) {
      debugPrint('[Notifications] permission prompt failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _dialogVisible = false;
    }
  }

  /// Waits (max ~6 s) while another dialog — e.g. the offer popup — is open,
  /// so the two never fight over the overlay.
  Future<void> _waitForFreeDialogSlot() async {
    for (int i = 0; i < 8; i++) {
      if (Get.isDialogOpen != true) return;
      await Future.delayed(const Duration(milliseconds: 750));
    }
  }
}
