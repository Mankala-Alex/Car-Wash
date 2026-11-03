import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:car_wash_customer_app/app/controllers/support/faq_chat_controller.dart';
import 'package:car_wash_customer_app/app/theme/app_theme.dart';

/// Guided help conversation for one topic: the questions of the topic arrive as
/// chat options, answers show inline, and the last step hands over to an agent.
class FaqChatView extends GetView<FaqChatController> {
  const FaqChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          controller.categoryName,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _body()),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _body() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.secondaryLight),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        itemCount:
            controller.entries.length + (controller.isBotTyping.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.entries.length) {
            return _typingBubble();
          }

          return _entry(
            controller.entries[index],
            isLast: index == controller.entries.length - 1,
          );
        },
      );
    });
  }

  // ---------------- One conversation entry ----------------
  Widget _entry(GuideEntry entry, {required bool isLast}) {
    final isUser = entry.fromUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[_botAvatar(), const SizedBox(width: 8)],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(Get.context!).size.width * 0.78,
                  ),
                  padding: const EdgeInsets.fromLTRB(13, 10, 13, 11),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primaryLight
                        : (entry.isError
                              ? const Color(0xFFFDECEA)
                              : const Color(0xFFF4F5F7)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: Radius.circular(isUser ? 15 : 3),
                      bottomRight: Radius.circular(isUser ? 3 : 15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.text,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: entry.isError
                              ? AppColors.errorLight
                              : AppColors.textDefaultLight,
                        ),
                      ),
                      if (entry.steps.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          "troubleshooting_steps".tr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLightBlueLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...List.generate(entry.steps.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 18,
                                  width: 18,
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.steps[index],
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      height: 1.45,
                                      color: AppColors.textLightBlueLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      if ((entry.screenRoute ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: TextButton.icon(
                            onPressed: () =>
                                controller.openScreenRoute(entry.screenRoute),
                            icon: const Icon(
                              Icons.open_in_new,
                              size: 15,
                              color: AppColors.secondaryLight,
                            ),
                            label: Text(
                              "go_to_screen".tr,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryLight,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Options are only live on the latest message.
          if (isLast && entry.choices.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: 10,
                left: isUser ? 0 : 38,
                right: isUser ? 38 : 0,
              ),
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 8,
                children: entry.choices
                    .map(
                      (choice) => _choiceButton(
                        choice.label,
                        () => controller.choose(choice),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _choiceButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondaryLight),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _botAvatar() {
    return Container(
      height: 30,
      width: 30,
      decoration: const BoxDecoration(
        color: AppColors.bgLightSecondaryLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.support_agent,
        size: 17,
        color: AppColors.secondaryLight,
      ),
    );
  }

  Widget _typingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _botAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              "guided_typing".tr,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textLightGrayLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Bottom bar ----------------
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: const BoxDecoration(
        color: AppColors.bgLight,
        border: Border(top: BorderSide(color: AppColors.borderLightGrayLight)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: controller.escalateToAgent,
                icon: const Icon(
                  Icons.headset_mic_outlined,
                  size: 18,
                  color: AppColors.secondaryLight,
                ),
                label: Text(
                  "guided_chat_team".tr,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryLight,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.secondaryLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
