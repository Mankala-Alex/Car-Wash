import 'package:car_wash_customer_app/app/controllers/booking_flow/payment_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("payment_details".trPluralParams()),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          /// SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Secure Header
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(
                          Icons.lock,
                          size: 40,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Secure Checkout",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "confirm_service_details_before_payment".tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SERVICE CARD
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        /// Banner
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            image: DecorationImage(
                              image: controller.image.isNotEmpty
                                  ? NetworkImage(controller.image)
                                  : const AssetImage(
                                          "assets/images/service_placeholder.png")
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            alignment: Alignment.bottomLeft,

                            /// Gradient Overlay
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(.5),
                                ],
                              ),
                            ),

                            /// PREMIUM TAG
                          ),
                        ),

                        /// CONTENT
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              /// Service Name
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Selected Service",
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          controller.serviceName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.local_car_wash,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),

                              ///const SizedBox(height: 16),

                              //const Divider(),

                              //const SizedBox(height: 16),

                              /// DATE & TIME
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: Row(
                              //         children: [
                              //           Container(
                              //             padding: const EdgeInsets.all(10),
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey.shade200,
                              //               borderRadius:
                              //                   BorderRadius.circular(10),
                              //             ),
                              //             child:
                              //                 const Icon(Icons.calendar_month),
                              //           ),
                              //           const SizedBox(width: 10),
                              //           Column(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //               const Text("Date"),
                              //               Text(
                              //                 controller.formattedDate
                              //                     .split("•")
                              //                     .first,
                              //                 style: const TextStyle(
                              //                   fontWeight: FontWeight.bold,
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //     Expanded(
                              //       child: Row(
                              //         children: [
                              //           Container(
                              //             padding: const EdgeInsets.all(10),
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey.shade200,
                              //               borderRadius:
                              //                   BorderRadius.circular(10),
                              //             ),
                              //             child: const Icon(Icons.access_time),
                              //           ),
                              //           const SizedBox(width: 10),
                              //           Column(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //               const Text("Time"),
                              //               Text(
                              //                 controller.formattedDate
                              //                     .split("•")
                              //                     .last,
                              //                 style: const TextStyle(
                              //                   fontWeight: FontWeight.bold,
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),

                              const SizedBox(height: 16),

                              const Divider(),

                              const SizedBox(height: 16),

                              /// PRICE DETAILS
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("subtotal".tr),
                                  Text(
                                    "${controller.amount.toStringAsFixed(2)} SAR",
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("tax".tr + " (0%)"),
                                  Text("0.00 SAR"),
                                ],
                              ),

                              const SizedBox(height: 16),

                              /// TOTAL BOX
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "total_amount".tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "${controller.amount.toStringAsFixed(2)} SAR",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// PAYMENT METHOD
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(14),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.all(10),
                  //         decoration: BoxDecoration(
                  //           color: Colors.black,
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //         child: const Text(
                  //           "VISA",
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //       ),
                  //       const SizedBox(width: 12),
                  //       const Expanded(
                  //         child: Text(
                  //           "Secure Card Payment",
                  //         ),
                  //       ),
                  //       const Icon(
                  //         Icons.check_circle,
                  //         color: Colors.blue,
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          /// PAY BUTTON
          Container(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const CircularProgressIndicator();
              }

              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: controller.payNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "pay_now".tr,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Secure 256-bit SSL Encrypted Payment",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
