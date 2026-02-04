import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import 'package:car_wash_customer_app/app/helpers/flutter_toast.dart';

class CustomFeedbackDialog extends StatelessWidget {
  final int initialRating;
  final Function(int rating, String comments) onSubmit;

  const CustomFeedbackDialog({
    super.key,
    this.initialRating = 0,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    RxInt rating = initialRating.obs;
    final TextEditingController commentsController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TITLE
            const Text(
              "How was the service?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // SUBTITLE
            const Text(
              "Your feedback helps us improve the partner community experience.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // ⭐ RATING STARS
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => rating.value = index + 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        index < rating.value
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 40,
                        color:
                            index < rating.value ? Colors.orange : Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 28),

            // COMMENTS LABEL
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add comments (optional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // COMMENTS TEXT FIELD
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: commentsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Write your feedback...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SUBMIT BUTTON
            GestureDetector(
              onTap: () {
                if (rating.value > 0) {
                  onSubmit(rating.value, commentsController.text);
                  successToast(
                    "Review submitted",
                  );
                  Get.back();
                } else {
                  errorToast("Rating Required, Please select a rating");
                  // Get.snackbar(
                  //   'Rating Required',
                  //   'Please select a rating',
                  //   snackPosition: SnackPosition.BOTTOM,
                  // );
                }
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Submit Review",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // NOT NOW BUTTON
            GestureDetector(
              onTap: () => Get.back(),
              child: const Text(
                "Not Now",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
