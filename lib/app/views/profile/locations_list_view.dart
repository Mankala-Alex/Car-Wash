import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/location_list_controller.dart';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Addresses",
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Saved Addresses",
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
                itemCount: controller.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _addressContainer(controller.addresses[index], index);
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
                child: const Row(
                  children: [
                    Icon(Icons.add, color: AppColors.bgLight, size: 26),
                    SizedBox(width: 12),
                    Text(
                      "Add New Address",
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
  Widget _addressContainer(AddressModel address, int index) {
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
              Icon(address.icon, size: 26, color: Colors.black87),
              const SizedBox(width: 12),

              // Title + distance
              Expanded(
                child: Row(
                  children: [
                    Text(
                      address.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "• ${address.distance}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),

                    // Selected Badge
                    if (address.isSelected)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9F9D8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Selected",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2B8A3E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              InkWell(
                onTap: () {
                  controller.showBottomSheet(address);
                },
                child: const Icon(Icons.more_vert, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.fullAddress,
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
