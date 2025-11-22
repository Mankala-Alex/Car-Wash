import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/dashboard_controller.dart';
import 'package:my_new_app/app/routes/app_routes.dart';
import 'package:my_new_app/app/theme/app_theme.dart';

class Page2View extends GetView<DashboardController> {
  const Page2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Bookings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------
            // CURRENT BOOKING
            // ---------------------------------------------------
            const Text(
              "Current Booking",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // TOP ROW: image + text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CIRCLE AVATAR
                      Container(
                        height: 55,
                        width: 55,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffEAEAEA),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            "assets/carwash/avatar.png", // Replace with your image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // TITLE + PROVIDER + PRICE
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Premium Exterior Wash",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Provider: John D.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "\$45.00",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),

                  // BUTTON ROW (ONLY TRACK + CANCEL)
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          Icons.location_on,
                          "Track",
                          Colors.black,
                          AppColors.borderGray,
                        ),
                      ),

                      const SizedBox(width: 10), // <-- GAP OF 10PX

                      Expanded(
                        child: _actionButton(
                          Icons.close,
                          "Cancel",
                          Colors.white,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ---------------------------------------------------
            // PAST BOOKINGS TITLE
            // ---------------------------------------------------
            const Text(
              "Past Bookings",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- PAST BOOKINGS LIST ----------------
            _pastBookingCard(
              index: 0,
              title: "Full Interior Detail",
              provider: "Jane S.",
              price: "\$90.00",
            ),
            const SizedBox(height: 18),

            _pastBookingCard(
              index: 1,
              title: "Ceramic Coating",
              provider: "Mike T.",
              price: "\$250.00",
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color iconAndTextColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor, // ← DIFFERENT BACKGROUND COLOR
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconAndTextColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: iconAndTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PAST BOOKING CARD (With star rating)
  // ===============================================================
  Widget _pastBookingCard({
    required int index,
    required String title,
    required String provider,
    required String price,
  }) {
    return GetBuilder<DashboardController>(
      builder: (ctrl) {
        int rating = ctrl.ratingMap[index] ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGray),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.06),
            //     blurRadius: 10,
            //     offset: const Offset(0, 4),
            //   ),
            // ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE + PRICE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                "Provider: $provider",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 10),

              // ⭐ INTERACTIVE STAR RATING ⭐
              Row(
                children: List.generate(5, (starIndex) {
                  bool isFilled = starIndex < rating;

                  return GestureDetector(
                    onTap: () => ctrl.setRating(index, starIndex + 1),
                    child: Icon(
                      isFilled ? Icons.star : Icons.star_border,
                      size: 26,
                      color: isFilled ? AppColors.warningLight : Colors.grey,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 14),

              // BUTTON
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.bookslot);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.secondaryLight
                      // gradient: const LinearGradient(
                      //   colors: [Color(0xff007BFF), Color(0xff00AFFF)],
                      // ),
                      ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Book Again",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
