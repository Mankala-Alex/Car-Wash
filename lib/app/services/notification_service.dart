import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Central place for every local notification the app shows itself.
///
/// Same behaviour as on Android: the app renders the banner locally, with
/// BOTH an Android and an iOS (Darwin) detail block. A [NotificationDetails]
/// without the `iOS:` block is silently dropped by iOS — including while the
/// app is in the foreground — and the iOS Simulator can never receive
/// FCM/APNs pushes at all, so this is the only banner path there.
///
/// Singleton: `NotificationService.instance`.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String defaultChannelId = 'default_channel';
  static const String highImportanceChannelId = 'high_importance_channel';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Guards `init()`: initialising twice re-registers the tap callback.
  bool _initialized = false;

  /// Recently shown [dedupeKey]s, so the same event delivered twice (push +
  /// socket, or a reconnect replay) does not banner twice.
  final Map<String, DateTime> _dedupe = <String, DateTime>{};

  bool get isInitialized => _initialized;

  /// Prepares the plugin (channels, permissions, tap callback).
  /// Never throws — a notification failure must not break the app.
  Future<void> init({void Function(String? payload)? onTap}) async {
    if (_initialized) return;

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Foreground presentation defaults only.
      //
      // `request*Permission` MUST stay false: those flags make `initialize()`
      // pop the iOS alert straight away, which is why the permission was being
      // asked on the splash screen. The customer is asked on the dashboard by
      // `NotificationPermissionService` instead.
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
        defaultPresentAlert: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
        defaultPresentSound: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          onTap?.call(response.payload);
        },
      );

      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            defaultChannelId,
            'Default Notifications',
            importance: Importance.high,
          ),
        );

        // The backend sends every push with channelId = 'high_importance_channel'.
        // Creating it here (instead of letting Android auto-create it with
        // DEFAULT importance) keeps booking / coupon alerts loud.
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            highImportanceChannelId,
            'Important Notifications',
            importance: Importance.max,
          ),
        );
      }

      // No permission request here on purpose — see the comment on
      // `darwinSettings` above. `NotificationPermissionService` asks after
      // the customer reached the dashboard.

      _initialized = true;
      debugPrint('🔔 NotificationService ready');
    } catch (e, stackTrace) {
      debugPrint('🔔 NotificationService init failed: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Shows one banner on both platforms.
  ///
  /// [dedupeKey] — pass a stable key (e.g. `booking:<id>:<status>`) when the
  /// same event can arrive more than once; repeats inside [dedupeWindow] are
  /// ignored.
  Future<void> show({
    required String title,
    required String body,
    String? payload,
    String? dedupeKey,
    Duration dedupeWindow = const Duration(seconds: 20),
  }) async {
    if (!_initialized) {
      // Callers (socket handlers) can be reached before init finishes.
      debugPrint('🔔 notification skipped, service not initialised yet');
      return;
    }

    if (dedupeKey != null && _isDuplicate(dedupeKey, dedupeWindow)) {
      debugPrint('🔔 duplicate notification skipped: $dedupeKey');
      return;
    }

    try {
      await _plugin.show(
        // A unique id per notification: a fixed id makes every new push
        // replace the previous one, so only the last one stays visible.
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            highImportanceChannelId,
            'Important Notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
          // Mandatory on iOS: without this block the notification is dropped,
          // including while the app is in the foreground.
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentSound: true,
          ),
        ),
      );
      debugPrint('🔔 notification shown: $title');
    } catch (e) {
      debugPrint('🔔 could not show the notification: $e');
    }
  }

  bool _isDuplicate(String key, Duration window) {
    final now = DateTime.now();
    _dedupe.removeWhere((_, shownAt) => now.difference(shownAt) > window);

    final previous = _dedupe[key];
    if (previous != null && now.difference(previous) <= window) return true;

    _dedupe[key] = now;
    return false;
  }
}
