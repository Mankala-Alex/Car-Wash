import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/config/constants.dart';
import 'package:my_new_app/app/controllers/dashboard/booking_history_details_controller.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class BookingHistoryDetailsView
    extends GetView<BookingHistoryDetailsController> {
  const BookingHistoryDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final b = controller.booking;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text("Service Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info("Service", b.serviceName),
            _info("Customer", b.customerName),
            _info("Vehicle", b.vehicle),
            _info("Amount", "₹${b.amount}"),
            _info("Status", b.status),
            const SizedBox(height: 24),
            const Text("Before Wash",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _imageRow(b.beforeImages),
            const SizedBox(height: 24),
            const Text("After Wash",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _imageRow(b.afterImages),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _imageRow(List<String> images) {
    if (images.isEmpty) {
      return const Text("No images available");
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final path = images[i].replaceAll("\\", "/");

          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              Constants.imageBaseUrl + path,
              width: 180,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
