import 'package:car_wash_customer_app/app/custome_widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/config/constants.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/instore_wash_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class InstoreWashListView extends GetView<InstoreWashController> {
  const InstoreWashListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          "in_store_locations".tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ---------------- SEARCH BAR ----------------
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          controller.searchStores(value);
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "search_by_name_or_area".tr,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- DYNAMIC LOCATIONS LIST ----------------
              Obx(() {
                if (controller.isLoading.value) {
                  return Column(
                    children: List.generate(
                      5, // Number of skeleton boxes to show
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 22),
                        child: SkeletonBox(
                          width: double.infinity,
                          height: 280,
                          radius: 16,
                        ),
                      ),
                    ),
                  );
                }

                if (controller.filteredStores.isEmpty) {
                  return noLocationFoundCard();
                }

                return Column(
                  children: controller.filteredStores.map((store) {
                    return locationCard(
                      image: store.imageUrl, // static placeholder
                      title: store.companyName,
                      rating: "0.0",
                      reviews: "no_reviews_yet".tr,
                      address: "${store.streetName}, ${store.city}",
                      statusText: store.status == "Active" ? "Closed" : "Open",
                      statusColor:
                          store.status == "Active" ? Colors.red : Colors.green,
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION CARD WIDGET
  // ============================================================

  Widget locationCard({
    required String image,
    required String title,
    required String rating,
    required String reviews,
    required String address,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: image.isEmpty
                ? Image.asset(
                    "assets/carwash/car1.png",
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    Constants.imageBaseUrl + image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/carwash/car1.png",
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),

                // Rating Row
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "($reviews)",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Address
                Text(
                  address,
                  style: const TextStyle(color: Colors.black87),
                ),

                const SizedBox(height: 8),

                // Status
                Row(
                  children: [
                    Icon(
                      statusColor == Colors.red
                          ? Icons.cancel
                          : Icons.circle_rounded,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ---- View Reviews ----
                Row(
                  children: [
                    Text(
                      "view_reviews".tr,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward,
                        size: 14, color: Colors.blue),
                  ],
                ),

                const SizedBox(height: 12),

                // ------------ LOCATION + CALL BUTTONS ------------
                Row(
                  children: [
                    // Location Button
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.textDefaultLight,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Location",
                              style: TextStyle(
                                color: AppColors.textDefaultLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Call Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.makePhoneCall("9999999999"),
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.secondaryLight),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.phone,
                                color: AppColors.textDefaultLight,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "call".tr,
                                style: const TextStyle(
                                  color: AppColors.textDefaultLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO LOCATION FOUND CARD
  // ============================================================

  Widget noLocationFoundCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.visibility_off_outlined, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Locations Found",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "We couldn't find any partner locations.\nTry again later.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
