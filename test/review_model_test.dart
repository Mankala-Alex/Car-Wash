import 'package:car_wash_customer_app/app/models/reviews/review_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewModel', () {
    test('parses the booking review payload returned by the backend', () {
      final json = {
        'id': 'rev_123',
        'booking_id': 'booking_456',
        'customer_id': 'cust_789',
        'technician_id': 'tech_321',
        'technician_name': 'Alex',
        'booking_code': 'BKG-1001',
        'service_name': 'Premium Wash',
        'rating': 5,
        'comment': 'Excellent service!',
        'created_at': '2026-10-06T10:00:00.000Z',
        'updated_at': '2026-10-06T10:15:00.000Z',
      };

      final review = ReviewModel.fromJson(json);

      expect(review.id, 'rev_123');
      expect(review.bookingId, 'booking_456');
      expect(review.rating, 5);
      expect(review.comment, 'Excellent service!');
      expect(review.serviceName, 'Premium Wash');
    });
  });
}
