import 'package:car_wash_customer_app/app/controllers/booking_flow/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Method",
        ),
      ),
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          }

          return ElevatedButton(
            onPressed: controller.payNow,
            child: const Text(
              "Pay Now",
            ),
          );
        }),
      ),
    );
  }
}
