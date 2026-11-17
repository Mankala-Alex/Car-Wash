import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows the outcome of a payment in a dialog.
///
/// A toast disappears in about two seconds, which is not enough to read *why* a
/// payment failed — the customer is left thinking the app is broken. This shows
/// the reason the backend/Paymob gave (e.g. "Your card has expired", "Your bank
/// declined the payment") and only then returns to the previous screen.
///
/// Awaiting the returned future gives the caller a point where the dialog has
/// been dismissed and navigation can safely continue.
Future<void> showPaymentResultDialog({
  required String title,
  required String message,
  String? buttonLabel,
  bool success = false,
}) {
  return Get.dialog<void>(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              size: 46,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (Get.isDialogOpen == true) Get.back();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(buttonLabel ?? "close".tr),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
