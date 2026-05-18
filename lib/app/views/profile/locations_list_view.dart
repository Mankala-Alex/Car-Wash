import 'package:car_wash_customer_app/app/models/booking%20slot/saved_location_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/location_list_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/custome_confirmation_dialog.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class LocationsListView extends GetView<LocationListController> {
  const LocationsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "addresses".tr,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      // ------------------ BODY ------------------
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Saved Addresses Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "saved_addresses".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ------------ LIST ------------
          Expanded(
            child: Obx(() {
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.locations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _addressContainer(controller.locations[index]);
                },
              );
            }),
          ),

          const SizedBox(height: 10),

          // ------------ ADD NEW ADDRESS (BOTTOM BUTTON) ------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: InkWell(
              onTap: () {
                Get.toNamed(Routes.locationPicker);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.bgLight, size: 26),
                    SizedBox(width: 12),
                    Text(
                      "add_new_address".tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.bgLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 18, color: AppColors.bgLight),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ---------------------------- ADDRESS TILE ----------------------------
  Widget _addressContainer(SavedLocation location) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 26, color: Colors.black87),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  location.label, // Home / Work / Other
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _showLocationOptionsSheet(location);
                },
                child: const Icon(Icons.more_vert, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            location.address,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom sheet with Edit and Delete options
  void _showLocationOptionsSheet(SavedLocation location) {
    Get.bottomSheet(
      Container(
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              location.address,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // ---- Edit Button ----
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.black87),
              title: const Text(
                "Edit",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Get.back(); // Close bottom sheet
                // Navigate to location picker with location data for editing
                Get.toNamed(
                  Routes.locationPicker,
                  arguments: {
                    'isEditing': true,
                    'editingLocation': location,
                  },
                );
              },
            ),

            const Divider(),

            // ---- Delete Button ----
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                "delete".tr,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
              onTap: () {
                Get.back(); // Close bottom sheet
                // Show confirmation dialog
                Get.dialog(
                  CustomConfirmationDialog(
                    header: "delete_address".tr,
                    body: "are_you_sure_you_want_to_delete".tr +
                        " ${location.label}?",
                    yesText: "delete".tr,
                    noText: "Cancel".tr,
                    onYes: () {
                      controller.deleteLocation(location);
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
      isScrollControlled: true,
    );
  }
}
