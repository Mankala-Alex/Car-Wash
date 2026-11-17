import 'package:car_wash_customer_app/app/models/booking%20slot/saved_location_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/location_list_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/saved_location_options_sheet.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class LocationsListView extends GetView<LocationListController> {
  const LocationsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F8),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            "addresses".tr,
            style: const TextStyle(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "saved_addresses".tr,
                style: const TextStyle(
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: AppColors.bgLight, size: 26),
                      const SizedBox(width: 12),
                      Text(
                        "add_new_address".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.bgLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: AppColors.bgLight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
              const Icon(
                Icons.location_on_outlined,
                size: 26,
                color: Colors.black87,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  location.label, // house number of the saved address
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showSavedLocationOptionsSheet(
                    controller.bookSlotController,
                    location,
                  );
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
}

// The 3-dot Edit / Delete bottom sheet lives in
// `custom_widgets/saved_location_options_sheet.dart` so the "Confirm Car Wash"
// screen can use exactly the same UI and behaviour.
