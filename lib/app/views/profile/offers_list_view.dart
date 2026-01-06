import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/offers_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';

class OffersListView extends GetView<OffersController> {
  const OffersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Offers",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.offers.isEmpty) {
          return const Center(child: Text("No offers available"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.offers.length,
          itemBuilder: (context, index) {
            final offer = controller.offers[index];

            /// Discount title logic
            String discountTitle = offer.discountType == "percentage"
                ? "${offer.discountValue}% OFF"
                : "SAR ${offer.discountValue}";

            /// Expiry date logic
            String expiryDate =
                controller.calculateExpiryDate(offer.expiryDays);

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE (STATIC)
                  // ClipRRect(
                  //   borderRadius:
                  //       const BorderRadius.vertical(top: Radius.circular(18)),
                  //   child: Image.asset(
                  //     "assets/carwash/toyota_camry.png",
                  //     width: double.infinity,
                  //     height: 180,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TITLE (discount)
                        Text(
                          discountTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),

                        /// DESCRIPTION (terms)
                        Text(
                          offer.terms.isNotEmpty
                              ? offer.title
                              : "No description available",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// EXPIRY
                            Text(
                              "Expires: $expiryDate",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),

                            /// BUTTON
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  Routes.offerscreen,
                                  arguments: offer,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
