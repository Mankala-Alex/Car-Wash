import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/profile/about_us_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

class AboutUsView extends GetView<AboutUsController> {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'About Us',
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Car Wash Customer App',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'We are dedicated to delivering easy, convenient, and premium car care services right to your doorstep or at our partner locations. Our goal is to save time while delivering exceptional quality and a smooth customer experience.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _infoCard(
              title: 'Our mission',
              body:
                  'To make professional car washing simple, reliable, and accessible for every customer through technology and trusted service providers.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Our values',
              body:
                  'We value transparency, quality service, punctuality, customer convenience, and consistent support from booking to completion.',
            ),
            const SizedBox(height: 14),
            _infoCard(
              title: 'Why choose us',
              body:
                  'Easy app booking, flexible service options, verified professionals, and a customer-first approach create a seamless car care experience for every order.',
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
