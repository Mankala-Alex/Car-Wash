import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NotificationController extends GetxController {
  // -------------------------
  // NOTIFICATION LIST
  // -------------------------
  RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[
    {
      "icon": Icons.directions_car,
      "bg": Colors.orange,
      "title": "Your technician is on the way!",
      "msg": "Track their arrival in real-time on the map.",
      "time": "2m ago",
      "unread": true,
    },
    {
      "icon": Icons.local_offer,
      "bg": Colors.green,
      "title": "Get 20% off your next premium wash!",
      "msg": "Use code WASH20 for a special discount.",
      "time": "2h ago",
      "unread": true,
    },
    {
      "icon": Icons.check_circle,
      "bg": Colors.orange,
      "title": "Your car wash is confirmed",
      "msg": "Your booking for tomorrow at 10:00 AM is all set.",
      "time": "Yesterday",
      "unread": false,
    },
    {
      "icon": Icons.receipt_long,
      "bg": Colors.orange,
      "title": "Payment was successful",
      "msg": "Your payment of \$45.00 has been processed.",
      "time": "Yesterday",
      "unread": false,
    },
    {
      "icon": Icons.campaign,
      "bg": Colors.teal,
      "title": "New interior detailing package",
      "msg": "Give your car the love it deserves.",
      "time": "Dec 15",
      "unread": false,
    },
    {
      "icon": Icons.celebration,
      "bg": Colors.green,
      "title": "Holiday cleaning special!",
      "msg": "Get your car sparkling for the holidays.",
      "time": "Dec 12",
      "unread": false,
    },
  ].obs;

  // ---------------------------------
  // FILTERED LIST FOR SEARCH
  // ---------------------------------
  RxList<Map<String, dynamic>> filteredList = <Map<String, dynamic>>[].obs;

  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filteredList.value = notifications;

    // Update list automatically on search
    ever(searchQuery, (_) => applySearch());
  }

  // -------------------------
  // SEARCH (REAL-TIME)
  // -------------------------
  void searchNotifications(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  void applySearch() {
    if (searchQuery.isEmpty) {
      filteredList.value = notifications;
      return;
    }

    filteredList.value = notifications.where((n) {
      return n["title"].toString().toLowerCase().contains(searchQuery.value) ||
          n["msg"].toString().toLowerCase().contains(searchQuery.value);
    }).toList();
  }

  // -------------------------
  // MARK ALL READ
  // -------------------------
  void markAllRead() {
    for (var n in notifications) {
      n["unread"] = false;
    }
    notifications.refresh();
    applySearch();
  }
}
