import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/privacy_policy_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Privacy Policy',
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
              title: 'Information we collect',
              body:
                  'We may collect your name, email address, phone number, booking details, car information, payment details, and location data required to provide our services safely and efficiently.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'How we use your information',
              body:
                  'Your data is used to process bookings, improve service quality, communicate with you, support payments, and personalize the app experience in accordance with our service requirements.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Data sharing',
              body:
                  'We do not sell personal data. We may share necessary information with trusted service providers, payment processors, or legal authorities when required by law or to support service delivery.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Security',
              body:
                  'We use reasonable technical and organizational safeguards to protect your personal information from unauthorized access, misuse, loss, or disclosure.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Your rights',
              body:
                  'You may request access to, correction of, or deletion of your personal data where legally applicable. Contact us through the app support channel for any privacy-related requests.',
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
