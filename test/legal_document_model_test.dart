import 'package:flutter_test/flutter_test.dart';
import 'package:car_wash_customer_app/app/models/legal_document_model.dart';

void main() {
  group('LegalDocumentModel', () {
    test('parses english and arabic payload fields', () {
      final json = {
        'id': 'id-1',
        'type': 'TERMS_AND_CONDITIONS',
        'title_en': 'Terms & Conditions',
        'content_en': '<p>English content</p>',
        'title_ar': 'الشروط والأحكام',
        'content_ar': '<p>محتوى عربي</p>',
        'status': 'ACTIVE',
      };

      final model = LegalDocumentModel.fromJson(json);

      expect(model.id, 'id-1');
      expect(model.type, 'TERMS_AND_CONDITIONS');
      expect(model.getTitle('en'), 'Terms & Conditions');
      expect(model.getTitle('ar'), 'الشروط والأحكام');
      expect(model.getContent('en'), '<p>English content</p>');
      expect(model.getContent('ar'), '<p>محتوى عربي</p>');
    });
  });
}
