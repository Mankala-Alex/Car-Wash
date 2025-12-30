// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:my_new_app/app/controllers/booking_flow/scratch_card_controller.dart';
// import 'package:my_new_app/app/routes/app_routes.dart';
// import 'package:my_new_app/app/theme/app_theme.dart';
// import 'package:scratcher/scratcher.dart';

// class ScratchCardView extends GetView<ScratchCardController> {
//   const ScratchCardView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black.withOpacity(0.55),
//       body: Obx(() {
//         return GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onTap: () {
//             Get.back();
//             Get.delete<ScratchCardController>();
//           },
//           child: Center(
//             child: GestureDetector(
//               onTap: () {},
//               child: SizedBox(
//                 width: 280,
//                 height: 350,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // SCRATCH → COUPON CONTENT
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(35),
//                       child: controller.revealed.value
//                           ? _couponCard()
//                           : Stack(
//                               children: [
//                                 Scratcher(
//                                   brushSize: 30,
//                                   threshold: 20,
//                                   onThreshold: controller.onScratchComplete,
//                                   image: Image.asset(
//                                     "assets/carwash/scratchcard3.jpg",
//                                     fit: BoxFit.cover,
//                                   ),
//                                   child: _couponCard(),
//                                 ),

//                                 /// 🎬 Scratch animation at bottom center
//                                 Positioned(
//                                   bottom: 10,
//                                   left: 0,
//                                   right: 0,
//                                   child: SizedBox(
//                                       width: 120,
//                                       height: 120,
//                                       child: ColorFiltered(
//                                         colorFilter: const ColorFilter.mode(
//                                           Colors.black,
//                                           BlendMode.srcATop,
//                                         ),
//                                         child: Lottie.asset(
//                                             "assets/carwash/scratching.json",
//                                             repeat: true),
//                                       )),
//                                 ),
//                               ],
//                             ),
//                     ),

//                     // ANIMATION overlay (plays on top of coupon)
//                     if (controller.showAnimation.value)
//                       Positioned(
//                         top: 0,
//                         child: SizedBox(
//                           width: 500,
//                           height: 500,
//                           child: Lottie.asset(
//                             "assets/carwash/success_blast.json",
//                             repeat: false,
//                             onLoaded: (animation) {
//                               Future.delayed(animation.duration, () {
//                                 controller.animationFinished();
//                               });
//                             },
//                           ),
//                         ),
//                       ),

//                     // "VIEW COUPON" button after animation ends
//                     if (controller.revealed.value &&
//                         !controller.showAnimation.value)
//                       Positioned(
//                         bottom: -5,
//                         child: TextButton(
//                           onPressed: () {
//                             Get.toNamed(
//                               Routes.qrcouponview,
//                               arguments: controller.bookingCode,
//                             );
//                             Get.delete<ScratchCardController>();
//                           },
//                           child: const Text(
//                             "View Coupon",
//                             style: TextStyle(fontSize: 16, color: Colors.black),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _couponCard() {
//     return Container(
//       color: AppColors.primaryLight,
//       alignment: Alignment.center,
//       child: const Text(
//         "🎟 50% OFF Next Was",
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
