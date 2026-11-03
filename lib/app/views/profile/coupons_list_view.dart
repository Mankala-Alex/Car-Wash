import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:car_wash_customer_app/app/controllers/profile/coupons_list_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/skeleton_box.dart';
import 'package:car_wash_customer_app/app/models/coupons_list_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

/// My Coupons screen.
///
/// Coupons come from `GET /api/coupons/my` and are grouped into:
/// * available — `status == ACTIVE` and not expired,
/// * history  — used / expired.
///
/// Coupons are view-only for the customer; they are redeemed by the partner.
class CouponsListView extends GetView<CouponsListController> {
  const CouponsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text("my_coupons".tr),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final hasCoupons = controller.hasCoupons;

        if (controller.isLoading.value && !hasCoupons) {
          return _buildLoading();
        }

        if (controller.errorKey.value.isNotEmpty && !hasCoupons) {
          return _buildError();
        }

        if (!hasCoupons) {
          return _buildEmpty();
        }

        final available = controller.availableCoupons;
        final history = controller.historyCoupons;

        return RefreshIndicator(
          color: AppColors.secondaryLight,
          onRefresh: controller.fetchCoupons,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              if (available.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _RewardsBanner(),
                ),
                _sectionTitle("available_coupons".tr),
                ...available.map(
                  (coupon) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildCouponCard(coupon, isUsable: true),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "no_coupons_available".tr,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
              ],
              if (history.isNotEmpty) ...[
                _sectionTitle("coupon_history".tr),
                ...history.map(
                  (coupon) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildCouponCard(coupon, isUsable: false),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  // ================= STATES =================

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const SkeletonBox(width: double.infinity, height: 135, radius: 26),
        const SizedBox(height: 20),
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonBox(width: double.infinity, height: 150, radius: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorKey.value.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.fetchCoupons,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                "retry".tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: AppColors.secondaryLight,
      onRefresh: controller.fetchCoupons,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            "no_coupons_available".tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            "coupons_awarded_after_completion".tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textDefaultLight,
        ),
      ),
    );
  }

  Widget _buildCouponCard(CouponsListModel coupon, {required bool isUsable}) {
    final eligible = coupon.eligibleServicesLabel;
    final expiry = coupon.expiresAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.borderGray,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // DISCOUNT + TITLE
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.percent,
                  color: AppColors.secondaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${coupon.discountLabel}${'percent_off'.tr}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coupon.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // COUPON CODE
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 15,
                color: Colors.black45,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  coupon.couponCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),

          // ELIGIBLE SERVICES
          if (eligible.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_car_wash_outlined,
                  size: 15,
                  color: Colors.black45,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${"eligible_services".tr}: $eligible",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // STATUS + EXPIRY
          Row(
            children: [
              _statusPill(coupon),
              const Spacer(),
              if (expiry != null)
                Text(
                  "${"valid_till".tr} "
                  "${DateFormat('dd MMM yyyy').format(expiry.toLocal())}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(
                  Routes.coupondetailsview,
                  arguments: {"coupon_code": coupon.couponCode},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isUsable ? AppColors.secondaryLight : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                isUsable ? "use_now".tr : "view_details".tr,
                style: TextStyle(
                  color: isUsable ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(CouponsListModel coupon) {
    final Color color;
    if (coupon.isActive) {
      color = Colors.green;
    } else if (coupon.isUsed) {
      color = Colors.blueGrey;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        coupon.statusKey.tr,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _RewardsBanner extends StatelessWidget {
  const _RewardsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB347),
            Color(0xFFFFCC33),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "youve_got_new_rewards".tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
