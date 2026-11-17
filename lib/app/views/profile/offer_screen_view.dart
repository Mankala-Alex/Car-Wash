import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:car_wash_customer_app/app/controllers/booking_flow/features_list_controller.dart';
import 'package:car_wash_customer_app/app/controllers/profile/offer_screen_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/new_user_offer_popup.dart';
import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:car_wash_customer_app/app/models/offers_model.dart';

class OfferScreenView extends GetView<OfferScreenController> {
  const OfferScreenView({super.key});

  bool get _isArabic =>
      (Get.locale?.languageCode ?? 'en').toLowerCase().startsWith('ar');

  static const List<String> _daysEn = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const List<String> _daysAr = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  String _dayName(int day) {
    final list = _isArabic ? _daysAr : _daysEn;
    return list[day % 7];
  }

  /// "10:00" -> "10:00 AM"
  String _time12h(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return hhmm;

    return DateFormat('h:mm a').format(DateTime(2000, 1, 1, hour, minute));
  }

  /// Names of the services this coupon can be used on.
  String _servicesText(Offersmodel offer) {
    if (offer.serviceIds.isEmpty) return "all_services".tr;

    try {
      if (Get.isRegistered<FeaturesListController>()) {
        final services = Get.find<FeaturesListController>().services;
        final names = offer.serviceIds.map((id) {
          final match = services.firstWhereOrNull((s) => s.id == id);
          return match?.getLocalizedName() ?? id;
        }).toList();

        if (names.isNotEmpty) return names.join(", ");
      }
    } catch (_) {
      // Fall through to the id count when the service list is not loaded.
    }

    return offer.serviceIds.length.toString();
  }

  @override
  Widget build(BuildContext context) {
    final offer = controller.offer;

    final String localizedTitle = _isArabic
        ? (offer.titleAr.isNotEmpty ? offer.titleAr : offer.titleEn)
        : (offer.titleEn.isNotEmpty ? offer.titleEn : offer.titleAr);

    final String localizedTerms = _isArabic
        ? (offer.termsAr.isNotEmpty ? offer.termsAr : offer.termsEn)
        : (offer.termsEn.isNotEmpty ? offer.termsEn : offer.termsAr);

    final String daysText = offer.daysOfWeek.isEmpty
        ? "every_day".tr
        : offer.daysOfWeek.map(_dayName).join(", ");

    final String slotsText = offer.slotStartTimes.isEmpty
        ? "any_time".tr
        : offer.slotStartTimes.map(_time12h).join(", ");

    final String servicesText = _servicesText(offer);

    /// Discount title logic
    List<InlineSpan> discountTitleSpans = offer.discountType == "percentage"
        ? [TextSpan(text: "${offer.discountValue}${'percent_off'.tr}")]
        : riyalAmountSpans(amount: offer.discountValue, suffix: " ${'off'.tr}");

    /// Expiry date
    String expiryDate = controller.getExpiryDate(offer);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "offer_details".tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE (uploaded by the admin, optional) — same 2:1 box as the
            /// popup and the home card, so one file fits everywhere.
            if (offerImageUrl(offer.imageUrl).isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: OfferBanner(offer: offer),
              ),

            const SizedBox(height: 20),

            /// TITLE (Discount)
            Text.rich(
              TextSpan(children: discountTitleSpans),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 12),

            /// COUPON CODE — this is what the customer applies at checkout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Text(
                    "${'offer_code'.tr}: ${offer.offerCode}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// TITLE (localized)
            Text(
              localizedTitle.isNotEmpty
                  ? localizedTitle
                  : "no_description_available".tr,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 28),

            /// EXPIRY + TERMS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SERVICE(S)
                  _infoRow(
                    icon: Icons.local_car_wash,
                    label: "service".tr,
                    value: servicesText,
                  ),

                  const SizedBox(height: 14),

                  /// VALID DAYS
                  _infoRow(
                    icon: Icons.event_available,
                    label: "valid_days".tr,
                    value: daysText,
                  ),

                  const SizedBox(height: 14),

                  /// VALID TIME SLOTS
                  _infoRow(
                    icon: Icons.schedule,
                    label: "valid_time_slots".tr,
                    value: slotsText,
                  ),

                  const SizedBox(height: 14),

                  // /// USES PER CUSTOMER
                  // _infoRow(
                  //   icon: Icons.person,
                  //   label: "uses_per_customer".tr,
                  //   value: offer.maxUsesPerCustomer.toString(),
                  // ),

                  // const SizedBox(height: 14),

                  // /// TOTAL USES
                  // _infoRow(
                  //   icon: Icons.groups,
                  //   label: "total_uses".tr,
                  //   value: offer.maxTotalUses?.toString() ?? "unlimited".tr,
                  // ),

                  // const SizedBox(height: 14),
                  // Divider(color: Colors.grey.shade300),
                  // const SizedBox(height: 14),

                  /// EXPIRY ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "expires_on".tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        expiryDate,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 14),

                  /// TERMS TITLE
                  Text(
                    "terms_conditions".tr,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Bullet Points (split by ".")
                  /// Bullet Points (split by ".")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: localizedTerms
                        .split(".")
                        .where((t) => t.trim().isNotEmpty)
                        .map(
                          (t) => TermsBullet(text: "${t.trim()}."),
                        ) // trim each sentence
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// Redeem button (no backend yet)
            // Container(
            //   width: double.infinity,
            //   height: 52,
            //   margin: const EdgeInsets.only(bottom: 16),
            //   decoration: BoxDecoration(
            //     color: Colors.orange,
            //     borderRadius: BorderRadius.circular(25),
            //   ),
            //   child: TextButton(
            //     onPressed: () {},
            //     child: Text(
            //       "redeem_now".tr,
            //       style: const TextStyle(
            //         fontSize: 17,
            //         fontWeight: FontWeight.w700,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  /// One "icon + label ......... value" line of the details card.
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: Colors.orange),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: _isArabic ? TextAlign.left : TextAlign.right,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class TermsBullet extends StatelessWidget {
  final String text;
  const TermsBullet({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // bullet icon
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.black87),
          ),
          const SizedBox(width: 10),
          // Use Expanded so text gets available width and wraps
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: Colors.grey.shade800,
              ),
              softWrap: true,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
