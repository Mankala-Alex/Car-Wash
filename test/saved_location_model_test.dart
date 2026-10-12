import 'package:flutter_test/flutter_test.dart';
import 'package:car_wash_customer_app/app/models/booking slot/saved_location_model.dart';

void main() {
  group('SavedLocation', () {
    test(
        'serializes and deserializes pincode without breaking older stored entries',
        () {
      final saved = SavedLocation(
        id: 'loc-1',
        label: 'Home',
        address: '123 Main St',
        latitude: 24.7136,
        longitude: 46.6753,
        houseNo: '12',
        landmark: 'Near park',
        phoneNumber: '0500000000',
        pincode: '12271',
      );

      final json = saved.toJson();
      expect(json['pincode'], '12271');

      final fromJson = SavedLocation.fromJson(json);
      expect(fromJson.pincode, '12271');

      final legacyJson = {
        'id': 'loc-2',
        'label': 'Work',
        'address': '456 Other St',
        'latitude': 24.7,
        'longitude': 46.6,
        'houseNo': '99',
        'phoneNumber': '0555555555',
      };

      final legacyLocation = SavedLocation.fromJson(legacyJson);
      expect(legacyLocation.pincode, isNull);
    });
  });
}
