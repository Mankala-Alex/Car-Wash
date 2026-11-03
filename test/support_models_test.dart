import 'package:flutter_test/flutter_test.dart';
import 'package:car_wash_customer_app/app/models/support/support_models.dart';

void main() {
  group('FaqCategory', () {
    test('picks the requested language and falls back when empty', () {
      const category = FaqCategory(
        id: 'payment_issues',
        nameEn: 'Payment Issues',
        nameAr: 'مشاكل الدفع',
      );

      expect(category.localizedName('en'), 'Payment Issues');
      expect(category.localizedName('ar'), 'مشاكل الدفع');
      expect(category.localizedName('ar_SA'), 'مشاكل الدفع');

      const englishOnly = FaqCategory(
        id: 'app_issues',
        nameEn: 'App Technical Issues',
        nameAr: '',
      );

      expect(englishOnly.localizedName('ar'), 'App Technical Issues');
    });

    test('parses api json', () {
      final category = FaqCategory.fromJson({
        'id': 'booking_issues',
        'name_en': 'Booking Issues',
        'name_ar': 'مشاكل الحجز',
        'icon': 'calendar',
      });

      expect(category.id, 'booking_issues');
      expect(category.icon, 'calendar');
    });
  });

  group('FaqQuestion', () {
    test('localizes question, answer, category and troubleshooting steps', () {
      final question = FaqQuestion.fromJson({
        'id': 'booking_issues__check_status',
        'category_id': 'booking_issues',
        'question_en': 'How can I check my booking status?',
        'question_ar': 'كيف أتحقق من حالة حجزي؟',
        'answer_en': 'Open My Bookings.',
        'answer_ar': 'افتح حجوزاتي.',
        'troubleshooting': [
          {'en': 'Open the app', 'ar': 'افتح التطبيق'},
          {'en': 'Tap My Bookings', 'ar': ''},
          {'en': '', 'ar': ''},
        ],
        'screen_route': 'booking_history',
        'category': {'name_en': 'Booking Issues', 'name_ar': 'مشاكل الحجز'},
      });

      expect(
        question.localizedQuestion('en'),
        'How can I check my booking status?',
      );
      expect(question.localizedQuestion('ar'), 'كيف أتحقق من حالة حجزي؟');
      expect(question.localizedAnswer('ar'), 'افتح حجوزاتي.');
      expect(question.localizedCategory('ar'), 'مشاكل الحجز');
      expect(question.screenRoute, 'booking_history');

      // Arabic falls back to English when a step has no translation, and empty
      // steps are dropped.
      expect(question.localizedSteps('ar'), [
        'افتح التطبيق',
        'Tap My Bookings',
      ]);
      expect(question.localizedSteps('en'), [
        'Open the app',
        'Tap My Bookings',
      ]);
    });
  });

  group('SupportMessage', () {
    test('classifies senders and keeps delivery state', () {
      final mine = SupportMessage.fromJson({
        'id': 'msg-1',
        'conversation_id': 'conv-1',
        'sender_type': 'customer',
        'message': 'Hello',
        'client_message_id': 'c_123',
        'created_at': '2026-10-30T10:00:00.000Z',
      });

      expect(mine.isMine, isTrue);
      expect(mine.isSystem, isFalse);
      expect(mine.clientMessageId, 'c_123');
      expect(mine.createdAt, isNotNull);

      final agent = SupportMessage.fromJson({
        'id': 'msg-2',
        'conversation_id': 'conv-1',
        'sender_type': 'agent',
        'message': 'Hi, how can I help?',
        'sender_name': 'Sara',
      });

      expect(agent.isMine, isFalse);
      expect(agent.senderName, 'Sara');

      final failed = mine.copyWith(status: SupportMessageStatus.failed);
      expect(failed.status, SupportMessageStatus.failed);
      expect(failed.message, 'Hello');
    });
  });

  group('SupportConversation', () {
    test('exposes status flags and copies state', () {
      final conversation = SupportConversation.fromJson({
        'id': 'conv-1',
        'status': 'OPEN',
        'customer_unread_count': 2,
        'assigned_admin_name': null,
      });

      expect(conversation.isClosed, isFalse);
      expect(conversation.hasAgent, isFalse);
      expect(conversation.customerUnreadCount, 2);

      final assigned = conversation.copyWith(
        status: 'ASSIGNED',
        assignedAdminName: 'Sara',
      );

      expect(assigned.id, 'conv-1');
      expect(assigned.status, 'ASSIGNED');
      expect(assigned.hasAgent, isTrue);

      final closed = conversation.copyWith(status: 'closed');
      expect(closed.isClosed, isTrue);
    });
  });
}
