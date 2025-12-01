import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/profile/offer_screen_controller.dart';

class OfferScreenView extends GetView<OfferScreenController> {
  const OfferScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final offer = controller.offer;

    /// Discount title logic
    String discountTitle = offer.discountType == "percentage"
        ? "${offer.discountValue}% OFF"
        : "SAR ${offer.discountValue} OFF";

    /// Expiry date
    String expiryDate = controller.getExpiryDate(offer.expiryDays);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Offer Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/carwash/toyota_camry.png", // static image
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE (Discount)
            Text(
              discountTitle,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            /// TERMS / DESCRIPTION
            Text(
              offer.terms.isNotEmpty
                  ? offer.title
                  : "No description available.",
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 28),

            /// EXPIRY + TERMS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// EXPIRY ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Expires on",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        expiryDate,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 14),

                  /// TERMS TITLE
                  const Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Bullet Points (split by ".")
                  /// Bullet Points (split by ".")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: offer.terms
                        .split(".")
                        .where((t) => t.trim().isNotEmpty)
                        .map((t) => TermsBullet(
                            text: "${t.trim()}.")) // trim each sentence
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// Redeem button (no backend yet)
            Container(
              width: double.infinity,
              height: 52,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Redeem Now",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsBullet extends StatelessWidget {
  final String text;
  const TermsBullet({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // bullet icon
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          // Use Expanded so text gets available width and wraps
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
