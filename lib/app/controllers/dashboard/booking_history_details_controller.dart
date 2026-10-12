import 'package:car_wash_customer_app/app/models/reviews/review_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/models/booking%20slot/booking_history_model.dart';
import 'package:car_wash_customer_app/app/repositories/auth/book_service/book_slot_repository.dart';

class BookingHistoryDetailsController extends GetxController {
  late Datum booking;

  final BookSlotRepository repo = BookSlotRepository();

  final RxBool isReviewLoading = true.obs;
  final Rxn<ReviewModel> review = Rxn<ReviewModel>();

  @override
  void onInit() {
    super.onInit();

    booking = Get.arguments as Datum;

    loadReview();
  }

  Future<void> loadReview() async {
    if (booking.id.trim().isEmpty) {
      isReviewLoading.value = false;
      return;
    }

    try {
      isReviewLoading.value = true;

      final response = await repo.getReviewByBooking(booking.id);

      final reviewData = ReviewModel.fromResponse(response.data);

      review.value = reviewData;
    } on DioException catch (e) {
      // No review is not an error for this page.
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        review.value = null;
      } else {
        review.value = null;
      }
    } catch (e) {
      review.value = null;
    } finally {
      isReviewLoading.value = false;
    }
  }
}
