import 'package:flutter_test/flutter_test.dart';

import 'package:car_wash_customer_app/app/models/payment/saved_card_model.dart';

void main() {
  group('SavedCardModel', () {
    test('parses the backend saved-card payload', () {
      final card = SavedCardModel.fromJson({
        "id": 7,
        "masked_pan": "xxxxxxxxxxxx1111",
        "card_brand": "VISA",
        "expiry_month": 12,
        "expiry_year": 2029,
        "holder_name": "tester",
        "is_default": true,
        "last_used_at": "2026-10-28T08:00:00.000Z",
        "created_at": "2026-10-27T08:00:00.000Z",
      });

      expect(card.id, 7);
      expect(card.cardBrand, "VISA");
      expect(card.isDefault, isTrue);
      expect(card.holderName, "tester");
      expect(card.lastUsedAt, isNotNull);
    });

    test('displayLabel shows the brand and the last four digits', () {
      final card = SavedCardModel.fromJson({
        "id": 1,
        "masked_pan": "xxxx-xxxx-xxxx-1111",
        "card_brand": "MASTERCARD",
      });

      expect(card.displayLabel, "MASTERCARD •••• 1111");
    });

    test('displayLabel does not dangle when no digits are returned', () {
      final card = SavedCardModel.fromJson({
        "id": 1,
        "masked_pan": null,
        "card_brand": "VISA",
      });

      expect(card.displayLabel, "VISA");
    });

    test('formattedExpiry pads a two-digit month and shortens the year', () {
      final card = SavedCardModel.fromJson({
        "id": 1,
        "expiry_month": 3,
        "expiry_year": 2029,
      });

      expect(card.formattedExpiry, "03/29");
    });

    test('formattedExpiry is empty when Paymob did not return an expiry', () {
      final card = SavedCardModel.fromJson({"id": 1});

      expect(card.formattedExpiry, isEmpty);
    });

    test('rows without a usable id are rejected downstream via id == 0', () {
      final card = SavedCardModel.fromJson({"id": null});

      expect(card.id, 0);
    });
  });
}
