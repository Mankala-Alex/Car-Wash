import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_new_app/app/controllers/dashboard/notification_controller.dart';

class NotificationsView extends GetView<NotificationController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: const Text(
              "Mark all read",
              style: TextStyle(color: Colors.blue, fontSize: 14),
            ),
          )
        ],
      ),

      // ----------- BODY ------------
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search notifications",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: controller.searchNotifications,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.filteredList.isEmpty) {
                return const Center(
                  child: Text(
                    "No notifications found",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: controller.filteredList.length,
                itemBuilder: (context, index) {
                  final n = controller.filteredList[index];

                  return _notificationTile(
                    icon: n["icon"],
                    iconBg: n["bg"],
                    title: n["title"],
                    message: n["msg"],
                    time: n["time"],
                    unread: n["unread"],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // Notification Tile Widget
  // -------------------------------------------------------------
  Widget _notificationTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String message,
    required String time,
    required bool unread,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT ICON
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconBg, size: 20),
          ),

          const SizedBox(width: 14),

          // MAIN TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // BLUE DOT (Unread)
          if (unread)
            Container(
              height: 10,
              width: 10,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
