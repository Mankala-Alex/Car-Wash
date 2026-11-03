import 'package:flutter_test/flutter_test.dart';
import 'package:car_wash_customer_app/app/models/support/booking_support_models.dart';
import 'package:car_wash_customer_app/app/models/support/support_models.dart';

void main() {
  group('BookingSupportSummary', () {
    test('uses backend labels and falls back between languages', () {
      final summary = BookingSupportSummary.fromJson({
        'id': 'bk-1',
        'booking_code': 'BK-123456',
        'service_name_en': 'Premium Car Wash',
        'service_name_ar': 'غسيل مميز',
        'scheduled_at': '2026-11-05T07:30:00.000Z',
        'status': 'ASSIGNED',
        'status_label_en': 'Assigned',
        'status_label_ar': 'تم تعيين فني',
        'payment_status': 'PAID',
        'payment_status_label_en': 'Paid',
        'payment_status_label_ar': 'مدفوع',
        'amount': '115.00',
        'has_technician': true,
        'technician_name': 'Ahmed',
        'can_request_cancellation': false,
      });

      expect(summary.bookingCode, 'BK-123456');
      expect(summary.serviceName('en'), 'Premium Car Wash');
      expect(summary.serviceName('ar'), 'غسيل مميز');
      expect(summary.statusLabel('ar'), 'تم تعيين فني');
      expect(summary.paymentLabel('en'), 'Paid');
      expect(summary.amount, 115.0);
      expect(summary.hasTechnician, isTrue);
      expect(summary.canRequestCancellation, isFalse);

      // Arabic request but the service has only an English name.
      final englishOnly = BookingSupportSummary.fromJson({
        'id': 'bk-2',
        'booking_code': 'BK-2',
        'service_name_en': 'Basic Wash',
      });
      expect(englishOnly.serviceName('ar'), 'Basic Wash');
      expect(englishOnly.amount, 0);
    });
  });

  group('BookingHelpPayload', () {
    test('parses categories/questions and finds them', () {
      final payload = BookingHelpPayload.fromJson({
        'booking': {'id': 'bk-1', 'booking_code': 'BK-1'},
        'categories': [
          {
            'id': 'technician',
            'label_en': 'Technician issues',
            'label_ar': 'مشاكل الفني',
            'icon': 'technician',
            'questions': [
              {
                'id': 'bk_no_technician',
                'category': 'technician',
                'question_en': 'No technician has been assigned.',
                'question_ar': 'لم يتم تعيين فني.',
              },
            ],
          },
        ],
      });

      expect(payload.categories, hasLength(1));
      expect(payload.categories.first.localizedLabel('ar'), 'مشاكل الفني');
      expect(
        payload.findQuestion('bk_no_technician')?.questionEn,
        'No technician has been assigned.',
      );
      expect(payload.findQuestion('missing'), isNull);
      expect(payload.categoryOf('technician')?.id, 'technician');
    });

    test('handles an empty payload without throwing', () {
      final payload = BookingHelpPayload.fromJson({});
      expect(payload.categories, isEmpty);
      expect(payload.booking.id, '');
    });
  });

  group('BookingHelpAnswer', () {
    test('localizes answer and steps, exposes urgency', () {
      final answer = BookingHelpAnswer.fromJson({
        'booking': {'id': 'bk-1', 'booking_code': 'BK-1'},
        'question': {'id': 'q1', 'question_en': 'Q', 'question_ar': 'س'},
        'answer': {
          'en': 'Your payment is being verified.',
          'ar': 'جاري التحقق من دفعتك.',
        },
        'steps': [
          {'en': 'Open My Bookings', 'ar': 'افتح حجوزاتي'},
          {'en': 'Check the status', 'ar': ''},
        ],
        'urgent': true,
        'can_request_cancellation': true,
      });

      expect(answer.localizedAnswer('en'), 'Your payment is being verified.');
      expect(answer.localizedAnswer('ar'), 'جاري التحقق من دفعتك.');
      expect(answer.localizedSteps('ar'), ['افتح حجوزاتي', 'Check the status']);
      expect(answer.urgent, isTrue);
      expect(answer.canRequestCancellation, isTrue);
    });
  });

  group('SupportConversation booking link', () {
    test('parses the booking reference attached by the backend', () {
      final conversation = SupportConversation.fromJson({
        'id': 'SUP-1',
        'status': 'ASSIGNED',
        'booking_id': 'bk-1',
        'booking_code': 'BK-999',
        'booking': {
          'booking_code': 'BK-999',
          'status': 'ASSIGNED',
          'service_name': 'Premium',
          'scheduled_at': '2026-11-05T07:30:00.000Z',
          'amount': '115.00',
          'payment_status': 'PAID',
        },
      });

      expect(conversation.bookingId, 'bk-1');
      expect(conversation.bookingCode, 'BK-999');
      expect(conversation.booking?.status, 'ASSIGNED');
      expect(conversation.booking?.paymentStatus, 'PAID');
      expect(conversation.booking?.amount, 115.0);

      final general = SupportConversation.fromJson({
        'id': 'SUP-2',
        'status': 'OPEN',
      });
      expect(general.booking, isNull);
    });
  });
}
