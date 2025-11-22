import 'package:get/get.dart';

class FeaturesListController extends GetxController {
  final RxList<Map<String, dynamic>> services = <Map<String, dynamic>>[
    {
      'title': 'Exterior Polish',
      'price': '\$49.99',
      'imageUrl': 'assets/carwash/yellowcar.png',
      'description': 'Bring back the shine and protect your paint.',
      'features': [
        'Hand Wash & Dry',
        'Clay Bar Treatment',
        'Single-Stage Machine Polish',
      ],
    },
    {
      'title': 'Interior Deep Clean',
      'price': '\$59.99',
      'imageUrl': 'assets/carwash/features/inteririorclean.png',
      'description': 'Sanitation, stain removal, and a fresh cabin feel.',
      'features': [
        'Full Interior Vacuum',
        'Shampoo & Steam Clean',
        'Dashboard & Console Polish',
      ],
    },
    {
      'title': 'Full Service',
      'price': '\$89.99',
      'imageUrl': 'assets/carwash/features/primuim.png',
      'description': 'The comprehensive, all-in-one car care package.',
      'features': [
        'Includes Exterior Polish',
        'Includes Interior Deep Clean',
        'Wheel & Tire Shine',
      ],
    },
    {
      'title': 'Headlight Restoration',
      'price': '\$24.99',
      'imageUrl': 'assets/carwash/features/headlight.png',
      'description': 'Restore clarity and brightness to your headlights.',
      'features': [
        'Clean & Polish Lenses',
        'Remove Haze & Yellowing',
        'Apply Protective Coating',
      ],
    },
    {
      'title': 'Leather Conditioning',
      'price': '\$19.99',
      'imageUrl': 'assets/carwash/features/tireandwheelclean.png',
      'description': 'Condition and protect your vehicle\'s leather surfaces.',
      'features': [
        'Clean Leather Surfaces',
        'Apply Conditioning Product',
        'Protect Against Cracking',
      ],
    },
  ].obs;
}
