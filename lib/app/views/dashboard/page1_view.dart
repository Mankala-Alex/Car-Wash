import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart'; // Ensure this import is correct
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/offers_controller.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

import '../../controllers/dashboard/dashboard_controller.dart';
import '../../routes/app_routes.dart'; // To navigate to Routes.BOOK_SLOT

class Page1View extends GetView<DashboardController> {
  Page1View({super.key});

  final offersController = Get.find<OffersController>();

  final List<String> bannerImages = const [
    'assets/carwash/carwheel.png',
    'assets/carwash/splash_image.jpg',
    'assets/carwash/yellowcar.png', // Add more if you have them
  ];
  final List<String> bannerTitles = const [
    "Exterior Polish",
    "Interior Deep Clean",
    "Full Service",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      backgroundColor: AppColors.bgLight, // Light grey background
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
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
                  Icons.notifications,
                  color: AppColors.warningLight,
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
            FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 180,
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

              // ----- FIXED ITEMS LIST -----
              items: List.generate(bannerImages.length, (index) {
                final imagePath = bannerImages[index];
                final title = bannerTitles[index];
                return Builder(
                  builder: (context) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Gradient overlay
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

                          // Bottom-left heading
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

                          // Bottom-right button
                          // Positioned(
                          //   right: 16,
                          //   bottom: 12,
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       Get.toNamed(Routes.bookslot);
                          //     },
                          //     child: Container(
                          //       padding: const EdgeInsets.symmetric(
                          //           horizontal: 18, vertical: 10),
                          //       decoration: BoxDecoration(
                          //         color: Colors.white.withOpacity(
                          //             0.18), // transparent glass effect
                          //         borderRadius: BorderRadius.circular(14),
                          //         border: Border.all(
                          //           color: Colors.white
                          //               .withOpacity(0.35), // frosty border
                          //           width: 1.2,
                          //         ),
                          //         boxShadow: [
                          //           BoxShadow(
                          //             color: Colors.white.withOpacity(0.25),
                          //             blurRadius: 6,
                          //             offset: const Offset(0, 2),
                          //           ),
                          //         ],
                          //       ),
                          //       child: const Text(
                          //         "Book Now",
                          //         style: TextStyle(
                          //           color: Colors.white,
                          //           fontSize: 14,
                          //           fontWeight: FontWeight.w600,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),

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

// ---------------- WALLET CARD (BELOW SERVICE CARDS) ----------------
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.05),
                  //         blurRadius: 8,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       // Left Side - Title + Button
                  //       Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             const Text(
                  //               "My Wallet",
                  //               style: TextStyle(
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.w700,
                  //               ),
                  //             ),
                  //             const SizedBox(height: 10),

                  //             // Manage Button
                  //             Container(
                  //               padding: const EdgeInsets.symmetric(
                  //                 horizontal: 14,
                  //                 vertical: 8,
                  //               ),
                  //               decoration: BoxDecoration(
                  //                 color: const Color(0xffEAF2FF),
                  //                 borderRadius: BorderRadius.circular(10),
                  //               ),
                  //               child: const Text(
                  //                 "Manage Payment & Coupons",
                  //                 style: TextStyle(
                  //                   fontSize: 12,
                  //                   color: Colors.blue,
                  //                   fontWeight: FontWeight.w600,
                  //                 ),
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),

                  //       // Right Side - Wallet Icon
                  //       Container(
                  //         //padding: const EdgeInsets.all(30),
                  //         // decoration: BoxDecoration(
                  //         //   color: const Color(0xffF5F7FA),
                  //         //   borderRadius: BorderRadius.circular(12),
                  //         // ),
                  //         child: Image.asset(
                  //           "assets/carwash/wallet.png",
                  //           height: 60,
                  //           width: 60, // <-- your wallet icon
                  //           fit: BoxFit.contain,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  //const SizedBox(height: 20),

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
                    const HOME_OFFER_CODE = "aa";
                    final offer = list.firstWhere(
                      (o) => o.offerCode == HOME_OFFER_CODE,
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
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE7C5),
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
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE7C5),
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

  // Helper widget for Carousel items
  Widget _buildCarouselItem(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3), // Darken image for text readability
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end, // Align text to bottom
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for Doorstep/In-Store buttons
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80, // Fixed height for the buttons
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center icon and text
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Flexible(
                // Allows text to wrap or shrink if needed
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.2, // Adjust line height for multiline text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for Featured Service cards
  Widget _buildFeaturedServiceCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white, // Default background
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35), // Darken image slightly
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
                        color: AppColors.secondaryLight,
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
