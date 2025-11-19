import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/location_list_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // -------- Add New Address Button --------
            InkWell(
              onTap: () {
                Get.toNamed(Routes.addlocation);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.pink, size: 26),
                    SizedBox(width: 12),
                    Text(
                      "Add New Address",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.pink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 18, color: Colors.black54),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Saved Addresses",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 18),

            // -------- Address List --------
            Expanded(
              child: Obx(() {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.separated(
                    itemCount: controller.addresses.length,
                    separatorBuilder: (_, __) => const Divider(height: 30),
                    itemBuilder: (context, index) {
                      final item = controller.addresses[index];
                      return _addressTile(item, index);
                    },
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // Address Tile UI (MATCHES SCREENSHOT)
  // -------------------------------------------------------------------
  Widget _addressTile(AddressModel address, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              address.icon,
              size: 26,
              color: Colors.black87,
            ),
            const SizedBox(width: 12),

            // Title + Distance + Selected badge
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
                  const SizedBox(width: 6),
                  Text(
                    "• ${address.distance}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
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

            // 3 dots menu
            InkWell(
              onTap: () {
                controller.showBottomSheet(address);
              },
              child: const Icon(Icons.more_vert, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          address.fullAddress,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
