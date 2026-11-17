import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:car_wash_customer_app/app/helpers/media_url.dart';
import 'package:car_wash_customer_app/app/models/offers_model.dart';
import 'package:car_wash_customer_app/app/routes/app_routes.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

/// Turns an offer image value into a usable URL.
///
/// Accepts an absolute URL, a backend relative path (`/uploads/offers/x.jpg`)
/// or a bare path (`uploads/offers/x.jpg`) and normalises Windows separators.
///
/// The host is taken from `API_BASE_URL` (the backend that actually stored the
/// upload) and only falls back to `Constants.imageBaseUrl` when no API base is
/// configured. Offer banners are uploaded from the admin portal to whichever
/// backend that portal talks to, so they must be fetched from the same place —
/// `Constants.imageBaseUrl` (the public site) does not carry them.
String offerImageUrl(String? raw) => resolveMediaUrl(raw);

/// The ONE aspect ratio every offer image is exported at: **2 : 1**
/// (e.g. 1200x600 px).
///
/// The popup dialog, the home "Offers for you" card and the offer details
/// screen all size their image box with `AspectRatio(offerImageAspectRatio)`,
/// so the very same uploaded file is shown fully — never cropped and never
/// stretched — on small phones, big phones and tablets.
const double offerImageAspectRatio = 2.0;

/// Full-width banner of an offer (image when the admin uploaded one, otherwise
/// a warm gradient with the discount).
class OfferBanner extends StatelessWidget {
  const OfferBanner({
    super.key,
    required this.offer,
    this.height,
    this.fit = BoxFit.contain,
  });

  final Offersmodel offer;

  /// Optional fixed height. Prefer leaving it `null`: the banner then keeps
  /// [offerImageAspectRatio] and derives its height from its own width, which
  /// is what makes it look identical everywhere.
  final double? height;

  /// `contain` shows the whole artwork; `cover` fills the area and crops.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = offerImageUrl(offer.imageUrl);

    // No background is painted behind the banner: a transparent PNG must show
    // its own artwork only (whatever is behind it stays visible).
    final Widget content = imageUrl.isEmpty
        ? Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB067), Color(0xFFFF8A2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_offer, size: 54, color: Colors.white),
          )
        : Image.network(
            imageUrl,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFFFF4E5),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_offer,
                size: 54,
                color: AppColors.secondaryLight,
              ),
            ),
          );

    if (height != null) {
      return SizedBox(height: height, width: double.infinity, child: content);
    }

    return AspectRatio(aspectRatio: offerImageAspectRatio, child: content);
  }
}

/// "Discount" headline shared by the popup and the details screen.
List<InlineSpan> discountHeadlineSpans(Offersmodel offer) {
  if (offer.discountType.toLowerCase() == 'percentage') {
    return [TextSpan(text: "${offer.discountValue}${'percent_off'.tr}")];
  }

  return riyalAmountSpans(amount: offer.discountValue, suffix: " ${'off'.tr}");
}

/// The new-customer login popup.
///
/// Shown once per offer per customer (the backend records it), so a dismissed
/// popup never comes back.
void showNewUserOfferPopup(Offersmodel offer) {
  final isArabic = (Get.locale?.languageCode ?? 'en').toLowerCase().startsWith(
        'ar',
      );
  final title = isArabic
      ? (offer.titleAr.isNotEmpty ? offer.titleAr : offer.titleEn)
      : (offer.titleEn.isNotEmpty ? offer.titleEn : offer.titleAr);

  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Same 2:1 banner on phones and tablets.
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner ONLY — no card/background behind it, so a transparent PNG
          // shows just its own artwork over the dimmed screen.
          Stack(
            alignment: Alignment.topRight,
            children: [
              OfferBanner(offer: offer),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ),
            ],
          ),

          // Text + buttons still need a readable surface.
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: discountHeadlineSpans(offer)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.secondaryLight,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        offer.offerCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.secondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
                if (title.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
                if (offer.terms.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    offer.terms,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Expanded(
                    //   child: OutlinedButton(
                    //     onPressed: () => Get.back(),
                    //     style: OutlinedButton.styleFrom(
                    //       padding: const EdgeInsets.symmetric(vertical: 13),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(14),
                    //       ),
                    //     ),
                    //     child: Text('later'.tr),
                    //   ),
                    // ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(Routes.offerscreen, arguments: offer);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryLight,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'view_details'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
