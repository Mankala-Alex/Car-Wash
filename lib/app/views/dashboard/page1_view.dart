import 'package:car_wash_customer_app/app/models/advertisement/advertisement_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart'; // Ensure this import is correct
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/features_list_controller.dart';
import 'package:car_wash_customer_app/app/controllers/profile/offers_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:car_wash_customer_app/app/custome_widgets/new_user_offer_popup.dart';
import 'package:car_wash_customer_app/app/custome_widgets/skeleton_box.dart';
import 'package:car_wash_customer_app/app/models/booking%20slot/booking_history_model.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import 'package:car_wash_customer_app/app/helpers/amount_formatter.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';
import 'package:car_wash_customer_app/app/helpers/media_url.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/dashboard/dashboard_controller.dart';
import '../../routes/app_routes.dart'; // To navigate to Routes.BOOK_SLOT

class Page1View extends GetView<DashboardController> {
  Page1View({super.key});

  final offersController = Get.find<OffersController>();
  final featuresController = Get.find<FeaturesListController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //extendBodyBehindAppBar: true,
        backgroundColor: AppColors.bgLight, // Light grey background
        // appBar: AppBar(
        //   backgroundColor: AppColors.bgLight,
        //   elevation: 0,
        //   scrolledUnderElevation: 0,
        //   surfaceTintColor: Colors.white,
        //   automaticallyImplyLeading: false, // Make app bar transparent
        //   title: Row(
        //     children: [
        //       // IconButton(
        //       //     onPressed: () {
        //       //       Get.toNamed("page4");
        //       //     },
        //       //     icon: Icon(
        //       //       Icons.notifications,
        //       //       color: AppColors.warningLight,
        //       //       size: 30,
        //       //     )),
        //       //const SizedBox(width: 10),
        //       // Text(
        //       //   "aguawash".tr,
        //       //   style: const TextStyle(
        //       //     fontSize: 20,
        //       //     fontWeight: FontWeight.bold,
        //       //     color: Color(0xFF1E293B), // Dark text color
        //       //   ),
        //       // ),
        //       //const Spacer(),
        //       // IconButton(
        //       //     onPressed: () {
        //       //       Get.toNamed(Routes.notification);
        //       //     },
        //       //     icon: const Icon(
        //       //       Icons.notifications_outlined,
        //       //       color: AppColors.bgBlackLight,
        //       //       size: 30,
        //       //     ))
        //     ],
        //   ),
        // ),
        body: RefreshIndicator(
          onRefresh: controller.refreshHomeData,
          color: AppColors.primaryLight,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Advertisement Carousel ---
                // --- Advertisement Carousel ---
                Obx(() {
                  if (controller.isAdvertisementsLoading.value) {
                    return SizedBox(
                      height: 150,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    );
                  }

                  if (controller.advertisements.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return FlutterCarousel(
                    options: FlutterCarouselOptions(
                      height: 150,
                      autoPlay: controller.advertisements.length > 1,
                      enlargeCenterPage: true,
                      viewportFraction: 0.95,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      enableInfiniteScroll:
                          controller.advertisements.length > 1,
                    ),
                    items: controller.advertisements.map((advertisement) {
                      return _advertisementCard(advertisement);
                    }).toList(),
                  );
                }),

                // --- Top Carousel Section ---
                // Obx(() {
                //   if (featuresController.isLoading.value) {
                //     return const SkeletonCarousel(
                //       height: 180,
                //       itemCount: 3,
                //     );
                //   }

                //   if (featuresController.services.isEmpty) {
                //     return SizedBox(
                //       height: 180,
                //       child: Center(child: Text("no_services_available".tr)),
                //     );
                //   }

                //   return FlutterCarousel(
                //     options: FlutterCarouselOptions(
                //       height: 180,
                //       autoPlay: true,
                //       enlargeCenterPage: true,
                //       viewportFraction: 1.0,
                //       autoPlayInterval: const Duration(seconds: 3),
                //       autoPlayAnimationDuration:
                //           const Duration(milliseconds: 800),
                //       enableInfiniteScroll: true,
                //       showIndicator: true,
                //       slideIndicator: CircularSlideIndicator(
                //         slideIndicatorOptions: const SlideIndicatorOptions(
                //           currentIndicatorColor: Colors.black,
                //           indicatorBackgroundColor: Colors.white,
                //           indicatorRadius: 3,
                //           itemSpacing: 15,
                //         ),
                //       ),
                //     ),

                //     // 🔥 LIST FROM API
                //     items: List.generate(featuresController.services.length,
                //         (index) {
                //       final service = featuresController.services[index];
                //       final imageUrl =
                //           Constants.imageBaseUrl + service.imageUrl;
                //       final title = service.name;

                //       return Builder(
                //         builder: (context) {
                //           return Container(
                //             margin: const EdgeInsets.symmetric(horizontal: 6),
                //             decoration: BoxDecoration(
                //               borderRadius: const BorderRadius.only(
                //                 bottomLeft: Radius.circular(18),
                //                 bottomRight: Radius.circular(18),
                //               ),
                //               image: DecorationImage(
                //                 image: NetworkImage(imageUrl),
                //                 fit: BoxFit.cover,
                //               ),
                //             ),
                //             child: Stack(
                //               children: [
                //                 // 🔥 Gradient overlay
                //                 Positioned.fill(
                //                   child: Container(
                //                     decoration: const BoxDecoration(
                //                       borderRadius: BorderRadius.only(
                //                         bottomLeft: Radius.circular(18),
                //                         bottomRight: Radius.circular(18),
                //                       ),
                //                       gradient: LinearGradient(
                //                         colors: [
                //                           Colors.transparent,
                //                           Colors.black54,
                //                         ],
                //                         begin: Alignment.topCenter,
                //                         end: Alignment.bottomCenter,
                //                       ),
                //                     ),
                //                   ),
                //                 ),

                //                 // 🔥 Bottom-left service title
                //                 Positioned(
                //                   left: 16,
                //                   bottom: 16,
                //                   child: Text(
                //                     title,
                //                     style: const TextStyle(
                //                       color: Colors.white,
                //                       fontSize: 16,
                //                       fontWeight: FontWeight.w500,
                //                     ),
                //                   ),
                //                 ),

                //                 // 🔥 Bottom-right Book Now button
                //                 Positioned(
                //                   right: 16,
                //                   bottom: 12,
                //                   child: GestureDetector(
                //                     onTap: () {
                //                       Get.toNamed(
                //                         Routes.bookslot,
                //                         arguments: {
                //                           "image": imageUrl,
                //                           "name": service.name,
                //                           "description": service.description,
                //                           "price": service.price.toString(),
                //                           "features": service.features,
                //                         },
                //                       );
                //                     },
                //                     child: Container(
                //                       padding: const EdgeInsets.symmetric(
                //                           horizontal: 18, vertical: 10),
                //                       decoration: BoxDecoration(
                //                         color: Colors.white
                //                             .withValues(alpha: 0.18),
                //                         borderRadius: BorderRadius.circular(14),
                //                         border: Border.all(
                //                           color: Colors.white
                //                               .withValues(alpha: 0.35),
                //                           width: 1.2,
                //                         ),
                //                         boxShadow: [
                //                           BoxShadow(
                //                             color: Colors.white
                //                                 .withValues(alpha: 0.25),
                //                             blurRadius: 6,
                //                             offset: const Offset(0, 2),
                //                           ),
                //                         ],
                //                       ),
                //                       child: Text(
                //                         "book_now".tr,
                //                         style: const TextStyle(
                //                           color: Colors.white,
                //                           fontSize: 14,
                //                           fontWeight: FontWeight.w600,
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           );
                //         },
                //       );
                //     }),
                //   );
                // }),
                const SizedBox(height: 25),

                // --- Doorstep & In-Store Wash Buttons ---
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------------- SERVICES SECTION ----------------
                      Obx(() {
                        if (featuresController.isLoading.value) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(
                                  left: 2,
                                  right: 2,
                                  bottom: 12,
                                ),
                                child: Row(
                                  children: [
                                    SkeletonBox(
                                      width: 100,
                                      height: 24,
                                      radius: 8,
                                    ),
                                    Spacer(),
                                    SkeletonBox(
                                      width: 80,
                                      height: 32,
                                      radius: 18,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.52,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 3,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 14),
                                  itemBuilder: (context, index) => SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.52,
                                    child: const SkeletonBox(
                                      width: double.infinity,
                                      height: 180,
                                      radius: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        if (featuresController.services.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        final services = featuresController.services;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // -------- SECTION HEADER --------
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 2,
                                right: 2,
                                bottom: 12,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "services".tr,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.featureslist);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryLight,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "View_all".tr,
                                            style: const TextStyle(
                                              color: AppColors.textWhiteLight,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // -------- HORIZONTAL SERVICES --------
                            SizedBox(
                              height: MediaQuery.of(context).size.width * 0.52,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: services.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final service = services[index];

                                  // Resolved against the API origin the app is
                                  // connected to (see `resolveMediaUrl`).
                                  final imageUrl =
                                      resolveMediaUrl(service.imageUrl);

                                  return GestureDetector(
                                    onTap: () {
                                      _showServiceDetails(
                                        name: service.getLocalizedName(),
                                        description:
                                            service.getLocalizedDescription(),
                                        price: service.price,
                                      );
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.52,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // -------- SERVICE IMAGE --------
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(18),
                                              topRight: Radius.circular(18),
                                            ),
                                            child: Image.network(
                                              imageUrl,
                                              width: double.infinity,
                                              // Slightly shorter than before so the
                                              // "incl. VAT" line fits on 360dp phones.
                                              height: 110,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 110,
                                                  color: Colors.grey.shade200,
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.local_car_wash,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          // -------- SERVICE DETAILS --------
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Service Name
                                                  Text(
                                                    service.getLocalizedName(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF1E293B),
                                                    ),
                                                  ),

                                                  const Spacer(),

                                                  // Price (VAT inclusive) + Book Now
                                                  Row(
                                                    children: [
                                                      // Final price the customer pays
                                                      Expanded(
                                                        // The height cap keeps the row
                                                        // from ever growing taller than
                                                        // the "Book Now" chip, which used
                                                        // to overflow the card by a
                                                        // fraction of a pixel.
                                                        child: SizedBox(
                                                          height: 22,
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional
                                                                    .centerStart,
                                                            child: RiyalAmount(
                                                              // `totalAmount` is a `double`;
                                                              // without formatting it can read
                                                              // `13.800000000000001`.
                                                              formatAmount(
                                                                service
                                                                    .totalAmount,
                                                              ),
                                                              maxLines: 1,
                                                              // Fits the price to whatever
                                                              // space the card has instead of
                                                              // truncating it with `...`.
                                                              fitToWidth: true,
                                                              minFontSize: 11,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                  0xFF1E293B,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      // Book Now
                                                      GestureDetector(
                                                        onTap: () {
                                                          Get.toNamed(
                                                            Routes.bookslot,
                                                            arguments: {
                                                              "image": imageUrl,
                                                              "name": service
                                                                  .getLocalizedName(),
                                                              "description": service
                                                                  .getLocalizedDescription(),
                                                              "price": service
                                                                  .price
                                                                  .toString(),
                                                              "service_id":
                                                                  service.id,
                                                              "features":
                                                                  service
                                                                      .features,
                                                              // VAT breakdown from the backend
                                                              "vat_percentage":
                                                                  service
                                                                      .vatPercentage,
                                                              "vat_amount":
                                                                  service
                                                                      .vatAmount,
                                                              "total_amount":
                                                                  service
                                                                      .totalAmount,
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .secondaryLight,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              20,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            "book_now".tr,
                                                            style:
                                                                const TextStyle(
                                                              color: AppColors
                                                                  .textWhiteLight,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                      // --- SERVICE CARDS USING THE SAME WIDGET ---
                      // ServiceCard(
                      //   title: "doorstep_car_wash".tr,
                      //   subtitle: "convenience_at_your_home".tr,
                      //   buttonText: "book_now".tr,
                      //   imagePath: "assets/carwash/door_step.png",
                      //   onTap: () {
                      //     Get.toNamed(Routes.featureslist);
                      //   },
                      // ),
                      const SizedBox(height: 15),
                      ServiceCard(
                        title: "in_store_car_wash".tr,
                        subtitle: "visit_us_for_a_premium_clean".tr,
                        buttonText: "Partner_location".tr,
                        imagePath: "assets/carwash/in_store.png",
                        // discountText: "off_50".tr,
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
                      //const SizedBox(height: 20),

                      // ---------------- PROMO BANNERS AFTER WALLET ----------------
                      Text(
                        "offers_for_you".tr,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() {
                        final list = offersController.offers;

                        // One 2:1 box for the offer artwork on every device.
                        final cardWidth =
                            MediaQuery.sizeOf(context).width * 0.72;
                        final cardHeight = cardWidth / offerImageAspectRatio;

                        if (list.isEmpty) {
                          return Container(
                            height: cardHeight,
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 10),
                            child: SkeletonBox(
                              width: double.infinity,
                              height: cardHeight,
                              radius: 18,
                            ),
                          );
                        }

                        return SizedBox(
                          height: cardHeight,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final offer = list[index];

                              // Keep your existing discount formatting
                              final List<InlineSpan> discountTitleSpans =
                                  offer.discountType == "percentage"
                                      ? [
                                          TextSpan(
                                            text:
                                                "${offer.discountValue}${'percent_off'.tr}",
                                          ),
                                        ]
                                      : riyalAmountSpans(
                                          amount: offer.discountValue,
                                          suffix: " ${'off'.tr}",
                                        );

                              return GestureDetector(
                                onTap: () => Get.toNamed(
                                  Routes.offerscreen,
                                  arguments: offer,
                                ),
                                child: Container(
                                  width: cardWidth,
                                  height: cardHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.10),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Full offer image (same 2:1 artwork)
                                      OfferBanner(offer: offer),

                                      // Bottom gradient for text visibility
                                      const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black12,
                                              Colors.black54,
                                            ],
                                            stops: [0.35, 0.65, 1.0],
                                          ),
                                        ),
                                      ),

                                      // Discount text on image
                                      Positioned(
                                        left: 16,
                                        right: 16,
                                        bottom: 16,
                                        child: Text.rich(
                                          TextSpan(
                                            children: discountTitleSpans,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),

                      // Obx(() {
                      //   final list = offersController.offers;

                      //   if (list.isEmpty) {
                      //     return Container(
                      //       height: 180,
                      //       width: double.infinity,
                      //       margin: const EdgeInsets.only(top: 10),
                      //       child: const SkeletonBox(
                      //         width: double.infinity,
                      //         height: 180,
                      //         radius: 18,
                      //       ),
                      //     );
                      //   }

                      //   return SizedBox(
                      //     height: 200,
                      //     child :
                      // child: ListView.separated(
                      //   scrollDirection: Axis.horizontal,
                      //   physics: const BouncingScrollPhysics(),
                      //   padding: const EdgeInsets.symmetric(horizontal: 12),
                      //   itemCount: list.length,
                      //   separatorBuilder: (_, __) =>
                      //       const SizedBox(width: 12),
                      //   itemBuilder: (context, index) {
                      //     final offer = list[index];

                      //     final List<InlineSpan> discountTitleSpans =
                      //         offer.discountType == "percentage"
                      //             ? [
                      //                 TextSpan(
                      //                   text:
                      //                       "${offer.discountValue}${'percent_off'.tr}",
                      //                 ),
                      //               ]
                      //             : riyalAmountSpans(
                      //                 amount: offer.discountValue,
                      //                 suffix: " ${'off'.tr}",
                      //               );

                      //     return GestureDetector(
                      //       onTap: () => Get.toNamed(
                      //         Routes.offerscreen,
                      //         arguments: offer,
                      //       ),
                      //       child: Container(
                      //         width:
                      //             MediaQuery.of(context).size.width * 0.62,
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius: BorderRadius.circular(16),
                      //           boxShadow: [
                      //             BoxShadow(
                      //               color: Colors.black.withValues(
                      //                 alpha: 0.08,
                      //               ),
                      //               blurRadius: 10,
                      //               offset: const Offset(0, 4),
                      //             ),
                      //           ],
                      //         ),
                      //         clipBehavior: Clip.antiAlias,
                      //         child: Column(
                      //           crossAxisAlignment:
                      //               CrossAxisAlignment.start,
                      //           children: [
                      //             // ---- OFFER IMAGE ----
                      //             SizedBox(
                      //               height: 110,
                      //               width: double.infinity,
                      //               child: OfferBanner(
                      //                 offer: offer,
                      //                 height: 110,
                      //               ),
                      //             ),

                      //             // ---- WHITE FOOTER ----
                      //             Padding(
                      //               padding: const EdgeInsets.fromLTRB(
                      //                 12,
                      //                 10,
                      //                 12,
                      //                 12,
                      //               ),
                      //               child: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Row(
                      //                     children: [
                      //                       Expanded(
                      //                         child: Text.rich(
                      //                           TextSpan(
                      //                             children:
                      //                                 discountTitleSpans,
                      //                           ),
                      //                           maxLines: 1,
                      //                           overflow:
                      //                               TextOverflow.ellipsis,
                      //                           style: const TextStyle(
                      //                             color: Colors.black,
                      //                             fontSize: 18,
                      //                             fontWeight:
                      //                                 FontWeight.w900,
                      //                           ),
                      //                         ),
                      //                       ),
                      //                       const Icon(
                      //                         Icons.chevron_right,
                      //                         size: 18,
                      //                         color: Colors.grey,
                      //                       ),
                      //                     ],
                      //                   ),
                      //                   // const SizedBox(height: 2),
                      //                   // Text(
                      //                   //   offer.title,
                      //                   //   maxLines: 1,
                      //                   //   overflow: TextOverflow.ellipsis,
                      //                   //   style: TextStyle(
                      //                   //     color: Colors.grey.shade800,
                      //                   //     fontSize: 12.5,
                      //                   //   ),
                      //                   // ),
                      //                   // const SizedBox(height: 4),
                      //                   // Text(
                      //                   //   "${"expires_in".tr} ${offer.expiryDays} ${"days".tr}",
                      //                   //   maxLines: 1,
                      //                   //   overflow: TextOverflow.ellipsis,
                      //                   //   style: TextStyle(
                      //                   //     color: Colors.grey.shade500,
                      //                   //     fontSize: 11,
                      //                   //   ),
                      //                   // ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      //   );
                      // }),

                      // ---------------- PROMO BANNER AFTER WALLET ----------------
                      // Obx(() {
                      //   final list = offersController.offers;

                      //   if (list.isEmpty) {
                      //     return Container(
                      //       height: 180,
                      //       width: double.infinity,
                      //       margin: const EdgeInsets.only(top: 10),
                      //       child: const SkeletonBox(
                      //         width: double.infinity,
                      //         height: 180,
                      //         radius: 18,
                      //       ),
                      //     );
                      //   }

                      //   // Pick a specific offer (by code OR first item)
                      //   const homeOfferCode = "aa";
                      //   final offer = list.firstWhere(
                      //     (o) => o.offerCode == homeOfferCode,
                      //     orElse: () => list.first,
                      //   );

                      //   // Discount title
                      //   final discountTitle = offer.discountType == "percentage"
                      //       ? "${offer.discountValue}% OFF"
                      //       : "SAR ${offer.discountValue} OFF";

                      //   return Container(
                      //     height: 180,
                      //     width: double.infinity,
                      //     //     padding: const EdgeInsets.all(16),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(18),
                      //       color: const Color(
                      //           0xFFFFF4E5), // soft beige background
                      //     ),
                      //     child: Stack(
                      //       children: [
                      //         // --- Soft Circles Background ---
                      //         Positioned(
                      //           top: -20,
                      //           right: -20,
                      //           child: Container(
                      //             height: 120,
                      //             width: 120,
                      //             decoration: const BoxDecoration(
                      //               color: Color(0xFFFFE7C5),
                      //               shape: BoxShape.circle,
                      //             ),
                      //           ),
                      //         ),
                      //         Positioned(
                      //           bottom: -30,
                      //           left: -30,
                      //           child: Container(
                      //             height: 140,
                      //             width: 140,
                      //             decoration: const BoxDecoration(
                      //               color: Color(0xFFFFE7C5),
                      //               shape: BoxShape.circle,
                      //             ),
                      //           ),
                      //         ),

                      //         // ---- OFFER TEXT CONTENT ----
                      //         Padding(
                      //           padding: const EdgeInsets.all(10),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               // Discount
                      //               Text(
                      //                 discountTitle,
                      //                 style: const TextStyle(
                      //                   color: Colors.black,
                      //                   fontSize: 28,
                      //                   fontWeight: FontWeight.w900,
                      //                 ),
                      //               ),

                      //               const SizedBox(height: 6),

                      //               // Title
                      //               Text(
                      //                 offer.title,
                      //                 maxLines: 2,
                      //                 overflow: TextOverflow.ellipsis,
                      //                 style: const TextStyle(
                      //                   color: Colors.black,
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.w500,
                      //                 ),
                      //               ),

                      //               const Spacer(),

                      //               // Expiry
                      //               Text(
                      //                 "${"expires_in".tr} ${offer.expiryDays} days",
                      //                 style: const TextStyle(
                      //                   color: Colors.black87,
                      //                   fontSize: 13,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   );
                      // }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                //const SizedBox(height: 30), // Padding at the bottom
              ],
            ),
          ),
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
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
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
                    b.washerName ?? "not_assigned".tr,
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
            // Call the assigned technician. Only shown once a technician is
            // assigned and a usable number exists, so the customer never taps a
            // dead button.
            if ((b.washerPhone ?? "").isNotEmpty)
              _callTechnicianButton(b.washerPhone!),
            // ElevatedButton(
            //   onPressed: () {
            //     Get.toNamed(
            //       Routes.tracttechnicianview,
            //       arguments: b, // 👈 pass Datum
            //     );
            //   },
            //   child: const Text("Track"),
            // )
          ],
        ),

        const SizedBox(height: 20),

        // --- TIMELINE (YOUR IMAGE STYLE) ---
        _trackingTimeline(b.status),
      ],
    ),
  );
}

/// Round call button for the assigned technician, shown on the right of the
/// tracking card.
Widget _callTechnicianButton(String phone) {
  return IconButton(
    tooltip: "call_technician".tr,
    onPressed: () => _dialTechnician(phone),
    style: IconButton.styleFrom(
      backgroundColor: AppColors.blue.withValues(alpha: .12),
      foregroundColor: AppColors.blue,
      minimumSize: const Size(44, 44),
    ),
    icon: const Icon(Icons.call),
  );
}

/// Opens the phone dialer with the technician's number.
///
/// Uses `tel:` so the call app (dialer/WhatsApp/Truecaller chooser) handles the
/// call itself — the app never places a call on its own.
Future<void> _dialTechnician(String phone) async {
  final uri = Uri(scheme: "tel", path: phone);

  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened) errorToast("could_not_open_dialer".tr);
  } catch (e) {
    print("❌ Could not open dialer for $phone: $e");

    errorToast("could_not_open_dialer".tr);
  }
}

void _showServiceDetails({
  required String name,
  required String description,
  required double price,
}) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              // const Text(
              //   "Description",
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 8),

              Text(
                description.isNotEmpty
                    ? description
                    : "no_description_for_service".tr,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // Price
              // Text(
              //   "SAR ${price.toStringAsFixed(2)}",
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: AppColors.secondaryLight,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

Widget _advertisementCard(AdvertisementModel advertisement) {
  // Some rows only carry the snake_case key, so fall back to it.
  final imageUrl = resolveMediaUrl(
    advertisement.imageUrl.isNotEmpty
        ? advertisement.imageUrl
        : advertisement.imageUrlSnake,
  );

  if (imageUrl.isEmpty) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6),
    clipBehavior: Clip.antiAlias,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      ),
    ),
    child: Image.network(
      imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: Colors.grey,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        // Placeholder while the image downloads — no spinner.
        return Container(width: double.infinity, color: Colors.grey.shade200);
      },
    ),
  );
}

Widget _trackingTimeline(String status) {
  bool assigned =
      status == "ASSIGNED" || status == "ARRIVED" || status == "IN_PROGRESS";
  bool arrived = status == "ARRIVED" || status == "IN_PROGRESS";
  bool inProgress = status == "IN_PROGRESS";

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // ASSIGNED
      _timelineStep(
        active: assigned,
        label: "assigned".tr,
        icon: Icons.check_circle,
      ),

      // ARRIVED
      _timelineStep(
        active: arrived,
        label: "arrived".tr,
        icon: Icons.radio_button_checked,
      ),

      // IN_PROGRESS
      _timelineStep(
        active: inProgress,
        label: "in_progress".tr,
        icon: Icons.local_car_wash,
      ),

      // COMPLETED (always inactive here)
      _timelineStep(active: false, label: "completed".tr, icon: Icons.flag),
    ],
  );
}

Widget _timelineStep({
  required bool active,
  required String label,
  required IconData icon,
}) {
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
        child: Icon(icon, size: 18, color: active ? Colors.white : Colors.grey),
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

  const ServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imagePath,
    this.discountText,
    this.onTap,
  });

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
            BoxShadow(color: Colors.grey, blurRadius: 15, offset: Offset(5, 5)),
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
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade900),
                  ),

                  const SizedBox(height: 12),

                  // Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      // color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.secondaryLight,
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
