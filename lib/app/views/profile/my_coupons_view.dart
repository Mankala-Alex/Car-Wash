import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class MyCouponsView extends StatelessWidget {
  const MyCouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Column(
        children: [
          // 🔥 TOP HEADER WITH BACK BUTTON
          Container(
            width: double.infinity,
            height: 170,
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // 👈 Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ⭐ Keep title centered even with back icon
                    const Expanded(
                      child: Text(
                        "My Coupons",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // 👻 Dummy space to balance UI
                    const SizedBox(width: 32),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 GRID LIST
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _gridCard(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gridCard(int index) {
    final List<String> titles = [
      "Scratch & Win",
      "Cashback Offer",
      "Refer Bonus",
      "Free Wash",
    ];

    final List<IconData> icons = [
      Icons.star,
      Icons.card_giftcard,
      Icons.people,
      Icons.local_car_wash,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 12),

          // Title
          Text(
            titles[index],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          // Icon
          Icon(
            icons[index],
            size: 50,
            color: Colors.black87,
          ),

          // 🔘 Button at bottom
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: TextButton(
              onPressed: () {
                showCouponDialog(Get.context!);
              },
              child: const Text(
                "View Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textDefaultLight,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

void showCouponDialog(BuildContext context) {
  showDialog(
    context: Get.context!,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Make scrollable section
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // 👈 Fix alignment globally
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: const Icon(Icons.close,
                                size: 25, color: Colors.black),
                          ),
                        ),
                      ),
                      // 🎟 TITLE
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              "50% OFF",
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "On any In-Store Service",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 🔥 Coupon Code Box
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "SAVE50-XYZ123",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔥 BIG IMAGE SECTION
                      Container(
                        width: double.infinity,
                        height: 350, // Increased height
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            "assets/carwash/qr.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Center(
                          child:
                              Text("Scan Me", style: TextStyle(fontSize: 15))),

                      const SizedBox(height: 20),

                      // 📌 Coupon Details Section
                      const Text(
                        "Coupon Details",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      const Row(
                        children: [
                          Icon(Icons.discount, size: 20),
                          SizedBox(width: 6),
                          Text("50% off any car wash",
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.calendar_today, size: 20),
                          SizedBox(width: 6),
                          Text("Valid for 60 days",
                              style: TextStyle(fontSize: 15)),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 📌 Terms & Conditions (left aligned)
                      const Text(
                        "Terms & Conditions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 10),

                      // 👇 Now properly aligned left
                      const Text("• Valid for in-store services only."),
                      const Text("• Cannot be combined with any offer."),
                      const Text("• No cash value."),
                      const Text("• One-time use only."),
                      const Text("• Present QR code at service time."),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 🚀 Action Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.back(); // close dialog
                },
                child: const Text(
                  "Redeem Offer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}
