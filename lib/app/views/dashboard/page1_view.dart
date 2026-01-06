import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart'; // Ensure this import is correct
import 'package:get/get.dart';
import 'package:my_new_app/app/config/constants.dart';
import 'package:my_new_app/app/controllers/booking_flow/features_list_controller.dart';
import 'package:my_new_app/app/controllers/profile/offers_controller.dart';
import 'package:my_new_app/app/models/booking%20slot/booking_history_model.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

import '../../controllers/dashboard/dashboard_controller.dart';
import '../../routes/app_routes.dart'; // To navigate to Routes.BOOK_SLOT

class Page1View extends GetView<DashboardController> {
  Page1View({super.key});

  final offersController = Get.find<OffersController>();
  final featuresController = Get.find<FeaturesListController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      backgroundColor: AppColors.bgLight, // Light grey background
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false, // Make app bar transparent
        title: Row(
          children: [
            // IconButton(
            //     onPressed: () {
            //       Get.toNamed("page4");
            //     },
            //     icon: Icon(
            //       Icons.notifications,
            //       color: AppColors.warningLight,
            //       size: 30,
            //     )),
            const SizedBox(width: 10),
            const Text(
              "CAR WASH",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B), // Dark text color
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Get.toNamed(Routes.notification);
                },
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.bgBlackLight,
                  size: 30,
                ))
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Carousel Section ---
            Obx(() {
              if (featuresController.isLoading.value) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (featuresController.services.isEmpty) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: Text("No services available")),
                );
              }

              return FlutterCarousel(
                options: FlutterCarouselOptions(
                  height: 150,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  enableInfiniteScroll: true,
                  showIndicator: true,
                  slideIndicator: CircularSlideIndicator(
                    slideIndicatorOptions: const SlideIndicatorOptions(
                      currentIndicatorColor: Colors.black,
                      indicatorBackgroundColor: Colors.white,
                      indicatorRadius: 3,
                      itemSpacing: 15,
                    ),
                  ),
                ),

                // 🔥 LIST FROM API
                items:
                    List.generate(featuresController.services.length, (index) {
                  final service = featuresController.services[index];
                  final imageUrl = Constants.imageBaseUrl + service.imageUrl;
                  final title = service.name;

                  return Builder(
                    builder: (context) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // 🔥 Gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.6),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ),

                            // 🔥 Bottom-left service title
                            Positioned(
                              left: 16,
                              bottom: 16,
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // 🔥 Bottom-right Book Now button
                            Positioned(
                              right: 16,
                              bottom: 12,
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    Routes.bookslot,
                                    arguments: {
                                      "image": imageUrl,
                                      "name": service.name,
                                      "description": service.description,
                                      "price": service.price.toString(),
                                      "features": service.features,
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.35),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "Book Now",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              );
            }),

            const SizedBox(height: 25),

            // --- Doorstep & In-Store Wash Buttons ---
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SERVICE CARDS USING THE SAME WIDGET ---
                  ServiceCard(
                    title: "Doorstep Car Wash",
                    subtitle: "Convenience at your home",
                    buttonText: "Book Now",
                    imagePath: "assets/carwash/door_step.png",
                    onTap: () {
                      Get.toNamed(Routes.featureslist);
                    },
                  ),

                  ServiceCard(
                    title: "In-Store Car Wash",
                    subtitle: "Visit us for a premium clean",
                    buttonText: "Book Now",
                    imagePath: "assets/carwash/in_store.png",
                    discountText: "50% OFF",
                    onTap: () {
                      Get.toNamed(Routes.instorewash);
                    },
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (controller.trackingBooking.value == null) {
                      return const SizedBox.shrink();
                    }

                    final b = controller.trackingBooking.value!;

                    return _trackingCard(b);
                  }),
                  const SizedBox(height: 20),
// ---------------- PROMO BANNER AFTER WALLET ----------------
                  Obx(() {
                    final list = offersController.offers;

                    if (list.isEmpty) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryLight,
                              AppColors.primaryLight
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Loading offer...",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                      );
                    }

                    // Pick a specific offer (by code OR first item)
                    const homeOfferCode = "aa";
                    final offer = list.firstWhere(
                      (o) => o.offerCode == homeOfferCode,
                      orElse: () => list.first,
                    );

                    // Discount title
                    final discountTitle = offer.discountType == "percentage"
                        ? "${offer.discountValue}% OFF"
                        : "SAR ${offer.discountValue} OFF";

                    return Container(
                      height: 180,
                      width: double.infinity,
                      //     padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xFFFFF4E5), // soft beige background
                      ),
                      child: Stack(
                        children: [
                          // --- Soft Circles Background ---
                          Positioned(
                            top: -20,
                            right: -20,
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFE7C5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -30,
                            left: -30,
                            child: Container(
                              height: 140,
                              width: 140,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFE7C5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // ---- OFFER TEXT CONTENT ----
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Discount
                                Text(
                                  discountTitle,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Title
                                Text(
                                  offer.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const Spacer(),

                                // Expiry
                                Text(
                                  "Expires in ${offer.expiryDays} days",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            //const SizedBox(height: 30), // Padding at the bottom
          ],
        ),
      ),
    );
  }
}

Widget _trackingCard(Datum b) {
  return Container(
    //margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 3),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Technician + Service ---
        Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage("assets/carwash/avatar.png"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.washerName.isEmpty ? "Technician Assigned" : b.washerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    b.serviceName,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // open full tracking UI
              },
              child: const Text("Track"),
            )
          ],
        ),

        const SizedBox(height: 20),

        // --- TIMELINE (YOUR IMAGE STYLE) ---
        _trackingTimeline(b.status),
      ],
    ),
  );
}

Widget _trackingTimeline(String status) {
  bool assigned =
      status == "ASSIGNED" || status == "ARRIVED" || status == "IN_PROGRESS";
  bool arrived = status == "ARRIVED" || status == "IN_PROGRESS";
  bool inProgress = status == "IN_PROGRESS";

  Color active = Colors.orange;
  Color inactive = Colors.grey.shade400;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // ASSIGNED
      _timelineStep(
        active: assigned,
        label: "ASSIGNED",
        icon: Icons.check_circle,
      ),

      // ARRIVED
      _timelineStep(
        active: arrived,
        label: "ARRIVED",
        icon: Icons.radio_button_checked,
      ),

      // IN_PROGRESS
      _timelineStep(
        active: inProgress,
        label: "IN PROGRESS",
        icon: Icons.local_car_wash,
      ),

      // COMPLETED (always inactive here)
      _timelineStep(
        active: false,
        label: "COMPLETED",
        icon: Icons.flag,
      ),
    ],
  );
}

Widget _timelineStep(
    {required bool active, required String label, required IconData icon}) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Colors.orange : Colors.grey.shade200,
          border: Border.all(
            color: active ? Colors.orange : Colors.grey.shade400,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? Colors.white : Colors.grey,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? Colors.orange : Colors.grey,
        ),
      ),
    ],
  );
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final String imagePath;
  final String? discountText;
  final VoidCallback? onTap;

  const ServiceCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.buttonText,
      required this.imagePath,
      this.discountText,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 15,
              offset: Offset(5, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // If discount available → show badge
                  if (discountText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        discountText!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  if (discountText != null) const SizedBox(height: 8),

                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Button
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        // color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.secondaryLight
                        //   colors: [
                        //     Color(0xFF6B42F2),
                        //     Color(0xFF825AD9),
                        //   ],
                        //   begin: Alignment.centerLeft,
                        //   end: Alignment.centerRight,
                        // ),
                        ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: AppColors.textWhiteLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 5),
                        // const Icon(Icons.arrow_forward,
                        //     color: Colors.black, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right Image Section
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 150,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
