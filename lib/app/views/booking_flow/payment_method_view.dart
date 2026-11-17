import 'package:car_wash_customer_app/app/controllers/booking_flow/payment_method_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:car_wash_customer_app/app/models/payment/saved_card_model.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Payment method chooser shown after "Pay Now" and before any payment
/// attempt is created.
class PaymentMethodView extends GetView<PaymentMethodController> {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text("select_payment_method".tr),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoadingMethods.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final error = controller.methodsError.value;

                if (error != null) {
                  return _buildErrorState(error);
                }

                return _buildMethods();
              }),
            ),
            _buildContinueBar(),
          ],
        ),
      ),
    );
  }

  // ==============================
  // ERROR
  // ==============================

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: AppColors.errorLight,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textLightBlueLight,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.loadPaymentMethods,
              icon: const Icon(Icons.refresh),
              label: Text("retry".tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================
  // METHODS
  // ==============================

  Widget _buildMethods() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountCard(),
          const SizedBox(height: 20),
          Text(
            "choose_how_to_pay".tr,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLightGrayLight,
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.cardEnabled.value) {
              return _buildMethodTile(
                value: PaymentMethodController.cardMethod,
                title: "credit_debit_card".tr,
                subtitle: "pay_securely_with_card".tr,
                icon: Icons.credit_card,
                iconBackground: AppColors.blue,
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (controller.applePayEnabled.value) {
              return _buildMethodTile(
                value: PaymentMethodController.applePayMethod,
                title: "apple_pay".tr,
                subtitle: "pay_quickly_with_apple_pay".tr,
                icon: Icons.apple,
                iconBackground: Colors.black,
              );
            }
            return const SizedBox.shrink();
          }),

          /// SAVED CARDS — only relevant when paying by card.
          Obx(() {
            if (controller.selectedMethod.value !=
                PaymentMethodController.cardMethod) {
              return const SizedBox.shrink();
            }

            return _buildSavedCardsSection();
          }),
        ],
      ),
    );
  }

  // ==============================
  // SAVED CARDS
  // ==============================

  Widget _buildSavedCardsSection() {
    if (controller.isLoadingSavedCards.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final cards = controller.savedCards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          "saved_cards".tr,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLightGrayLight,
          ),
        ),
        const SizedBox(height: 12),
        ...cards.map(_buildSavedCardTile),
        _buildNewCardTile(),
        if (controller.selectedSavedCardId.value == null)
          _buildSaveCardToggle(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSavedCardTile(SavedCardModel card) {
    return Obx(() {
      final isSelected = controller.selectedSavedCardId.value == card.id;
      final isDeleting = controller.deletingSavedCardId.value == card.id;
      final isDisabled = controller.isLoading.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: isDisabled ? null : () => controller.selectSavedCard(card.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? AppColors.secondaryLight : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.secondaryLight
                      : AppColors.borderGray,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.displayLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (card.formattedExpiry.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          "${'expires_colon'.tr} ${card.formattedExpiry}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLightGrayLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isDeleting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    tooltip: "remove_card".tr,
                    onPressed: isDisabled ? null : () => _confirmDelete(card),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.errorLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNewCardTile() {
    return Obx(() {
      final isSelected = controller.selectedSavedCardId.value == null;
      final isDisabled = controller.isLoading.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: isDisabled ? null : () => controller.selectSavedCard(null),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? AppColors.secondaryLight : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.secondaryLight
                      : AppColors.borderGray,
                ),
                const SizedBox(width: 12),
                const Icon(Icons.add_card, color: AppColors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "pay_with_new_card".tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSaveCardToggle() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SwitchListTile.adaptive(
          value: controller.saveCardForNextTime.value,
          onChanged: controller.isLoading.value
              ? null
              : controller.toggleSaveCardForNextTime,
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.secondaryLight,
          title: Text(
            "save_card".tr,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            "save_card_hint".tr,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLightGrayLight,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _confirmDelete(SavedCardModel card) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text("remove_card".tr),
        content: Text("remove_card_message".tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("cancel".tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text("remove".tr),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteSavedCard(card);
    }
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Expanded so a long service name wraps onto the next line instead of
          // being cut off / pushed under the amount.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "total_amount".tr,
                  style: const TextStyle(
                    color: AppColors.textLightGrayLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.serviceName.isEmpty
                      ? "booking_payment".tr
                      : controller.serviceName,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          RiyalAmount(
            controller.amount.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackground,
  }) {
    return Obx(() {
      final isSelected = controller.selectedMethod.value == value;
      final isDisabled = controller.isLoading.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: isDisabled ? null : () => controller.selectMethod(value),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? AppColors.secondaryLight : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLightGrayLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.secondaryLight
                      : AppColors.borderGray,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ==============================
  // CONTINUE
  // ==============================

  Widget _buildContinueBar() {
    return Obx(() {
      final disabled = controller.isLoadingMethods.value ||
          controller.isLoading.value ||
          controller.selectedMethod.value.isEmpty ||
          controller.methodsError.value != null;

      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey.shade100,
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: disabled ? null : controller.continueWithSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryLight,
              disabledBackgroundColor: AppColors.bgBtnDisableLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "continue".tr,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
