import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/booking_flow/book_slot_controller.dart';
import '../custome_widgets/custome_confirmation_dialog.dart';
import '../models/booking%20slot/saved_location_model.dart';
import '../routes/app_routes.dart';

/// Bottom sheet with Edit / Delete for a saved address.
///
/// Shared by the Addresses screen (My Profile -> Addresses) and by the
/// "Confirm Car Wash" booking screen, so the 3-dot menu behaves identically
/// in both places.
void showSavedLocationOptionsSheet(
  BookSlotController bookings,
  SavedLocation location,
) {
  Get.bottomSheet(
    SafeArea(
      top: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              location.address,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // ---- Edit Button ----
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black87),
              title: Text(
                "edit".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Get.back(); // Close bottom sheet
                // Open the picker pre-filled with this address.
                Get.toNamed(
                  Routes.locationPicker,
                  arguments: {'isEditing': true, 'editingLocation': location},
                );
              },
            ),

            const Divider(),

            // ---- Delete Button ----
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                "delete".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Get.back(); // Close bottom sheet
                Get.dialog(
                  CustomConfirmationDialog(
                    header: "delete_address".tr,
                    body:
                        "${"are_you_sure_you_want_to_delete".tr} ${location.label}?",
                    yesText: "delete".tr,
                    noText: "cancel".tr,
                    onYes: () {
                      // Removes it from the shared list, persists the change and
                      // re-selects another address (or clears the selection).
                      bookings.removeSavedLocation(location);
                      Get.back();
                    },
                    onNo: () => Get.back(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
