import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:car_wash_customer_app/app/controllers/support/support_chat_controller.dart';
import 'package:car_wash_customer_app/app/custome_widgets/riyal_amount.dart';
import 'package:car_wash_customer_app/app/models/support/support_models.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

/// Live chat between the customer and the support team.
class SupportChatView extends GetView<SupportChatController> {
  const SupportChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        titleSpacing: 0,
        title: Obx(() => _headerTitle()),
        actions: [
          Obx(() {
            if (controller.conversation.value == null) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: "support_conversation_options".tr,
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onPressed: () {
                final isClosed =
                    controller.conversation.value?.isClosed ?? false;

                isClosed
                    ? controller.reopenConversation()
                    : controller.closeConversation();
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isInitializing.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.secondaryLight),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.conversation.value == null) {
          return _errorState();
        }

        return Column(
          children: [
            _statusStrip(),
            _bookingCard(),
            Expanded(child: _messagesList()),
            _composer(),
          ],
        );
      }),
    );
  }

  // ---------------- Booking context ----------------
  /// Compact, authoritative booking card for booking-linked conversations.
  Widget _bookingCard() {
    final summary = controller.conversation.value?.booking;
    if (summary == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.bgLightSecondaryLight,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLightGrayLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                size: 14,
                color: AppColors.secondaryLight,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  summary.bookingCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDefaultLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  summary.status.isEmpty ? "not_available".tr : summary.status,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(
              children: riyalAmountSpans(
                amount: summary.amount.toStringAsFixed(2),
                prefix: [
                  if (summary.serviceName.isNotEmpty) summary.serviceName,
                  if (summary.scheduledAt != null)
                    DateFormat(
                      'dd MMM • hh:mm a',
                    ).format(summary.scheduledAt!.toLocal()),
                  if ((summary.paymentStatus ?? '').isNotEmpty)
                    "${"payment".tr}: ${summary.paymentStatus}",
                ].map((part) => "$part · ").join(),
              ),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textLightGrayLight,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- App bar ----------------
  Widget _headerTitle() {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.support_agent,
            size: 20,
            color: AppColors.secondaryLight,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "support_chat_title".tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                controller.agentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Status strip ----------------
  Widget _statusStrip() {
    final conversation = controller.conversation.value;
    if (conversation == null) return const SizedBox.shrink();

    final closed = conversation.isClosed;

    return Container(
      width: double.infinity,
      color: closed ? const Color(0xFFFDECEA) : AppColors.bgLightSecondaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        closed
            ? "support_chat_closed_message".tr
            : "${controller.statusLabel} · ${"support_reply_time".tr}",
        style: TextStyle(
          fontSize: 11.5,
          color: closed ? AppColors.errorLight : AppColors.textLightGrayLight,
        ),
      ),
    );
  }

  // ---------------- Messages ----------------
  Widget _messagesList() {
    if (controller.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 46,
                color: AppColors.textLightGrayLight,
              ),
              const SizedBox(height: 12),
              Text(
                "support_chat_empty".tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textLightGrayLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final typingRows = controller.agentTyping.value ? 1 : 0;

    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: controller.messages.length +
          (controller.hasMore.value ? 1 : 0) +
          typingRows,
      itemBuilder: (context, index) {
        if (controller.hasMore.value && index == 0) {
          return Center(
            child: controller.isLoadingMore.value
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: controller.loadOlderMessages,
                    child: Text("load_older_messages".tr),
                  ),
          );
        }

        final messageIndex = controller.hasMore.value ? index - 1 : index;

        // Last row is the agent typing indicator, not a stored message.
        if (messageIndex >= controller.messages.length) {
          return _typingIndicator();
        }

        final message = controller.messages[messageIndex];

        if (message.isSystem) {
          return _systemBubble(message);
        }

        return _messageBubble(message);
      },
    );
  }

  /// "Support is typing…" bubble with three pulsing dots.
  Widget _typingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 2, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF4F5F7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDots(),
            const SizedBox(width: 8),
            Text(
              "support_typing".tr,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textLightGrayLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _systemBubble(SupportMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 30),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textLightGrayLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _messageBubble(SupportMessage message) {
    final isMine = message.isMine;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(Get.context!).size.width * 0.76,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primaryLight : const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMine ? 14 : 2),
            bottomRight: Radius.circular(isMine ? 2 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine && (message.senderName ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  message.senderName!,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryLight,
                  ),
                ),
              ),
            Text(
              message.message,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.textDefaultLight,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeLabel(message.createdAt),
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textLightGrayLight,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 5),
                  _deliveryIcon(message),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _deliveryIcon(SupportMessage message) {
    switch (message.status) {
      case SupportMessageStatus.sending:
        return const SizedBox(
          height: 10,
          width: 10,
          child: CircularProgressIndicator(strokeWidth: 1.2),
        );
      case SupportMessageStatus.failed:
        return GestureDetector(
          onTap: () => controller.retryMessage(message),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 12,
                color: AppColors.errorLight,
              ),
              const SizedBox(width: 3),
              Text(
                "tap_to_retry".tr,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppColors.errorLight,
                ),
              ),
            ],
          ),
        );
      case SupportMessageStatus.sent:
        return Icon(
          message.readAt != null ? Icons.done_all : Icons.check,
          size: 12,
          color: message.readAt != null
              ? AppColors.successLight
              : AppColors.textLightGrayLight,
        );
    }
  }

  String _timeLabel(DateTime? date) {
    if (date == null) return '';
    return DateFormat('hh:mm a').format(date.toLocal());
  }

  // ---------------- Composer ----------------
  Widget _composer() {
    final closed = controller.conversation.value?.isClosed ?? true;

    if (closed) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.bgLight,
          border: Border(
            top: BorderSide(color: AppColors.borderLightGrayLight),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: controller.isClosing.value
                ? null
                : controller.reopenConversation,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text("support_reopen_chat".tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondaryLight,
              side: const BorderSide(color: AppColors.secondaryLight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.bgLight,
        border: Border(top: BorderSide(color: AppColors.borderLightGrayLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller.textController,
                minLines: 1,
                maxLines: 4,
                maxLength: 2000,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: "type_your_message".tr,
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLightGrayLight,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF4F5F7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => SizedBox(
                height: 44,
                width: 44,
                child: ElevatedButton(
                  onPressed: controller.canSend ? controller.send : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryLight,
                    disabledBackgroundColor: AppColors.bgBtnDisableLight,
                    elevation: 0,
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: controller.isSending.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Error ----------------
  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 46,
              color: AppColors.textLightGrayLight,
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textLightGrayLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.retry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryLight,
                elevation: 0,
              ),
              child: Text(
                "retry".tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: controller.goBackToHelpCenter,
              child: Text("help_center_title".tr),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three pulsing dots, like the typing indicator in chat apps.
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Each dot peaks 200ms after the previous one.
            final progress = (_controller.value + index * 0.2) % 1.0;
            final scale = 0.6 + 0.4 * (1 - (progress - 0.5).abs() * 2);

            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  height: 6,
                  width: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.textLightGrayLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
