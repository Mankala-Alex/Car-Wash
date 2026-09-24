import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/terms_conditions_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class TermsConditionsView extends GetView<TermsConditionsController> {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(
              title: 'Booking & service usage',
              body:
                  'By using our car wash services, you agree to book appointments, provide accurate vehicle and contact details, and follow the scheduled time slot and service instructions provided by the company.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Payments',
              body:
                  'All service charges, package prices, and promotional discounts are subject to the current pricing displayed in the app. Payments must be completed before or at the time of service as applicable.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Cancellation & rescheduling',
              body:
                  'Customers may cancel or reschedule bookings according to the policy displayed in the app. Late cancellations or no-shows may incur applicable fees or result in forfeiture of the booking.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Vehicle condition',
              body:
                  'The company is not responsible for pre-existing damage, wear, or defects in the vehicle. Customers should inform the service team of any special concerns before the wash begins.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Acceptance of terms',
              body:
                  'By continuing to use the app and booking a service, you confirm that you have read, understood, and agreed to these terms and conditions.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required String body}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
